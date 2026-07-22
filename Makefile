#
# Copyright 2026 Scott Gigawatt
#
# Licensed under the Apache License, Version 2.0.
#
# Makefile: Automation for building, previewing, validating, and running
#           Plundarrpedia with Docker and Docker Compose.
#

#
# Makefile target names.
#
ALL=all
BUILD=build
BUILD_DEPENDS=build-depends
BUILD_MULTIARCH=build-multiarch
CHECK_ENV=check-env
CLEAN=clean
CONFIG=config
DOWN=down
ENV=env
HELP=help
LINT=lint
LOGS=logs
MARKDOWN=markdown
PRINT_CONFIG=print-config
PRINT_ENV=print-env
SERVE=serve
SITE=site
START=start
STOP=stop
UP=up

TARGETS= \
	$(ALL) \
	$(BUILD) \
	$(BUILD_DEPENDS) \
	$(BUILD_MULTIARCH) \
	$(CHECK_ENV) \
	$(CLEAN) \
	$(CONFIG) \
	$(DOWN) \
	$(ENV) \
	$(HELP) \
	$(LINT) \
	$(LOGS) \
	$(MARKDOWN) \
	$(PRINT_CONFIG) \
	$(PRINT_ENV) \
	$(SERVE) \
	$(SITE) \
	$(START) \
	$(STOP) \
	$(UP)

#
# Plundarrpedia service name.
#
PLUNDARRPEDIA_SERVICE ?= plundarrpedia

#
# Docker Compose options.
#
COMPOSE_FILE          ?= docker-compose.yml
COMPOSE_ENV_FILE      ?= $(ENV_FILE)
COMPOSE_DOWN_OPTIONS  ?= --remove-orphans
COMPOSE_BUILD_OPTIONS ?= --pull --no-cache
COMPOSE_UP_OPTIONS    ?= --build --detach --force-recreate --remove-orphans
COMPOSE_LOGS_OPTIONS  ?= --follow

#
# Docker build settings.
#
DOCKERFILE              ?= docker/Dockerfile
DOCKER_BUILD_CONTEXT     ?= .
BUILDX_PLATFORM_OPTIONS  ?= --platform linux/amd64,linux/arm64,linux/arm/v7
BUILDX_BUILD_OPTIONS     ?= --pull --no-cache
BUILDX_IMAGE_TAG         ?= ghcr.io/scottgigawatt/plundarrpedia:multiarch-local
SITE_OUTPUT_PATH         ?= site

#
# Authoring server settings.
#
MKDOCS_AUTHOR_PORT ?= 8000
MKDOCS_IMAGE       ?= squidfunk/mkdocs-material:9.7.7

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
# Help line formatting function.
#
define help_line
	@printf "  %-22s %s\n" "$(1)" "$(2)"
endef

#
# Verify Docker Compose availability.
#
ifeq ($(DOCKER_COMPOSE),)
    $(error "Neither 'docker compose' nor 'docker-compose' is available. \
        Please install Docker Compose.")
endif

#
# Build dependencies.
#
DEPENDENCIES=docker
LINT_DEPENDENCIES=pre-commit

#
# Environment file paths.
#
ENV_FILE=.env
EXAMPLE_ENV_FILE=example.env

#
# Targets that are not files (i.e. never up-to-date); these will run every
# time the target is called or required.
#
.PHONY: $(TARGETS)

#
# $(ALL): Default Makefile target. Builds the production image.
#
# Dependencies:
#   $(BUILD) - Build the production Plundarrpedia image.
#
$(ALL): $(BUILD)

#
# $(BUILD_DEPENDS): Ensure build and validation dependencies are installed.
#
$(BUILD_DEPENDS):
	$(foreach exe,$(DEPENDENCIES), \
		$(if $(shell which $(exe) 2> /dev/null),,$(error "No $(exe) in PATH")))
	@# Verify Docker Compose availability.
	@$(DOCKER_COMPOSE) version >/dev/null 2>&1 || { \
		echo "Docker Compose is not available."; \
		echo "Install docker compose or docker-compose."; \
		exit 1; \
	}

#
# $(CHECK_ENV): Ensure .env exists before running Compose commands.
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
# $(BUILD): Build only the production Plundarrpedia image.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure build dependencies are installed.
#   $(CHECK_ENV) - Ensure .env exists before running Compose commands.
#
$(BUILD): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nBuilding the Plundarrpedia image. ⚒️"
	$(DOCKER_COMPOSE) --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE) build \
		$(COMPOSE_BUILD_OPTIONS) \
		$(PLUNDARRPEDIA_SERVICE)

#
# $(BUILD_MULTIARCH): Verify the image builds for all published platforms.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure build dependencies are installed.
#   $(CHECK_ENV) - Ensure .env exists before reading build arguments.
#
$(BUILD_MULTIARCH): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nVerifying multi-architecture builds for amd64, arm64, and arm/v7. 🧭"
	@set -a; \
	. ./$(COMPOSE_ENV_FILE); \
	set +a; \
	docker buildx build $(BUILDX_BUILD_OPTIONS) $(BUILDX_PLATFORM_OPTIONS) \
		--build-arg MKDOCS_MATERIAL_IMAGE="$${MKDOCS_MATERIAL_IMAGE}" \
		--build-arg MKDOCS_MATERIAL_TAG="$${MKDOCS_MATERIAL_TAG}" \
		--build-arg NGINX_UNPRIVILEGED_IMAGE="$${NGINX_UNPRIVILEGED_IMAGE}" \
		--build-arg NGINX_UNPRIVILEGED_TAG="$${NGINX_UNPRIVILEGED_TAG}" \
		--tag $(BUILDX_IMAGE_TAG) \
		--file $(DOCKERFILE) \
		$(DOCKER_BUILD_CONTEXT)

#
# $(SITE): Build the strict static site into the local site directory.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker is installed.
#   $(CHECK_ENV) - Ensure .env exists before reading build arguments.
#
$(SITE): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nRendering the static Plundarrpedia site. 🗺️"
	@set -a; \
	. ./$(COMPOSE_ENV_FILE); \
	set +a; \
	docker build $(COMPOSE_BUILD_OPTIONS) \
		--build-arg MKDOCS_MATERIAL_IMAGE="$${MKDOCS_MATERIAL_IMAGE}" \
		--build-arg MKDOCS_MATERIAL_TAG="$${MKDOCS_MATERIAL_TAG}" \
		--target site \
		--output type=local,dest=$(SITE_OUTPUT_PATH) \
		--file $(DOCKERFILE) \
		$(DOCKER_BUILD_CONTEXT)

#
# $(SERVE): Run the live-reload MkDocs authoring server.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker is installed.
#
$(SERVE): $(BUILD_DEPENDS)
	@echo "\nStarting the authoring server on port $(MKDOCS_AUTHOR_PORT). 📚"
	docker run --rm --interactive --tty \
		--publish $(MKDOCS_AUTHOR_PORT):8000 \
		--volume "$(CURDIR):/docs" \
		$(MKDOCS_IMAGE)

#
# $(MARKDOWN): Lint every Markdown document with the shared repository rules.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure pre-commit is installed.
#
$(MARKDOWN): $(BUILD_DEPENDS)
	@echo "\nLinting Markdown files. 📝"
	$(foreach exe,$(LINT_DEPENDENCIES), \
		$(if $(shell which $(exe) 2> /dev/null),,$(error "No $(exe) in PATH")))
	pre-commit run markdownlint-cli2 --all-files

#
# $(LINT): Run all repository lint and policy checks.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure pre-commit is installed.
#
$(LINT): $(BUILD_DEPENDS)
	@echo "\nRunning repository validation hooks. 🔎"
	$(foreach exe,$(LINT_DEPENDENCIES), \
		$(if $(shell which $(exe) 2> /dev/null),,$(error "No $(exe) in PATH")))
	pre-commit run --all-files

#
# $(CONFIG): Render the Docker Compose model.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker Compose is installed.
#   $(CHECK_ENV) - Ensure .env exists before running Compose commands.
#
$(CONFIG): $(BUILD_DEPENDS) $(CHECK_ENV)
	$(DOCKER_COMPOSE) --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE) config

#
# $(ENV): Print the environment used to interpolate the Compose model.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker Compose is installed.
#   $(CHECK_ENV) - Ensure .env exists before running Compose commands.
#
$(ENV): $(BUILD_DEPENDS) $(CHECK_ENV)
	$(DOCKER_COMPOSE) --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE) \
		config --environment

#
# $(PRINT_CONFIG): Print the raw uncommented Docker Compose configuration.
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
# $(UP): Build, recreate, and start Plundarrpedia.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure build dependencies are installed.
#   $(CHECK_ENV) - Ensure .env exists before running Compose commands.
#
$(UP): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nBuilding and starting Plundarrpedia. 🚀"
	$(DOCKER_COMPOSE) --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE) up \
		$(COMPOSE_UP_OPTIONS)

#
# $(DOWN): Stop and remove the Plundarrpedia service stack.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker Compose is installed.
#   $(CHECK_ENV) - Ensure .env exists before running Compose commands.
#
$(DOWN): $(BUILD_DEPENDS) $(CHECK_ENV)
	@echo "\nStopping the Plundarrpedia service stack. ⚓"
	$(DOCKER_COMPOSE) --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE) down \
		$(COMPOSE_DOWN_OPTIONS)

#
# $(LOGS): View output from the Plundarrpedia container.
#
# Dependencies:
#   $(CHECK_ENV) - Ensure .env exists before running Compose commands.
#
$(LOGS): $(CHECK_ENV)
	@echo "\nShowing Plundarrpedia logs. 🔎"
	$(DOCKER_COMPOSE) --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE) logs \
		$(COMPOSE_LOGS_OPTIONS)

#
# $(HELP): Print help information.
#
$(HELP):
	@echo "Usage: make [TARGET]"
	@echo ""
	@echo "Targets:"
	$(call help_line,$(ALL),Builds the production Plundarrpedia image.)
	$(call help_line,$(BUILD),Builds only the production image.)
	$(call help_line,$(BUILD_DEPENDS),Ensures required tools are installed.)
	$(call help_line,$(BUILD_MULTIARCH),Verifies amd64/arm64/arm/v7 builds.)
	$(call help_line,$(CHECK_ENV),Ensures .env exists.)
	$(call help_line,$(CLEAN),Stops the local Plundarrpedia service.)
	$(call help_line,$(CONFIG),Renders the Docker Compose model.)
	$(call help_line,$(DOWN),Stops and removes the service.)
	$(call help_line,$(ENV),Prints Compose interpolation values.)
	$(call help_line,$(LINT),Runs all pre-commit validation hooks.)
	$(call help_line,$(LOGS),Shows Plundarrpedia logs.)
	$(call help_line,$(MARKDOWN),Lints all Markdown documents.)
	$(call help_line,$(PRINT_CONFIG),Prints uncommented Compose YAML.)
	$(call help_line,$(PRINT_ENV),Prints uncommented example env values.)
	$(call help_line,$(SERVE),Starts the live-reload authoring server.)
	$(call help_line,$(SITE),Builds the strict static site locally.)
	$(call help_line,$(START),Alias for $(UP).)
	$(call help_line,$(STOP),Alias for $(DOWN).)
	$(call help_line,$(UP),Builds and starts Plundarrpedia.)
	$(call help_line,$(HELP),Displays this help message.)

#
# $(CLEAN): Alias for down.
#
# Dependencies:
#   $(DOWN) - Stop and remove the service.
#
$(CLEAN): $(DOWN)

#
# $(START): Alias for up.
#
# Dependencies:
#   $(UP) - Build and start Plundarrpedia.
#
$(START): $(UP)

#
# $(STOP): Alias for down.
#
# Dependencies:
#   $(DOWN) - Stop and remove Plundarrpedia.
#
$(STOP): $(DOWN)
