bold := $(shell tput bold)
norm := $(shell tput sgr0)

# defaults
REPO_NAME 	?= $(notdir $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..))/$(shell basename '$(PWD)')
GIT_BRANCH 	?= dev

# gh-actions shim
ifdef GITHUB_REPOSITORY
	REPO_NAME := $(GITHUB_REPOSITORY)
endif

ifdef GITHUB_REF
ifneq (,$(findstring refs/heads/,$(GITHUB_REF)))
	GIT_BRANCH := $(GITHUB_REF:refs/heads/%=%)
else ifneq (,$(findstring refs/tags/,$(GITHUB_REF)))
	TAG_NAME := $(GITHUB_REF:refs/tags/%=%)
endif
endif


$(info [REPO_NAME: $(REPO_NAME)])
$(info [GIT_BRANCH: $(GIT_BRANCH)])
$(info [TAG_NAME: $(TAG_NAME)])


.PHONY: all
all:


.PHONY: build
build:
	@echo -e "🔨👷 $(bold)Building$(norm) 👷🔨"

	docker build \
		-t '$(REPO_NAME)' \
		.


.PHONY: test
test:
	@echo -e "🔨🚨 $(bold)Testing$(norm) 🚨🔨"

	docker run --rm '$(REPO_NAME)'


.PHONY: publish
publish:
ifeq ($(GIT_BRANCH),main)
	$(call docker_login)
	@echo -e "🚀🐳 $(bold)Publishing: $(REPO_NAME):latest$(norm) 🐳🚀"
	docker push '$(REPO_NAME)'
else ifdef TAG_NAME
	$(call docker_login)
	@echo -e "🚀🐳 $(bold)Publishing: $(REPO_NAME):$(TAG_NAME)$(norm) 🐳🚀"
	docker tag '$(REPO_NAME)' '$(REPO_NAME):$(TAG_NAME)'
	docker push '$(REPO_NAME):$(TAG_NAME)'
endif


define docker_login
	docker login -u lifeofguenter -p '$(DOCKER_PASSWORD)'
endef
