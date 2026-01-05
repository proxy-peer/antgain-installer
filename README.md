# AntGain Installer

One-line installation scripts for AntGain Desktop and CLI.

## Desktop Client Installation

**Auto-install latest version:**
```bash
curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-linux.sh | sudo bash
```

**Install specific version:**
```bash
curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-linux.sh | sudo bash -s 1.0.23
```

### What it does

- ✅ Detects system architecture (x86_64 only)
- ✅ Checks for Debian/Ubuntu-based distribution
- ✅ Fetches latest version from GitHub Release
- ✅ Downloads and installs .deb package
- ✅ Automatically handles dependencies

## CLI Installation

### Quick Install

**Auto-install latest CLI version:**
```bash
curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli.sh | bash
```

**Install specific CLI version:**
```bash
curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli.sh | bash -s 1.0.0
```

### Install as Systemd Service

**One-line with API Key argument:**
```bash
curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli-service.sh | sudo bash -s YOUR_API_KEY
```

**With environment variable:**
```bash
export ANTGAIN_API_KEY=your-api-key
curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli-service.sh | sudo bash
```

**Interactive (will prompt for API Key):**
```bash
curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli-service.sh | sudo bash
```

### What CLI installer does

- ✅ Detects OS (Linux/macOS) and architecture (x86_64/ARM64)
- ✅ Fetches latest CLI version from R2
- ✅ Downloads appropriate binary
- ✅ Installs to /usr/local/bin
- ✅ Makes executable

## Manual Installation

### Desktop
```bash
wget https://github.com/proxy-peer/antgain/releases/latest/download/AntGain_*_linux-x86_64.deb
sudo apt install ./AntGain_*_linux-x86_64.deb
```

### CLI
```bash
# Linux x86_64
wget https://pub-xxx.r2.dev/cli/releases/1.0.0/antgain-linux-amd64.tar.gz
tar xzf antgain-linux-amd64.tar.gz
sudo mv antgain /usr/local/bin/
```

## Requirements

- Ubuntu 22.04+ or Debian-based distribution (Desktop)
- Linux/macOS with x86_64 or ARM64 (CLI)
- `curl` and basic tools

## License

MIT
