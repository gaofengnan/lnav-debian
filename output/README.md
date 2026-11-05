<div align="center">

# lnav

> Fork of [dariogriffo/lnav-debian](https://github.com/dariogriffo/lnav-debian) (MIT); the original packaging is by Dario Griffo. Served at [deb.gaofn.xyz](https://deb.gaofn.xyz) for Debian 12 (bookworm) and 13 (trixie).

**The Logfile Navigator.**

![GitHub Release](https://img.shields.io/github/v/release/tstack/lnav?display_name=tag&color=%23a6a)
![GitHub License](https://img.shields.io/github/license/tstack/lnav)

</div>

## About

lnav is a log file viewer for the terminal. Point it at a directory or a set
of files and it merges them into one view ordered by timestamp, so you can
read what happened across services without juggling `tail` windows.

It detects common formats on its own (syslog, journald, Apache and nginx
access logs, JSON lines and many more), highlights errors and warnings, keeps
following files as they grow, opens compressed files and archives, and lets
you filter, search and query the messages with SQL.

Run `lnav /var/log` to start, or `journalctl -o json | lnav` to read the
journal. `lnav user@host:/var/log/syslog` opens logs on a remote host over
ssh (needs `openssh-client`). Press `?` inside lnav for the built-in help and
`man lnav` for the command-line reference.

**[Read the documentation](https://docs.lnav.org)**
