ARG TOOLCHAIN_VERSION=latest
#################################################
# STAGE: builder
#------------------------------------------------
FROM docker.io/library/golang:${TOOLCHAIN_VERSION} AS builder

WORKDIR /repo
COPY . /repo

RUN make build

#################################################
# STAGE: runtime
#------------------------------------------------
FROM scratch AS runtime

COPY --from=builder /repo/build/catwalk /usr/bin/catwalk

ENTRYPOINT [ "/usr/bin/catwalk" ]
