---
title: Homepage Login
description: Configure the generated dashboard password, browser URL, reverse proxy, and session recovery.
icon: material/view-dashboard
status: new
---

# Sign in to Homepage

Plundarr enables Homepage's native shared-password login whenever Homepage is selected. It requires Homepage v2 or later. Maraudarr generates a unique password and session secret in `dist/<preset>/.env`, including when those settings are first added to an older deployment. Your dashboard now has a doorbell. 🔐

## Configure the browser address

Review these values before launch:

| Setting | Purpose |
| --- | --- |
| `HOMEPAGE_AUTH_ENABLED` | Keep `true` to enable the native login. |
| `HOMEPAGE_AUTH_PASSWORD` | Generated shared password; read it locally from `.env`. No username is required. |
| `HOMEPAGE_AUTH_SECRET` | Generated session secret; keep it private alongside the password. |
| `HOMEPAGE_EXTERNAL_URL` | Exact browser URL, including scheme and any nonstandard port. |
| `HOMEPAGE_ALLOWED_HOSTS` | Matching hostname and optional port, without the scheme. |
| `HOMEPAGE_WEBUI_PORT` | Published HTTP port used directly on a trusted network or by your reverse proxy. |

For an HTTPS proxy, use an external URL such as `https://homepage.example.com` and allowed host `homepage.example.com`. Configure the proxy and certificate separately; forward to the generated HTTP port and preserve the original host and forwarded HTTPS scheme. Restrict direct backend access to trusted networks. For direct LAN access, use the actual HTTP address and port in both settings, omitting only the scheme from allowed hosts.

Recreate Homepage after changing `.env`; restarting a container does not reload its environment. From the Plundarr repository root, for the default preset:

```sh
docker compose --project-directory dist/plundarr up -d --force-recreate homepage
```

Substitute your preset directory when necessary. In Synology Container Manager, apply the changed project configuration and recreate the service. Open the configured external URL and sign in with the generated password; `example.env` contains empty secret placeholders and cannot supply a working login.

## Rotate a password or recover access

Read the current password locally from the deployment `.env`. Existing passwords, session secrets, and URL settings survive regeneration. To change the password and invalidate existing sessions, replace both `HOMEPAGE_AUTH_PASSWORD` and `HOMEPAGE_AUTH_SECRET`, then recreate Homepage. Use a strong unique password and a random session secret of at least 32 characters.

> [!IMPORTANT]
> Native login uses one shared password and does not rate-limit attempts itself. Protect public access with appropriate proxy authentication/rate limiting or a VPN. Never paste the generated password, session secret, or complete `.env` into a support request.

A healthy container does not prove that your browser URL or login is configured correctly: the healthcheck deliberately uses the public `/api/healthcheck` endpoint.

## Preserve dashboard customization

Regeneration rebuilds `config/homepage/services.yaml` from the selected service fragments. Keep card customizations in the generator's source fragments and rebuild your customized Maraudarr image if they must survive regeneration. Existing `settings.yaml` is preserved. Browser links use `HOMEPAGE_VAR_*_HREF`; widget API requests use `HOMEPAGE_VAR_*_URL` reachable from inside Docker.

[Return to stack configuration](configuration.md){ .md-button }
