---
title: Glossary
description: Plain-language definitions for common media automation and container terms.
icon: material/book-alphabet
---

# Glossary

Compose project
: A set of services, networks, and volumes described by Docker Compose and
  grouped under one project name.

Container path
: A path as seen inside a container. It may map to a differently named absolute
  path on the host.

Gluetun
: A containerized VPN client. In this ecosystem it consumes Privateerr's custom
  WireGuard output, establishes the tunnel, and manages PIA port forwarding.

Hardlink
: A second directory entry for the same file data. Media managers can hardlink
  completed downloads into a library without consuming a second file's worth of
  storage, provided source and destination share a filesystem.

Healthcheck
: A command Docker runs to decide whether a container's application has reached
  a usable state. "Running" and "healthy" are not synonyms.

IPAM
: IP Address Management. Compose IPAM settings select the subnet, allocation
  range, and gateway for a custom network.

Maraudarr
: The short-lived generator image/application that creates a complete Plundarr
  deployment.

OPDS
: An open catalog format used by ebook servers and reading clients.

PIA
: Private Internet Access, the VPN provider whose official manual connection
  scripts are packaged by Privateerr.

PUID / PGID
: Numeric user and group IDs passed to many Linux container images so files are
  created with useful host ownership.

Privateerr
: A configuration generator, not a VPN client. It writes PIA WireGuard and
  endpoint metadata files.

Reverse proxy
: A front-end HTTP service that terminates connections and forwards them to an
  internal application, often adding TLS and a friendly hostname.

SBOM
: Software Bill of Materials: an inventory of packages/components attached to a
  build for supply-chain visibility.

WireGuard
: A VPN protocol and implementation. `wg0.conf` is the conventional interface
  configuration filename used in these projects.
