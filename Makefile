 # Monorepo Makefile run on every commit by Buildkite to only build targets that have changed since the last-good-master-build tag

MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := help
SHELL = /bin/bash -o pipefail
.PHONY: *

# list of targets we want to build when there are changes in the directory of the same name
targets := shared-lib app1 app2

# list of directories with changes since last-good-master-build tag, or all directories if no last-good-master-build tag
last-good-master-build-sha := $(shell git rev-list -n 1 last-good-master-build 2>/dev/null || echo no sha)
changed-directories := $(shell (git diff last-good-master-build...HEAD --name-only 2> /dev/null || ls -d */*) | cut -d'/' -f1 | uniq)
changed-targets := $(filter $(changed-directories),$(targets))

## display this help message
help:
	@awk '/^##.*$$/,/^[~\/\.a-zA-Z_-]+:/' $(MAKEFILE_LIST) | awk '!(NR%2){print $$0p}{p=$$0}' | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' | sort

## list targets in this Makefile
list-targets:
	@echo $(targets)

## fetch last-good-master-build tag, makes sure we have the latest locally
fetch-last-good-master-build:
	git fetch origin +refs/tags/last-good-master-build:refs/tags/last-good-master-build || true

## tag HEAD as last-good-master-build
tag-last-good-master-build:
	git tag -f last-good-master-build && git push -f origin refs/tags/last-good-master-build

## display directories and targets that have changed since last-good-master-build tag
list-changed:
	@echo "Directories with changes since last-good-master-build tag ($(last-good-master-build-sha)):"
	@echo $(changed-directories)
	@echo
	@echo "Changed targets:"
	@echo $(changed-targets)

## build targets that have changed since last-good-master-build tag
build-changed: list-changed $(changed-targets)

## build app1
app1:
	@echo Trigger app1
	$(call trigger,app1) | buildkite-agent pipeline upload

## build app2
app2:
	@echo Trigger app2
	$(call trigger,app2) | buildkite-agent pipeline upload

## build shared-lib & dependents
shared-lib: build-shared-lib app1 app2

## build shared-lib
build-shared-lib:
	@echo Trigger build-shared-lib
	$(call trigger,build-shared-lib) | buildkite-agent pipeline upload

test-trigger:
	$(call trigger,foo) | tee trigger.yml

trigger = printf '$(subst $(\n),\n,$(call trigger.yml,$1))'

define trigger.yml
steps:
- trigger: "monorepo-$1"
  label: ":zap: Trigger $1"
  branches: "*"
  async: false
  build:
    message: "$(subst ','"'"',$(BUILDKITE_MESSAGE))"
    commit: "$(BUILDKITE_COMMIT)"
    branch: "$(BUILDKITE_BRANCH)"
endef

define \n


endef
