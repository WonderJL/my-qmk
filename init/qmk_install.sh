#!/bin/bash
#
# QMK Firmware Installation Script for macOS (Apple Silicon)
# 
# This script installs all required dependencies for QMK firmware development
# on macOS systems with Apple Silicon (M1/M2/M3).
#
# Usage: bash qmk_install.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AVR_GCC_VERSION="8"
ARM_GCC_VERSION="13"
QMK_HOMEBREW_PATH="/opt/homebrew"

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    
    # Check for Apple Silicon
    if [[ $(uname -m) != "arm64" ]]; then
        print_warning "This script is optimized for Apple Silicon (M1/M2/M3)."
        print_warning "Intel Macs may need adjustments."
    fi
    
    print_success "Detected macOS $(sw_vers -productVersion) ($(uname -m))"
}

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed."
        print_info "Please install Homebrew first: https://brew.sh"
        exit 1
    fi
    print_success "Homebrew found: $(brew --version | head -n1)"
}

# Install QMK CLI if not present
install_qmk_cli() {
    print_header "Step 1: Installing QMK CLI"
    
    if command -v qmk &> /dev/null; then
        QMK_VERSION=$(qmk --version 2>/dev/null || echo "unknown")
        print_success "QMK CLI already installed (version: $QMK_VERSION)"
        return 0
    fi
    
    print_info "QMK CLI not found. Installing via pipx..."
    
    # Check if pipx is installed
    if ! command -v pipx &> /dev/null; then
        print_info "pipx not found. Installing pipx..."
        brew install pipx
        pipx ensurepath
    fi
    
    # Install QMK CLI
    print_info "Installing QMK CLI..."
    pipx install qmk
    
    if command -v qmk &> /dev/null; then
        print_success "QMK CLI installed successfully (version: $(qmk --version))"
    else
        print_error "QMK CLI installation failed."
        print_info "You may need to restart your terminal or run: source ~/.zshrc"
        exit 1
    fi
}

# Install Homebrew dependencies
install_dependencies() {
    print_header "Step 2: Installing QMK Dependencies"
    
    # Add required taps
    print_info "Adding Homebrew taps..."
    if ! brew tap | grep -q "osx-cross/avr"; then
        brew tap osx-cross/avr
        print_success "Added osx-cross/avr tap"
    else
        print_success "osx-cross/avr tap already exists"
    fi
    
    if ! brew tap | grep -q "osx-cross/arm"; then
        brew tap osx-cross/arm
        print_success "Added osx-cross/arm tap"
    else
        print_success "osx-cross/arm tap already exists"
    fi
    
    # Install AVR toolchain
    print_info "Installing AVR toolchain (avr-gcc@${AVR_GCC_VERSION})..."
    if brew list --formula osx-cross/avr/avr-gcc@${AVR_GCC_VERSION} &>/dev/null; then
        print_success "AVR toolchain already installed"
    else
        brew install osx-cross/avr/avr-gcc@${AVR_GCC_VERSION} || {
            print_warning "avr-gcc@${AVR_GCC_VERSION} not available, trying avr-gcc..."
            brew install osx-cross/avr/avr-gcc
        }
        print_success "AVR toolchain installed"
    fi
    
    # Install ARM toolchain (arm-none-eabi-gcc)
    # This is required for ARM-based keyboards like Keychron Q11
    print_info "Installing ARM toolchain (arm-none-eabi-gcc)..."
    if command -v arm-none-eabi-gcc &> /dev/null; then
        print_success "ARM toolchain already installed: $(arm-none-eabi-gcc --version | head -n1)"
    else
        # Try standard Homebrew formula first (most reliable)
        if brew install arm-none-eabi-gcc 2>/dev/null; then
            print_success "ARM toolchain installed (arm-none-eabi-gcc)"
        # Fallback to osx-cross/arm tap
        elif brew install osx-cross/arm/arm-gcc-bin@${ARM_GCC_VERSION} 2>/dev/null; then
            print_success "ARM toolchain installed (osx-cross version ${ARM_GCC_VERSION})"
        elif brew install osx-cross/arm/arm-gcc-bin@12 2>/dev/null; then
            ARM_GCC_VERSION="12"
            print_success "ARM toolchain installed (osx-cross version 12)"
        elif brew install osx-cross/arm/arm-gcc-bin 2>/dev/null; then
            print_success "ARM toolchain installed (osx-cross latest)"
        else
            print_error "Failed to install ARM toolchain. Please install manually:"
            print_info "  brew install arm-none-eabi-gcc"
        fi
    fi
    
    # Install other required tools
    print_info "Installing other required tools..."
    local tools=("avrdude" "dfu-util" "dfu-programmer" "dos2unix")
    for tool in "${tools[@]}"; do
        if brew list --formula "$tool" &>/dev/null; then
            print_success "$tool already installed"
        else
            brew install "$tool"
            print_success "$tool installed"
        fi
    done
}

# Configure PATH in ~/.zshrc
configure_path() {
    print_header "Step 3: Configuring PATH"
    
    local zshrc_path="$HOME/.zshrc"
    local avr_path="${QMK_HOMEBREW_PATH}/opt/avr-gcc@${AVR_GCC_VERSION}/bin"
    
    # Detect ARM toolchain path (standard Homebrew or osx-cross)
    local arm_path=""
    if [ -d "${QMK_HOMEBREW_PATH}/opt/arm-none-eabi-gcc/bin" ]; then
        arm_path="${QMK_HOMEBREW_PATH}/opt/arm-none-eabi-gcc/bin"
    elif [ -d "${QMK_HOMEBREW_PATH}/opt/arm-gcc-bin@${ARM_GCC_VERSION}/bin" ]; then
        arm_path="${QMK_HOMEBREW_PATH}/opt/arm-gcc-bin@${ARM_GCC_VERSION}/bin"
    elif [ -d "${QMK_HOMEBREW_PATH}/opt/arm-gcc-bin@12/bin" ]; then
        arm_path="${QMK_HOMEBREW_PATH}/opt/arm-gcc-bin@12/bin"
    fi
    
    # Check if paths are already configured
    if grep -q "QMK toolchain paths" "$zshrc_path" 2>/dev/null; then
        print_success "QMK toolchain paths already in ~/.zshrc"
    else
        print_info "Adding QMK toolchain paths to ~/.zshrc..."
        
        # Add a blank line and comment if file doesn't end with newline
        if [ -s "$zshrc_path" ] && [ "$(tail -c 1 "$zshrc_path")" != "" ]; then
            echo "" >> "$zshrc_path"
        fi
        
        echo "" >> "$zshrc_path"
        echo "# QMK toolchain paths" >> "$zshrc_path"
        echo "export PATH=\"${avr_path}:\$PATH\"" >> "$zshrc_path"
        if [ -n "$arm_path" ]; then
            echo "export PATH=\"${arm_path}:\$PATH\"" >> "$zshrc_path"
        fi
        
        print_success "Added toolchain paths to ~/.zshrc"
    fi
    
    # Export paths for current session
    export PATH="${avr_path}:$PATH"
    if [ -n "$arm_path" ]; then
        export PATH="${arm_path}:$PATH"
    fi
    
    print_info "Toolchain paths exported for current session"
}

# Verify installation
verify_installation() {
    print_header "Step 4: Verifying Installation"
    
    local all_good=true
    
    # Check for required tools
    local tools=(
        "arm-none-eabi-gcc:ARM toolchain"
        "avr-gcc:AVR toolchain"
        "avrdude:AVR programmer"
        "dfu-util:DFU utility"
        "dfu-programmer:DFU programmer"
        "dos2unix:Text converter"
    )
    
    for tool_info in "${tools[@]}"; do
        IFS=':' read -r tool name <<< "$tool_info"
        if command -v "$tool" &> /dev/null; then
            local version=$($tool --version 2>/dev/null | head -n1 || echo "installed")
            print_success "$name ($tool) found: $version"
        else
            print_error "$name ($tool) not found in PATH"
            all_good=false
        fi
    done
    
    echo ""
    if [ "$all_good" = true ]; then
        print_success "All tools are accessible!"
    else
        print_warning "Some tools are not in PATH. You may need to reload your shell."
    fi
    
    # Run qmk doctor
    echo ""
    print_info "Running QMK Doctor..."
    echo ""
    if command -v qmk &> /dev/null; then
        qmk doctor || {
            print_warning "qmk doctor found some issues. See output above."
        }
    else
        print_error "qmk command not found. Please restart your terminal."
    fi
}

# Main installation flow
main() {
    print_header "QMK Firmware Installation Script"
    print_info "This script will install all dependencies for QMK firmware development."
    print_info "It's safe to run multiple times (idempotent)."
    echo ""
    
    # Run installation steps
    check_macos
    check_homebrew
    install_qmk_cli
    install_dependencies
    configure_path
    verify_installation
    
    # Final instructions
    print_header "Installation Complete!"
    
    echo ""
    print_success "All QMK dependencies have been installed!"
    echo ""
    print_info "IMPORTANT: To use QMK in your current terminal session, run:"
    echo -e "  ${GREEN}source ~/.zshrc${NC}"
    echo ""
    print_info "Or simply open a new terminal window."
    echo ""
    print_info "Next steps:"
    echo "  1. Run 'source ~/.zshrc' or open a new terminal"
    echo "  2. Run 'qmk setup' to clone the QMK firmware repository"
    echo "  3. Run 'qmk doctor' to verify everything is working"
    echo "  4. Start building firmware with 'qmk compile -kb <keyboard> -km default'"
    echo ""
}

# Run main function
main "$@"
