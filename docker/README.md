<!--
  Copyright 2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  README.md: Production image design and local runtime examples.
-->

# Plundarrpedia image

The production image uses a multi-stage build:

1. Material for MkDocs builds the static site with `--strict`.
2. An unprivileged Nginx runtime serves only the generated output on port 8080.

The runtime is read-only compatible, drops Linux capabilities in Compose, runs
as the unprivileged user supplied by the base image, and contains no Python
toolchain or wiki source files.

```console
docker build -t plundarrpedia:local -f docker/Dockerfile .
docker run --rm -p 8000:8080 --read-only --tmpfs /tmp plundarrpedia:local
```

The base image repositories, pinned tags, OCI metadata, and runtime resource
settings can be overridden through `example.env` and Compose. The Dockerfile
keeps matching defaults so direct `docker build` remains usable.
