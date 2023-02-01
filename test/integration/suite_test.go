package integration

import (
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

func TestCatwalk(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Catwalk Suite")
}

var _ = BeforeSuite(func(ctx SpecContext) {
})
