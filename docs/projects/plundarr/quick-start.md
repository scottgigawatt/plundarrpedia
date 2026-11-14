---
title: Plundarr quick start
description: Choose services interactively with the published Maraudarr image, then configure and start Plundarr.
icon: material/rocket-launch
---

# Generate and start Plundarr

Maraudarr's interactive terminal helps you choose services and generates your Plundarr project. You edit its settings, then start the stack with Docker Compose. No Git, Make, or local image build is needed for this route.

## Before you start

You need Docker with Compose v2, an amd64 or arm64 host, and an active PIA subscription for the default preset. Choose persistent host directories for downloads and media, and the host user/group that should own them. For NAS deployment, review the [platform requirements](../../guides/index.md).

The default preset includes automation and download services, a dashboard, and ebooks. Plex and Jellyfin are optional additions. Applications still need their own first-run setup after the containers start.

Watchtower is selected by default and can update eligible containers across this Docker host, including other projects. Run only one persistent Watchtower per host. Deselect it in the picker if you already use one or prefer manual updates; [review its update policy](../presets/watchtower.md#run-the-persistent-preset) before launch.

![Maraudarr's interactive service picker generates the default Plundarr project](https://raw.githubusercontent.com/scottgigawatt/plundarr/main/docs/assets/maraudarr-demo.gif)

🔎 [View the full-size demo](https://raw.githubusercontent.com/scottgigawatt/plundarr/main/docs/assets/maraudarr-demo.gif).

## 1. Open the interactive generator

Run these commands in a new directory. Keep an existing deployment's files and settings; use the [update guide](upgrading.md) when regenerating it.

```sh
mkdir -p plundarr
cd plundarr
docker run --rm -it --pull always \
  --user "$(id -u):$(id -g)" \
  --read-only --network none \
  --cap-drop ALL --security-opt no-new-privileges:true \
  --tmpfs /tmp:rw,noexec,nosuid,size=64m \
  --volume "$PWD:/output:rw" \
  ghcr.io/scottgigawatt/maraudarr:latest configure
```

Choose **Plundarr**, review the preselected services, and confirm generation. Use the arrow keys to move, **Space** to select services, and **Enter** to continue. Maraudarr exits when the files are ready; it does not start the selected applications.

Your project is in `dist/plundarr/`: `docker-compose.yml`, `.env`, `example.env`, and `config/`. Container output paths beginning `/output/` correspond to the directory you mounted above.

## 2. Edit the generated settings

Enter the generated project, then open `.env` in a text editor:

```sh
cd dist/plundarr
```

Search for `Edit before launch:`, `Edit for your host:`, and host-port comments. Keep generated passwords and keys private; `example.env` is a reference and has no working generated secrets.

| Review | What to change |
| --- | --- |
| `PIA_USER`, `PIA_PASS` | Your PIA VPN username and password; the username is `p` or `P` followed by seven digits, not your email |
| `DEFAULT_PUID`, `DEFAULT_PGID`, `DEFAULT_GROUP` | The numeric host user and groups with access to your folders; obtain them with `id` |
| Host media/download paths | Real absolute paths on the machine that will run the stack; replace `/volume1/...` examples where needed |
| `TZ`, `COMPOSE_NETWORK_*`, `*_WEBUI_PORT` | Your timezone and available network/host ports |
| `HOMEPAGE_EXTERNAL_URL`, `HOMEPAGE_ALLOWED_HOSTS` | The browser URL and matching hostname/port without its scheme; see [Homepage login](homepage.md) |

For Calibre-Web Automated, set `CWA_CONFIG_PATH`, `CWA_INGEST_PATH`, and `CWA_LIBRARY_PATH` to three separate writable host directories. Books are removed from ingest after processing; keep originals and ongoing downloads elsewhere. A new library can use an empty directory, which CWA initializes automatically, or you can select an existing Calibre library. See [ebook folder setup](../presets/media-servers-and-books.md#calibre-web-automated).

Maraudarr generates the shared recovery key and Homepage password. Keep automatic recovery enabled for the default stack. [Configuration](configuration.md) explains optional region selection and service settings.

## 3. Validate and start

From the generated `dist/plundarr/` directory, validate without printing passwords:

```sh
docker compose config --quiet
```

Success produces no output. Fix any reported setting before continuing. This checks Compose syntax and required values; folder permissions and live connections are checked after startup.

For Synology or TrueNAS, transfer this complete project directory and continue with [your platform's deployment steps](../../guides/index.md). Start only one copy. For Docker Compose on this host:

```sh
docker compose up --detach --pull always
docker compose ps
```

Image downloads can take several minutes. Check that Privateerr is ready, Gluetun is healthy, and qBittorrent is running. Inspect locally if needed:

```sh
docker compose logs --tail 100 privateerr gluetun qbittorrent
```

Look for `Automatic recovery enabled` and `Gluetun tunnel is healthy` in Privateerr's logs. Keep logs, `.env`, and VPN files private. Use [troubleshooting](troubleshooting.md) for the first failing service.

## 4. Open your applications

Use the machine running Docker as `YOUR-HOST`, or `localhost` when it is this computer. Use the ports from your `.env` if you changed them.

| Application | Default browser address | First action |
| --- | --- | --- |
| Homepage | Your `HOMEPAGE_EXTERNAL_URL` | Sign in with `HOMEPAGE_AUTH_PASSWORD` from `.env`; no username |
| qBittorrent | `http://YOUR-HOST:8080` | Read the initial password locally in qBittorrent's logs, sign in as `admin`, and change it |
| Prowlarr | `http://YOUR-HOST:9696` | Complete initial authentication setup |
| Radarr / Sonarr | `http://YOUR-HOST:7878` / `http://YOUR-HOST:8989` | Complete initial authentication setup |

You have reached the first milestone when these UIs open and the VPN is healthy. Next, [connect your applications](connect-applications.md) so requests, downloads, and imports work together. Configure [Tracearr monitoring](monitoring.md) and other optional integrations afterward.

To stop the project while retaining settings and data:

```sh
docker compose down
```

## Use repository helpers later

Git and Make provide shortcuts for generation and maintenance. From a directory outside the project folder above:

```sh
git clone https://github.com/scottgigawatt/plundarr.git plundarr-source
cd plundarr-source
make pull-image
make configure
```

This generates a separate project under that checkout's `dist/`. Do not start another copy against the same application data. To manage the project you already generated, keep using its Compose commands. See [command reference](../../reference/commands.md) for Make equivalents and [developer documentation](https://scottgigawatt.github.io/plundarr/development/maraudarr/) when you want to build your own generator.
