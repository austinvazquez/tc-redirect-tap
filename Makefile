# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at
#
# 	http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

# Set this to pass additional commandline flags to the go compiler, e.g. "make test EXTRAGOARGS=-v"
EXTRAGOARGS?=

SOURCES:=$(shell find . -name '*.go' ! -name '*_test.go')
GOMOD := $(shell go env GOMOD)
GOSUM := $(GOMOD:.mod=.sum)

BINPATH:=$(abspath ./bin)

# Set this to override the directory in which the tc-redirect-tap plugin is
# installed by the "install" target
CNI_BIN_ROOT?=/opt/cni/bin

.PHONY: all
all: tc-redirect-tap

tc-redirect-tap: $(SOURCES) $(GOMOD) $(GOSUM)
	go build -o tc-redirect-tap $(CURDIR)/cmd/tc-redirect-tap

.PHONY: install
install: tc-redirect-tap
	install -D -m755 -t $(CNI_BIN_ROOT) tc-redirect-tap

.PHONY: test
test:
	go test ./... $(EXTRAGOARGS)

.PHONY: clean
clean:
	- rm -f tc-redirect-tap
	- rm -rf $(BINPATH)
	- rm -rf .*.stamp

.PHONY: deps
deps: .lint.stamp

.lint.stamp:
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s -- -b $(BINPATH) v1.46.2
	$(BINPATH)/golangci-lint --version
	@touch $@

.PHONY: lint
lint: .lint.stamp
	$(BINPATH)/golangci-lint run
