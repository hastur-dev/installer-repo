# Installer Repo

Cross-platform installation and verification system for third-party applications. This project provides a framework for creating, testing, and running install scripts across Windows, Linux, and macOS.

## Overview

This system provides:
- **Install scripts** (`install-{os}`) - Install applications using native package managers
- **Run scripts** (`run-{os}`) - Verify installations and run smoke tests
- **Uninstall scripts** (`uninstall-{os}`) - Remove applications cleanly
- **Docker containers** - Isolated testing environments
- **GitHub Actions CI** - Automated testing on all platforms

## Repository Structure

```
installer-repo/
├── .github/
│   └── workflows/
│       └── test-installers.yml    # CI workflow for all platforms
├── docker/
│   ├── Dockerfile.linux           # Ubuntu-based container
│   ├── Dockerfile.linux-fedora    # Fedora-based container
│   └── Dockerfile.linux-alpine    # Alpine-based container
├── scripts/
│   ├── run_all.sh                 # Master test runner (POSIX)
│   └── run_all.ps1                # Master test runner (Windows)
├── tests/
│   ├── test_scripts.sh            # Shell script tests
│   ├── test_scripts.ps1           # PowerShell script tests
│   └── test_docker_integration.sh # Docker integration tests
├── docker-compose.yml             # Container orchestration
├── README.md                      # This file
└── DEPENDENCIES.md                # Required dependencies
```

## Quick Start

### Prerequisites

- **Linux/macOS**: Bash 4.0+, Docker (optional)
- **Windows**: PowerShell 5.1+, Docker Desktop (optional)

### Running Install Scripts

**Linux:**
```bash
chmod +x vim/install-linux.sh
sudo ./vim/install-linux.sh
./vim/run-linux.sh
```

**macOS:**
```bash
chmod +x vim/install-macos.sh
./vim/install-macos.sh
./vim/run-macos.sh
```

**Windows (PowerShell as Administrator):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\vim\install-windows.ps1
.\vim\run-windows.ps1
```

### Uninstalling

**Linux:**
```bash
sudo ./vim/uninstall-linux.sh
```

**macOS:**
```bash
./vim/uninstall-macos.sh
```

**Windows:**
```powershell
.\vim\uninstall-windows.ps1
```

### Docker Testing

Build and run containers:

```bash
# Build all containers
docker-compose build

# Run Linux install test
docker run --rm install-linux

# Run Fedora install test
docker run --rm install-linux-fedora
```

### Running All Tests

**POSIX (Linux/macOS):**
```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

**Windows:**
```powershell
.\scripts\run_all.ps1
```

## Script Naming Convention

Each application has its own directory (e.g., `vim/`) containing scripts with consistent naming:

| Script | Purpose |
|--------|---------|
| `install-linux.sh` | Install on Linux (apt/dnf/yum/pacman) |
| `install-macos.sh` | Install on macOS (Homebrew) |
| `install-windows.ps1` | Install on Windows (winget/chocolatey) |
| `run-linux.sh` | Verify Linux installation |
| `run-macos.sh` | Verify macOS installation |
| `run-windows.ps1` | Verify Windows installation |
| `uninstall-linux.sh` | Uninstall on Linux |
| `uninstall-macos.sh` | Uninstall on macOS |
| `uninstall-windows.ps1` | Uninstall on Windows |

## Docker Container Names

| Image Name | Base OS | Package Manager |
|------------|---------|-----------------|
| `install-linux` | Ubuntu 22.04 | apt-get |
| `install-linux-fedora` | Fedora 39 | dnf |
| `install-linux-alpine` | Alpine 3.19 | apk |

## Adding New Applications

To add a new application:

1. Create a new directory with the application name (e.g., `neovim/`)
2. Add scripts following the naming pattern:
   - `install-linux.sh`, `install-macos.sh`, `install-windows.ps1`
   - `run-linux.sh`, `run-macos.sh`, `run-windows.ps1`
   - `uninstall-linux.sh`, `uninstall-macos.sh`, `uninstall-windows.ps1`
3. Test locally with `scripts/run_all.*`
4. Push to trigger CI tests

## CI/CD

GitHub Actions automatically tests on:
- **Ubuntu** (via Docker container)
- **macOS** (native runner)
- **Windows** (native runner)

Workflow triggers:
- Push to `main` or `develop`
- Pull requests to `main`
- Manual dispatch

## Troubleshooting

### Linux: Package manager not found
Ensure you're running on a supported distribution (Debian/Ubuntu, Fedora/RHEL, Arch).

### macOS: Homebrew not installing
Run manually: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### Windows: winget not available
Install from Microsoft Store or use Chocolatey fallback.

### Docker: Permission denied
Add your user to the docker group: `sudo usermod -aG docker $USER`

## Architecture Notes

- All scripts use bounded loops with explicit iteration limits
- Error handling includes retry logic with configurable attempts
- Scripts are idempotent (can run multiple times safely)
- Logging follows consistent format: `[LEVEL] script: message`

## License

See LICENSE file for details.
