#
# Copyright 2026 Scott Gigawatt
#
# Licensed under the Apache License, Version 2.0.
#
# Dockerfile: Build the Plundarrpedia static site and serve it from an
#             unprivileged Nginx runtime image.
#

#
# Default build-stage image and tag that can be overridden using build args.
#
ARG MKDOCS_MATERIAL_IMAGE=squidfunk/mkdocs-material
ARG MKDOCS_MATERIAL_TAG=9.7.7@sha256:51b87149d227691486b5f08993d28c65ca7e4990010664b697265b8e6fcd5287

#
# Default runtime image and tag that can be overridden using build args.
#
ARG NGINX_UNPRIVILEGED_IMAGE=nginxinc/nginx-unprivileged
ARG NGINX_UNPRIVILEGED_TAG=1.31.3-alpine3.24@sha256:334d92979f15aaecd5dd50af5105e1230e2bb70765d45b1e2f964e7c5eda81c3

#
# Use the specified MkDocs Material image as the shared documentation toolchain.
#
FROM ${MKDOCS_MATERIAL_IMAGE}:${MKDOCS_MATERIAL_TAG} AS toolchain

#
# Set the MkDocs project working directory.
#
WORKDIR /docs

#
# Install the exact Python dependencies used by local and Pages builds.
#
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir --requirement requirements.txt

#
# Extend the shared toolchain with the source files needed for a production
# static-site build.
#
FROM toolchain AS build

#
# Copy only the configuration, public content, and theme overrides needed to
# render the production site.
#
COPY mkdocs.yml ./mkdocs.yml
COPY docs ./docs
COPY overrides ./overrides

#
# Build in strict mode so invalid navigation and documentation warnings fail.
#
RUN mkdocs build --strict --site-dir /tmp/site

#
# Expose the generated site as a standalone BuildKit output target.
#
FROM scratch AS site

COPY --from=build /tmp/site /

#
# Use the specified unprivileged Nginx image for the production runtime.
#
FROM ${NGINX_UNPRIVILEGED_IMAGE}:${NGINX_UNPRIVILEGED_TAG} AS runtime

#
# Re-declare the runtime base values so labels can record the exact base image.
#
ARG NGINX_UNPRIVILEGED_IMAGE
ARG NGINX_UNPRIVILEGED_TAG

#
# Image metadata that can be overridden using build args.
#
ARG IMAGE_CREATED=unknown
ARG IMAGE_REVISION=unknown
ARG IMAGE_VERSION=latest

#
# Add Open Container Initiative image labels. Container registries use these to
# link the package to its source, documentation, license, and build revision.
#
LABEL org.opencontainers.image.title="Plundarrpedia" \
      org.opencontainers.image.description="A one-stop wiki for Plundarr, Privateerr, Plex utilities, and self-hosted media automation." \
      org.opencontainers.image.url="https://scottgigawatt.github.io/plundarrpedia/" \
      org.opencontainers.image.documentation="https://scottgigawatt.github.io/plundarrpedia/" \
      org.opencontainers.image.source="https://github.com/scottgigawatt/plundarrpedia" \
      org.opencontainers.image.vendor="Scott Gigawatt" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.base.name="docker.io/${NGINX_UNPRIVILEGED_IMAGE}:${NGINX_UNPRIVILEGED_TAG}"

#
# Copy the hardened server configuration and generated static site.
#
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /tmp/site /usr/share/nginx/html

#
# Document the unprivileged HTTP port used by the Nginx runtime.
#
EXPOSE 8080

#
# Verify the dedicated health endpoint without requiring additional packages.
#
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["wget", "--quiet", "--spider", "http://127.0.0.1:8080/healthz"]

#
# Run Nginx as the unprivileged user supplied by the runtime base image.
#
USER 101
