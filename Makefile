INFO_COLOR=\033[1;34m
RESET=\033[0m
BOLD=\033[1m
TEST ?= $(shell go list ./... | grep -v -e vendor -e keys -e tmp)
VERSION = $(shell cat version)
GOVERSION=$(shell go version)
REVISION=$(shell git describe --always)
BUILDDATE=$(shell date '+%Y/%m/%d %H:%M:%S %Z')
GO ?= GO111MODULE=on $(SYSTEM) go
BUILD=tmp/bin

test: ## Run test
	@echo "$(INFO_COLOR)==> $(RESET)$(BOLD)Testing$(RESET)"
	$(GO) test -v $(TEST) -timeout=30s -parallel=4
	$(GO) test -race $(TEST)

build: ## Build server
	$(GO) build -ldflags "-s -w -X main.mversion=$(VERSION) -X main.revision=$(REVISION) -X \"main.goversion=$(GOVERSION)\" -X \"main.builddate=$(BUILDDATE)\"" -o $(BUILD)/mackerel-checks-exporter

run:
	$(GO) run main.go

release:
	@echo "$(INFO_COLOR)==> $(RESET)$(BOLD)Releasing for Github$(RESET)"
	rm -rf dist/*
	BUILDDATE="$(BUILDDATE) VERSION="$(VERSION) REVISION="$(REVISION) "GOVERSION="$(GOVERSION)" goreleaser --rm-dist --skip-validate

docker:
	docker build -t pyama/mackerel-check-plugin-exporter:$(VERSION) .
	docker push pyama/mackerel-check-plugin-exporter:$(VERSION)

