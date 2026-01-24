# QMK Firmware Installation for macOS (Apple Silicon)

A comprehensive, one-command installation script for QMK firmware development on macOS systems with Apple Silicon (M1/M2/M3).

## Quick Start

```bash
# Download and run the installation script
bash qmk_install.sh
```

That's it! The script will:
- ✅ Install QMK CLI (via pipx)
- ✅ Install all required toolchains and dependencies
- ✅ Configure your PATH automatically
- ✅ Verify the installation

## What Gets Installed

### QMK CLI
- **qmk** - QMK command-line interface (installed via pipx)

### Toolchains
- **arm-none-eabi-gcc** - ARM embedded toolchain (version 13.x)
- **avr-gcc** - AVR toolchain (version 8.x)

### Utilities
- **avrdude** - AVR programmer/flasher
- **dfu-util** - DFU (Device Firmware Update) utility
- **dfu-programmer** - DFU programmer tool
- **dos2unix** - Text file converter

## Prerequisites

- **macOS** (tested on macOS 15.x with Apple Silicon)
- **Homebrew** - [Install Homebrew](https://brew.sh) if not already installed
- **Internet connection** - For downloading packages

## Installation Steps

### 1. Run the Installation Script

```bash
bash qmk_install.sh
```

The script is **idempotent**, meaning you can safely run it multiple times. It will:
- Skip already installed packages
- Only add PATH entries if they don't exist
- Verify everything is working

### 2. Reload Your Shell

After installation, reload your shell configuration:

```bash
source ~/.zshrc
```

Or simply **open a new terminal window** (new terminals automatically load `.zshrc`).

### 3. Verify Installation

Check that everything is working:

```bash
qmk doctor
```

You should see:
```
Ψ All dependencies are installed.
Ψ Found arm-none-eabi-gcc version 13.2.1
Ψ Found avr-gcc version 8.5.0
Ψ QMK is ready to go
```

### 4. Setup QMK Firmware Repository

If you haven't already, clone the QMK firmware repository:

```bash
qmk setup
```

This will clone the QMK firmware to `~/qmk_firmware` (or prompt you for a location).

## Usage Examples

### Compile a keyboard firmware

```bash
qmk compile -kb <keyboard> -km default
```

Example:
```bash
qmk compile -kb clueboard/66/rev3 -km default
```

### Flash firmware to keyboard

```bash
qmk flash -kb <keyboard> -km default
```

### List available keyboards

```bash
qmk list-keyboards
```

## Troubleshooting

### "Can't find arm-none-eabi-gcc" or "Can't find avr-gcc"

**Solution:** The toolchains are installed but not in your PATH. Run:

```bash
source ~/.zshrc
```

Or open a new terminal window.

**Verify:** Check if paths are in your `.zshrc`:
```bash
grep "QMK toolchain" ~/.zshrc
```

### "qmk: command not found"

**Solution:** The QMK CLI might not be in your PATH. Run:

```bash
pipx ensurepath
source ~/.zshrc
```

Or restart your terminal.

### Homebrew Installation Fails

**Solution:** Make sure Homebrew is up to date:

```bash
brew update
```

If you're on an Intel Mac, you may need to adjust the paths in the script (change `/opt/homebrew` to `/usr/local`).

### Permission Errors

**Solution:** Make sure you have write permissions to your home directory and Homebrew directories:

```bash
sudo chown -R $(whoami) /opt/homebrew
```

## How It Works

### PATH Configuration

The script adds these paths to your `~/.zshrc`:

```bash
# QMK toolchain paths
export PATH="/opt/homebrew/opt/avr-gcc@8/bin:$PATH"
export PATH="/opt/homebrew/opt/arm-gcc-bin@13/bin:$PATH"
```

These are "keg-only" Homebrew packages, meaning they're not automatically symlinked to `/opt/homebrew/bin`. The script adds them to your PATH so QMK can find them.

### Idempotent Design

The script checks for existing installations before installing:
- Skips taps that already exist
- Skips packages that are already installed
- Only adds PATH entries if they don't exist
- Safe to run multiple times

## File Structure

```
completed/
├── README.md          # This file
├── PLAN.md           # Development plan
└── qmk_install.sh    # Main installation script
```

## System Requirements

- **macOS**: 12.0 (Monterey) or later
- **Architecture**: Apple Silicon (arm64) - M1, M2, M3, etc.
- **Homebrew**: Latest version
- **Disk Space**: ~2GB for all dependencies

## What's Different from Manual Installation?

This script automates the entire process:

1. **No manual tap additions** - Automatically adds required Homebrew taps
2. **No manual PATH configuration** - Automatically adds toolchain paths to `.zshrc`
3. **No version guessing** - Handles version fallbacks automatically
4. **Comprehensive verification** - Runs `qmk doctor` to verify everything works
5. **Idempotent** - Safe to run multiple times without issues

## Advanced Usage

### Custom Installation Location

If you want to install QMK firmware in a custom location:

```bash
qmk setup -H /path/to/custom/location
```

### Using a Fork

If you have your own QMK firmware fork:

```bash
qmk setup <your-username>/qmk_firmware
```

## Support

- **QMK Documentation**: https://docs.qmk.fm
- **QMK Discord**: https://discord.gg/qmk
- **QMK GitHub**: https://github.com/qmk/qmk_firmware

## License

This script is provided as-is for convenience. QMK firmware and its dependencies have their own licenses.

## Changelog

### Version 1.0
- Initial consolidated script
- Supports macOS Apple Silicon
- Idempotent installation
- Automatic PATH configuration
- Comprehensive verification
