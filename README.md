# AntGain Installer

One-line installation script for AntGain Linux.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-linux.sh | sudo bash
```

## What it does

- ✅ Detects system architecture (x86_64 only)
- ✅ Checks for Debian/Ubuntu-based distribution
- ✅ Fetches latest version from GitHub Release
- ✅ Downloads and installs .deb package
- ✅ Automatically handles dependencies

## Manual Installation

Download the latest release:
```bash
wget https://github.com/proxy-peer/antgain/releases/latest/download/AntGain_*_linux-x86_64.deb
sudo apt install ./AntGain_*_linux-x86_64.deb
```

## Requirements

- Ubuntu 22.04+ or Debian-based distribution
- x86_64 architecture
- `curl` and `apt-get`

## License

MIT
