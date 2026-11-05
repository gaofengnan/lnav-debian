![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/gaofengnan/lnav-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/gaofengnan/lnav-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/gaofengnan/lnav-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/gaofengnan/lnav-debian)

<h1>
   <p align="center">
     <a href="https://lnav.org"><img src="https://github.com/gaofengnan/lnav-debian/blob/main/lnav-logo.svg" alt="lnav Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/gaofengnan/lnav-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>lnav for Debian
   </p>
</h1>
<p align="center">
 lnav, the Logfile Navigator: merge, follow, search and query log files from the terminal.
</p>

# lnav for Debian

> Fork of [dariogriffo/lnav-debian](https://github.com/dariogriffo/lnav-debian) (MIT); the original packaging is by Dario Griffo. Served at [deb.gaofn.xyz](https://deb.gaofn.xyz) for Debian 12 (bookworm) and 13 (trixie).

This repository contains build scripts to produce the _unofficial_ Debian and
Ubuntu packages (.deb) for [lnav](https://github.com/tstack/lnav/) hosted at
[deb.gaofn.xyz](https://deb.gaofn.xyz)

The package and the command are both called `lnav`.

Currently supported distros are:
- Debian Bookworm (v12), Trixie (v13), Forky (v14), Sid
- Ubuntu Jammy (22.04), Noble (24.04), Questing (25.10), Resolute (26.04)

Supported architectures:
- amd64 (x86_64) - All distributions
- arm64 (aarch64) - All distributions

Upstream only publishes Linux builds for these two architectures, so there are
no i386, armhf, armel or riscv64 packages.

One package per architecture is built and shared by every suite
(`lnav_<version>-<build>~griffo_<arch>.deb`). It repackages upstream's
statically linked (musl) build, so it has no runtime dependencies and runs on
every suite above, plus the man page. Upstream ships no shell completions. The
binary's debug info is stripped (it would add about 20 MB); the symbol table is
kept so lnav's crash backtraces still name functions.

`openssh-client` is recommended: lnav runs `ssh` to open logs on a remote host
(`lnav user@host:/var/log/syslog`). `wl-clipboard` or `xclip` is suggested so
lnav can copy to the system clipboard (it also uses tmux's buffer inside tmux).

Every supported suite also ships an older `lnav` in its own archive (0.9.0 on
Jammy up to 0.13.2 on Sid and Resolute). This package has the same name and a
newer version, so apt upgrades it in place.

### Raspberry Pi

A Raspberry Pi 3, 4 or 5 on a 64-bit OS (Raspberry Pi OS 64-bit, Ubuntu) uses
the arm64 package as is; upstream links it for 64K pages, so it also runs on
the Pi 5's 16K-page kernel. On 32-bit Raspberry Pi OS with a 64-bit kernel
(`uname -m` prints `aarch64`), the static binary still runs:
`sudo dpkg --add-architecture arm64 && sudo apt update && sudo apt install lnav:arm64`
(the recommended `openssh-client` stays native, it is `Multi-Arch: foreign`).
A 32-bit kernel (`armv7l`/`armv6l`, or a Pi Zero/1/2) can't run it; use
Raspbian's own `lnav` there.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the lnav source code, see
[lnav](https://github.com/tstack/lnav/).

## Install/Update

### The Debian way

```sh
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSL https://deb.gaofn.xyz/deb.gaofn.xyz.gpg -o /etc/apt/keyrings/deb.gaofn.xyz.gpg
sudo curl -fsSL https://deb.gaofn.xyz/deb.gaofn.xyz.sources -o /etc/apt/sources.list.d/deb.gaofn.xyz.sources
# Debian 12 (bookworm): fetch deb.gaofn.xyz-bookworm.sources instead
sudo apt update
sudo apt install -y lnav
```

### Manual Installation

1. Download the .deb package for your architecture available on
   the [Releases](https://github.com/gaofengnan/lnav-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <lnav_version> <build_version> <architecture>
# Example: ./build.sh 0.14.1 1 arm64
```

### Build for all architectures
```sh
./build.sh <lnav_version> <build_version> all
# Example: ./build.sh 0.14.1 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64)

## Disclaimer

- This repo is not open for issues related to lnav. This repo is only for _unofficial_ Debian packaging.
