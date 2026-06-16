# silverstripe-dev-machine

## tldr;

step 1: install https://ubuntu.com/tutorials/install-ubuntu-desktop

step 2: follow [script](install.sh)

## Background

A Bash provisioning script (`install.sh`) that sets up a fresh **Ubuntu** workstation for **Silverstripe** web development. It runs a sequence of `apt` / `snap` / `composer` installs, each announced with a `print_header` banner.

> ⚠️ **Read this before running**
>
> - The script is **not idempotent** — re-running it appends duplicate lines to `~/.bashrc`, re-adds `/etc/hosts` entries, etc.
> - The `snap_refresh` helper calls **`reboot`**. It is invoked several times mid-script, so the script **will not finish in a single pass** — you'll need to comment those out or re-run after each reboot.
> - MariaDB root password is hardcoded as **`x`** (local-dev only — never expose this machine).
> - Timezone is hardcoded to **`Pacific/Auckland`**.
> - Several `git clone` steps use `git@github.com:` (SSH), so your SSH key must already be added to GitHub or those steps fail.
> - Targets **PHP 8.3** as the default version.

---

## What gets installed

### System & helpers
| Item | Source | Notes |
|------|--------|-------|
| apt update | `apt` | Run repeatedly between steps |
| GNOME keyring | `apt` | `gnome-keyring`, `libsecret-1-0`, `libsecret-1-dev`, `seahorse` — needed for VS Code secret storage |
| snapd | `apt` | Required for the snap installs below |

### Desktop applications
| App | Source |
|-----|--------|
| VS Code | snap (`--classic`) |
| Google Chrome | `.deb` from Google |
| Slack | snap |
| GIMP | PPA (`otto-kesselgulasch/gimp`) **and** snap edge channel |
| Meld | apt — used as the Git merge tool |

### Git
- Installs `git` and `curl`.
- Global config applied:
  - `core.filemode false`
  - Rewrites `https://github.com/` → `git@github.com:`
  - Rewrites `https://bitbucket.org/` → `git@bitbucket.org:`

### Node.js
| Item | Source | Notes |
|------|--------|-------|
| nodejs, npm | apt | Distro versions |
| nvm | install script (v0.40.1) | Adds `nvm use node` to `~/.bashrc` |
| node (latest) | nvm | |

### Web stack — the Silverstripe core

**Apache2**
- Sets `ServerName localhost`.
- Downloads `sites-enabled.conf` from this repo into `/etc/apache2/sites-available/silverstripe-dev-machine.conf` and enables the site.
- Enables modules: `rewrite`, `vhost_alias`, `access_compat`, `proxy`, `headers`, `proxy_http`.

**MariaDB**
- Installed and enabled.
- Forced to listen on `127.0.0.1` only (`bind-address` in `50-server.cnf`).
- Root password set to `x`; handles the `unix_socket` → `mysql_native_password` switch.
- Loads timezone tables (`mysql_tzinfo_to_sql`).

**PHP**
- `libapache2-mod-php8.3`.
- Installs the author's [`silverstripe-switch-php-versions`](https://github.com/sunnysideup/silverstripe-switch-php-versions) tool, then runs `php-switch 8.3`.
- Sets `date.timezone = 'Pacific/Auckland'` across PHP **7.0, 7.2, 7.4, 8.0, 8.1, 8.3**.
- Turns `display_errors` and `display_startup_errors` **On** in every `php.ini`.

**Composer**
- Installed via apt **and** a manual, hash-verified install to `/usr/local/bin/composer`.
- Global config: `preferred-install source`, `github-protocols ssh`.

### Silverstripe-specific tooling
| Tool | Purpose |
|------|---------|
| [`silverstripe-upgrade-silverstripe`](https://github.com/sunnysideup/silverstripe-upgrade-silverstripe) | Cloned into `/var/www/upgrader`, deps installed |
| `sunnysideup/easy-coding-standards` | Linter, installed globally (dev-master) |
| SSPak | DB/asset backup tool → `/usr/local/bin` |
| SSBak | Go-based SSPak alternative → `/usr/local/bin` |

### Folder structure
Creates these under `/var/www`, chowns `/var/www` to `$USER:www-data`, and symlinks each into root (e.g. `/ss5`):

```
ss3  ss4  ss5  craft  wp  upgrader  upgrades
```

Then spins up a test Silverstripe project:
- Adds `127.0.0.1 test.ss4` to `/etc/hosts`
- Runs `composer create-project silverstripe/installer test` in `/var/www/ss4`
- Runs `sake installsake`

### Security & lint tooling
| Tool | Source |
|------|--------|
| semgrep | pipx |
| gitleaks | latest GitHub release |
| Go | snap (`--classic`) |
| shfmt | apt |

### Final manual steps
- Generates an SSH key (`ssh-keygen`).
- Opens `~/.ssh/config` in `nano` for you to add aliases.

---

## Path additions to `~/.bashrc`
The script appends Composer's global bin to your `PATH` (done redundantly in a few places):

```bash
PATH=~/.config/composer/vendor/bin:$PATH
# and/or
export PATH="$HOME/.composer/vendor/bin:$PATH"
```

---

## Summary of helper functions
- **`print_header "$1" "$2"`** — prints a banner with an optional reference URL.
- **`snap_refresh`** — restarts snapd/udevd, runs `snap refresh`, then **reboots**.
