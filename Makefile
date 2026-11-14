#
# Copyright 2026 Scott Gigawatt
#
# SPDX-License-Identifier: Apache-2.0
#
# Makefile: Automation for building, previewing, validating, and running
#           Plundarrpedia through its Docker Compose application.
#

#
# Makefile target names.
#
ALL=all
BUILD=build
BUILD_DEPENDS=build-depends
BUILD_PLATFORMS=build-platforms
CHECK_ENV=check-env
CLEAN_ARTIFACTS=clean-artifacts
CONFIG=config
DOWN=down
ENV=env
HELP=help
LINT=lint
LOGS=logs
MARKDOWN=markdown
PRINT_CONFIG=print-config
PRINT_ENV=print-env
RUN=run
DOCS_SERVE=docs-serve
DOCS=docs
START=start
STOP=stop
TEST_WORKFLOWS=test-workflows
UP=up

TARGETS= \
	$(ALL) \
	$(BUILD) \
	$(BUILD_DEPENDS) \
	$(BUILD_PLATFORMS) \
	$(CHECK_ENV) \
	$(CLEAN_ARTIFACTS) \
	$(CONFIG) \
	$(DOWN) \
	$(ENV) \
	$(HELP) \
	$(LINT) \
	$(LOGS) \
	$(MARKDOWN) \
	$(PRINT_CONFIG) \
	$(PRINT_ENV) \
	$(RUN) \
	$(DOCS_SERVE) \
	$(DOCS) \
	$(START) \
	$(STOP) \
	$(TEST_WORKFLOWS) \
	$(UP)

#
# Environment file paths.
#
ENV_FILE         ?= .env
EXAMPLE_ENV_FILE ?= example.env

#
# Docker Compose files, services, and reusable command options.
#
COMPOSE_FILE               ?= docker-compose.yml
COMPOSE_ENV_FILE           ?= $(ENV_FILE)
COMPOSE_AUTHOR_ENV_FILE    ?= $(if $(wildcard $(ENV_FILE)),$(ENV_FILE),$(EXAMPLE_ENV_FILE))
COMPOSE_PROJECT_OPTIONS    ?= --env-file $(COMPOSE_ENV_FILE) --file $(COMPOSE_FILE)
COMPOSE_AUTHOR_OPTIONS     ?= --env-file $(COMPOSE_AUTHOR_ENV_FILE) --file $(COMPOSE_FILE)
COMPOSE_BUILD_OPTIONS      ?= --pull --no-cache
COMPOSE_AUTHOR_RUN_OPTIONS ?= --rm --build --service-ports
COMPOSE_SITE_RUN_OPTIONS   ?= --rm --build
COMPOSE_UP_OPTIONS         ?= --build --detach --force-recreate --remove-orphans
COMPOSE_DOWN_OPTIONS       ?= --remove-orphans
COMPOSE_LOGS_OPTIONS       ?= --follow
COMPOSE_CONFIG_OPTIONS     ?=
COMPOSE_ENV_OPTIONS        ?= --environment

PLUNDARRPEDIA_SERVICE      ?= plundarrpedia
AUTHORING_SERVICE          ?= authoring
SITE_SERVICE               ?= site

#
# Static site and authoring settings passed to the Compose tool services.
#
SITE_OUTPUT_PATH    ?= site
MKDOCS_AUTHOR_PORT  ?= 8000

#
# Multi-architecture validation settings. Buildx remains responsible for this
# cache-only build because a local Docker image store cannot load one image for
# three platforms. The build arguments mirror the Compose build model.
#
DOCKERFILE                  ?= docker/Dockerfile
DOCKER_BUILD_CONTEXT        ?= .
BUILDX_BUILD_OPTIONS        ?= --pull --no-cache
BUILDX_PLATFORM_OPTIONS     ?= --platform linux/amd64,linux/arm64,linux/arm/v7
BUILDX_OUTPUT_OPTIONS       ?= --output type=cacheonly
BUILDX_TAG_OPTIONS          ?= --tag ghcr.io/scottgigawatt/plundarrpedia:multiarch-local
BUILDX_FILE_OPTIONS         ?= --file $(DOCKERFILE)
BUILDX_BUILD_ARG_OPTIONS    ?= \
	--build-arg MKDOCS_MATERIAL_IMAGE="$${MKDOCS_MATERIAL_IMAGE}" \
	--build-arg MKDOCS_MATERIAL_TAG="$${MKDOCS_MATERIAL_TAG}" \
	--build-arg NGINX_UNPRIVILEGED_IMAGE="$${NGINX_UNPRIVILEGED_IMAGE}" \
	--build-arg NGINX_UNPRIVILEGED_TAG="$${NGINX_UNPRIVILEGED_TAG}"

#
# Docker Compose command compatible with 'docker compose' (v2) and
# 'docker-compose' (v1).
#
DOCKER_COMPOSE := $(shell \
	if docker compose version >/dev/null 2>&1; then \
		echo "docker compose"; \
	elif command -v docker-compose >/dev/null 2>&1; then \
		echo "docker-compose"; \
	else \
		echo ""; \
	fi)

#
# Build and lint dependencies.
#
DEPENDENCIES=docker
LINT_DEPENDENCIES=pre-commit

#
# Help line formatting function.
#
define help_line
	@printf "  %-22s %s\n" "$(1)" "$(2)"
endef

#
# Verify Docker Compose availability while parsing the Makefile.
#
ifeq ($(DOCKER_COMPOSE),)
    $(error "Neither 'docker compose' nor 'docker-compose' is available. \
        Please install Docker Compose.")
endif

#
# Targets that are not files run every time they are called or required.
#
.PHONY: $(TARGETS)

#
# $(ALL): Default target. Build the production image through Compose.
#
# Dependencies:
#   $(BUILD) - Build the production Plundarrpedia image.
#
$(ALL): $(BUILD)

#
# $(BUILD_DEPENDS): Ensure Docker and Docker Compose are installed.
#
$(BUILD_DEPENDS):
	$(foreach exe,$(DEPENDENCIES), \
		$(if $(shell which $(exe) 2> /dev/null),,$(error "No $(exe) in PATH")))
	@$(DOCKER_COMPOSE) version >/dev/null 2>&1 || { \
		echo "Docker Compose is not available."; \
		echo "Install docker compose or docker-compose."; \
		exit 1; \
	}

#
# $(CHECK_ENV): Ensure the deployment environment file exists.
#
$(CHECK_ENV):
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "\nNo $(ENV_FILE) found."; \
		echo "Copy $(EXAMPLE_ENV_FILE) to $(ENV_FILE), then update the"; \
		echo "Plundarrpedia image, port, and resource settings."; \
		echo "Run: cp $(EXAMPLE_ENV_FILE) $(ENV_FILE)"; \
		exit 1; \
	fi

#
# $(BUILD): Build the production image defined by the Compose application.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are installed.
#   $(CHECK_ENV) - Ensure the deployment environment file exists.
#
$(BUILD): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nBuilding the Plundarrpedia image. ⚒️"
	$(DOCKER_COMPOSE) $(COMPOSE_PROJECT_OPTIONS) build \
		$(COMPOSE_BUILD_OPTIONS) \
		$(PLUNDARRPEDIA_SERVICE)

#
# $(BUILD_PLATFORMS): Verify all published platforms with a cache-only build.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are installed.
#   $(CHECK_ENV) - Ensure the deployment environment file exists.
#
$(BUILD_PLATFORMS): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nVerifying multi-architecture builds for amd64, arm64, and arm/v7. 🧭"
	@set -a; \
	. ./$(COMPOSE_ENV_FILE); \
	set +a; \
	docker buildx build \
		$(BUILDX_BUILD_OPTIONS) \
		$(BUILDX_PLATFORM_OPTIONS) \
		$(BUILDX_OUTPUT_OPTIONS) \
		$(BUILDX_TAG_OPTIONS) \
		$(BUILDX_FILE_OPTIONS) \
		$(BUILDX_BUILD_ARG_OPTIONS) \
		$(DOCKER_BUILD_CONTEXT)

#
# $(DOCS): Export the strict static site through a one-shot Compose service.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are installed.
#   $(CHECK_ENV) - Ensure the deployment environment file exists.
#
$(DOCS): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nRendering the static Plundarrpedia site. 🗺️"
	SITE_OUTPUT_PATH=$(SITE_OUTPUT_PATH) \
		$(DOCKER_COMPOSE) $(COMPOSE_PROJECT_OPTIONS) run \
		$(COMPOSE_SITE_RUN_OPTIONS) \
		$(SITE_SERVICE)

#
# $(CLEAN_ARTIFACTS): Delete only the configured generated static-site directory.
#
$(CLEAN_ARTIFACTS):
	@case "$(SITE_OUTPUT_PATH)" in \
		""|"."|".."|"/"|/*|*".."*) \
			echo "Refusing unsafe SITE_OUTPUT_PATH: $(SITE_OUTPUT_PATH)"; \
			exit 1; \
			;; \
	esac
	@if [ -d "$(CURDIR)/$(SITE_OUTPUT_PATH)" ]; then \
		rm -rf -- "$(CURDIR)/$(SITE_OUTPUT_PATH)"; \
		echo "Removed generated site: $(SITE_OUTPUT_PATH)/"; \
	else \
		echo "No generated site found at $(SITE_OUTPUT_PATH)/"; \
	fi

#
# $(DOCS_SERVE): Run the Compose authoring service with live reload.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are installed.
#
$(DOCS_SERVE): $(BUILD_DEPENDS)
	@echo "\nStarting the authoring server on port $(MKDOCS_AUTHOR_PORT). 📚"
	MKDOCS_AUTHOR_PORT=$(MKDOCS_AUTHOR_PORT) \
		$(DOCKER_COMPOSE) $(COMPOSE_AUTHOR_OPTIONS) run \
		$(COMPOSE_AUTHOR_RUN_OPTIONS) \
		$(AUTHORING_SERVICE)

#
# $(MARKDOWN): Lint every Markdown document with the repository rules.
#
$(MARKDOWN):
	@echo "\nLinting Markdown files. 📝"
	$(foreach exe,$(LINT_DEPENDENCIES), \
		$(if $(shell which $(exe) 2> /dev/null),,$(error "No $(exe) in PATH")))
	pre-commit run markdownlint-cli2 --all-files

#
# $(LINT): Run all repository lint and policy checks.
#
$(LINT):
	@echo "\nRunning repository validation hooks. 🔎"
	$(foreach exe,$(LINT_DEPENDENCIES), \
		$(if $(shell which $(exe) 2> /dev/null),,$(error "No $(exe) in PATH")))
	pre-commit run --all-files

#
# $(TEST_WORKFLOWS): Test Discord payloads and isolated delivery with public fixtures.
#
# Dependencies: Host Python 3, sh, jq, awk, and standard POSIX utilities.
#
$(TEST_WORKFLOWS):
	python3 test/helpers/test_discord_secret_scope.py
	sh test/helpers/test-discord-notifier.sh

#
# $(CONFIG): Render and validate the Docker Compose application model.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are installed.
#   $(CHECK_ENV) - Ensure the deployment environment file exists.
#
$(CONFIG): $(BUILD_DEPENDS) $(CHECK_ENV)
	$(DOCKER_COMPOSE) $(COMPOSE_PROJECT_OPTIONS) config $(COMPOSE_CONFIG_OPTIONS)

#
# $(ENV): Print the environment used to interpolate the Compose model.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are installed.
#   $(CHECK_ENV) - Ensure the deployment environment file exists.
#
$(ENV): $(BUILD_DEPENDS) $(CHECK_ENV)
	$(DOCKER_COMPOSE) $(COMPOSE_PROJECT_OPTIONS) config $(COMPOSE_ENV_OPTIONS)

#
# $(PRINT_CONFIG): Print the raw uncommented Compose source.
#
$(PRINT_CONFIG):
	@awk '{ \
		sub(/#.*/, ""); \
		sub(/[[:space:]]+$$/, ""); \
		if (NF) print \
	}' $(COMPOSE_FILE)

#
# $(PRINT_ENV): Print the raw uncommented example environment configuration.
#
$(PRINT_ENV):
	@awk '{ \
		sub(/#.*/, ""); \
		sub(/[[:space:]]+$$/, ""); \
		if (NF) print \
	}' $(EXAMPLE_ENV_FILE)

#
# $(RUN): Build and start the production Compose stack in the background.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are installed.
#   $(CHECK_ENV) - Ensure the deployment environment file exists.
#
$(RUN): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nBuilding and starting the Plundarrpedia Compose stack. 🚀"
	$(DOCKER_COMPOSE) $(COMPOSE_PROJECT_OPTIONS) up \
		$(COMPOSE_UP_OPTIONS)

#
# $(DOWN): Stop and remove the complete Compose stack.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are installed.
#   $(CHECK_ENV) - Ensure the deployment environment file exists.
#
$(DOWN): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nStopping the Plundarrpedia Compose stack. ⚓"
	$(DOCKER_COMPOSE) $(COMPOSE_PROJECT_OPTIONS) down \
		$(COMPOSE_DOWN_OPTIONS)

#
# $(LOGS): Follow output from the production service.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are installed.
#   $(CHECK_ENV) - Ensure the deployment environment file exists.
#
$(LOGS): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nShowing Plundarrpedia logs. 🔎"
	$(DOCKER_COMPOSE) $(COMPOSE_PROJECT_OPTIONS) logs \
		$(COMPOSE_LOGS_OPTIONS) \
		$(PLUNDARRPEDIA_SERVICE)

#
# $(HELP): Print help information.
#
$(HELP):
	@echo "Usage: make [TARGET]"
	@echo ""
	@echo "Targets:"
	$(call help_line,$(ALL),Builds the production Plundarrpedia image.)
	$(call help_line,$(BUILD),Builds the production image through Compose.)
	$(call help_line,$(BUILD_DEPENDS),Ensures Docker and Compose are installed.)
	$(call help_line,$(BUILD_PLATFORMS),Check image builds for amd64/arm64/arm/v7.)
	$(call help_line,$(CHECK_ENV),Ensures .env exists.)
	$(call help_line,$(CLEAN_ARTIFACTS),Delete the generated static site; keep source files and Docker resources.)
	$(call help_line,$(CONFIG),Renders the Docker Compose model.)
	$(call help_line,$(DOWN),Stops and removes the complete Compose stack.)
	$(call help_line,$(ENV),Prints Compose interpolation values.)
	$(call help_line,$(LINT),Runs all pre-commit validation hooks.)
	$(call help_line,$(LOGS),Shows production service logs.)
	$(call help_line,$(MARKDOWN),Lints all Markdown documents.)
	$(call help_line,$(PRINT_CONFIG),Prints uncommented Compose YAML.)
	$(call help_line,$(PRINT_ENV),Prints uncommented example env values.)
	$(call help_line,$(RUN),Builds and starts the Compose stack.)
	$(call help_line,$(DOCS_SERVE),Preview documentation with live reload at localhost:8000.)
	$(call help_line,$(DOCS),Build documentation with strict checks and export it to site/.)
	$(call help_line,$(START),Alias for $(RUN).)
	$(call help_line,$(STOP),Alias for $(DOWN).)
	$(call help_line,$(TEST_WORKFLOWS),Tests notifications without contacting Discord.)
	$(call help_line,$(UP),Alias for $(RUN).)
	$(call help_line,$(HELP),Displays this help message.)

#
# Compatibility aliases for established command names.
#
# Dependencies:
#   $(RUN) - Build and start the production Compose stack.
#   $(DOWN) - Stop and remove the complete Compose stack.
#
$(START): $(RUN)
$(STOP): $(DOWN)
$(UP): $(RUN)
