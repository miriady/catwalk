VERSION ?= $(shell git tag | head -n 1 | grep "" || echo '0.0.0')$(shell git diff --quiet || echo '-dev')

REGISTRY := ghcr.io
NAME ?= $(shell sed -En 's/^module (.*)$$/\1/p' go.mod | cut -d / -f 3 )
REPOSITORY := $(shell sed -En 's/^module (.*)$$/\1/p' go.mod | cut -d / -f 2 )

TOOLCHAIN_VERSION := $(shell sed -En 's/^go (.*)$$/\1/p' go.mod)
MODULE_NAME := $(shell sed -En 's/^module (.*)$$/\1/p' go.mod)

GO ?= go
ENGINE ?= docker

LDFLAGS += -X ${MODULE_NAME}/version.Version=${VERSION}
LDFLAGS += -X ${MODULE_NAME}/version.Name=${NAME}

CONTAINERFILE ?= Containerfile
OCI_TAGS += --tag=${REGISTRY}/${REPOSITORY}/${NAME}:latest
OCI_TAGS += --tag=${REGISTRY}/${REPOSITORY}/${NAME}:${VERSION}

.PHONY: build
build: clean
	${GO_SETTINGS} ${GO} build \
		-ldflags="${LDFLAGS}" \
		-o ./build/${NAME}

.PHONY: build-release
build-release:
	LDFLAGS="-s -w" make build

.PHONY: dev-dependencies
dev-dependencies:
	cd .dev && docker compose up --detach

.PHONY: docs
docs:
	${GO} run \
		-ldflags="${LDFLAGS}" \
		./scripts/docs-generator.go

.PHONY: e2e
e2e:
	TEST_MODE="-tags=e2e" make test

.PHONY: integration-test
integration-test: build
	cd test && make integration-test

.PHONY: test
test:
	${GO} test ${TEST_MODE} \
		-cover \
		-race \
		-covermode=atomic \
		-coverprofile=coverage.out \
		./...

.PHONY: lint
lint:
	golangci-lint run -v

.PHONY: clean
clean:
	rm -rf ./build

.PHONY: clean-image
clean-image:
	@-${ENGINE} image rm -f $(shell ${ENGINE} image ls -aq ${REGISTRY}${NAME}:${VERSION} | xargs -n1 | sort -u | xargs)

.PHONY: image
image: clean-image
	${ENGINE} build \
		${OCI_TAGS} \
		${OCI_BUILDARGS} \
		--file ${CONTAINERFILE} \
		.
