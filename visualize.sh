#!/bin/bash
#
# QMK Keymap Visualization Script
#
# This script uses keymap-drawer to visualize QMK keymaps.
# Workflow: keymap.c → qmk c2json → keymap parse → YAML → keymap draw → SVG
#
# Usage: ./visualize.sh
#

set -e  # Exit on error

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QMK_FIRMWARE_DIR="$HOME/qmk_firmware"
DEFAULT_OUTPUT_DIR="$SCRIPT_DIR/keymap-diagrams"
DEFAULT_COLUMNS=10

# =============================================================================
# Colors for output
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# =============================================================================
# Helper functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
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
    echo -e "${CYAN}→ $1${NC}"
}

print_step() {
    echo -e "${BOLD}[$1]${NC} $2"
}

# =============================================================================
# Validation functions
# =============================================================================

check_python_version() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 not found. Please install Python 3.12+."
        exit 1
    fi
    
    local python_version=$(python3 --version 2>&1 | awk '{print $2}')
    local major=$(echo "$python_version" | cut -d. -f1)
    local minor=$(echo "$python_version" | cut -d. -f2)
    
    if [ "$major" -lt 3 ] || ([ "$major" -eq 3 ] && [ "$minor" -lt 12 ]); then
        print_error "Python 3.12+ required. Found: $python_version"
        exit 1
    fi
    
    print_success "Python version: $python_version"
}

check_qmk_cli() {
    if ! command -v qmk &> /dev/null; then
        print_error "QMK CLI not found. Please install QMK first."
        print_info "Run: bash init/qmk_install.sh"
        exit 1
    fi
    print_success "QMK CLI found: $(qmk --version 2>/dev/null || echo 'installed')"
}

check_keymap_drawer() {
    if command -v keymap &> /dev/null; then
        print_success "keymap-drawer found: $(keymap --version 2>/dev/null || echo 'installed')"
        return 0
    fi
    
    print_warning "keymap-drawer not found."
    echo ""
    printf "Install keymap-drawer? (y/n): "
    read -r response
    
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        print_error "keymap-drawer is required. Exiting."
        exit 1
    fi
    
    # Check for pipx (preferred)
    if command -v pipx &> /dev/null; then
        print_info "Installing keymap-drawer via pipx (preferred)..."
        if pipx install keymap-drawer; then
            print_success "keymap-drawer installed via pipx"
            # pipx may need PATH update
            if ! command -v keymap &> /dev/null; then
                print_warning "keymap command not in PATH. You may need to restart your terminal."
                print_info "Or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
                exit 1
            fi
        else
            print_error "Failed to install keymap-drawer via pipx"
            exit 1
        fi
    # Fallback to pip
    elif command -v pip &> /dev/null || command -v pip3 &> /dev/null; then
        local pip_cmd="pip"
        if ! command -v pip &> /dev/null; then
            pip_cmd="pip3"
        fi
        print_info "Installing keymap-drawer via $pip_cmd..."
        if $pip_cmd install --user keymap-drawer; then
            print_success "keymap-drawer installed via $pip_cmd"
            # pip --user installs to ~/.local/bin
            if ! command -v keymap &> /dev/null; then
                print_warning "keymap command not in PATH. Adding ~/.local/bin to PATH..."
                export PATH="$HOME/.local/bin:$PATH"
                if ! command -v keymap &> /dev/null; then
                    print_error "keymap command still not found. Please restart your terminal."
                    exit 1
                fi
            fi
        else
            print_error "Failed to install keymap-drawer via $pip_cmd"
            exit 1
        fi
    else
        print_error "Neither pipx nor pip found. Please install one of them first."
        exit 1
    fi
    
    # Verify installation
    if command -v keymap &> /dev/null; then
        print_success "keymap-drawer installation verified"
    else
        print_error "keymap-drawer installation failed verification"
        exit 1
    fi
}

check_png_tools() {
    # Prefer Inkscape over CairoSVG (more reliable, no rendering issues)
    if command -v inkscape &> /dev/null; then
        print_success "Inkscape found (for PNG conversion - preferred)"
        return 0
    elif command -v cairosvg &> /dev/null; then
        print_success "CairoSVG found (for PNG conversion)"
        print_warning "Note: Inkscape is recommended for better PNG quality"
        return 0
    else
        return 1
    fi
}

install_png_tools() {
    print_warning "PNG conversion tool not found."
    echo ""
    echo "Options:"
    echo "  1) Install Inkscape (recommended - better quality, no rendering issues)"
    echo "  2) Install CairoSVG (alternative, may have rendering issues)"
    echo ""
    printf "Install Inkscape? (y/n, or 'c' for CairoSVG): "
    read -r response
    
    if [ "$response" = "c" ] || [ "$response" = "C" ]; then
        # Install CairoSVG
        if command -v pipx &> /dev/null; then
            print_info "Installing CairoSVG via pipx..."
            if pipx install cairosvg; then
                print_success "CairoSVG installed via pipx"
                if ! command -v cairosvg &> /dev/null; then
                    print_warning "cairosvg command not in PATH. You may need to restart your terminal."
                    print_info "Or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
                    return 1
                fi
                return 0
            fi
        fi
        
        if command -v pip &> /dev/null || command -v pip3 &> /dev/null; then
            local pip_cmd="pip"
            if ! command -v pip &> /dev/null; then
                pip_cmd="pip3"
            fi
            print_info "Installing CairoSVG via $pip_cmd..."
            if $pip_cmd install --user cairosvg; then
                print_success "CairoSVG installed via $pip_cmd"
                export PATH="$HOME/.local/bin:$PATH"
                if ! command -v cairosvg &> /dev/null; then
                    print_warning "cairosvg command still not found. You may need to restart your terminal."
                    return 1
                fi
                return 0
            fi
        fi
        print_error "Failed to install CairoSVG"
        return 1
    elif [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        print_warning "Skipping PNG conversion tool installation."
        return 1
    fi
    
    # Install Inkscape via Homebrew (preferred)
    if command -v brew &> /dev/null; then
        print_info "Installing Inkscape via Homebrew (recommended)..."
        if brew install inkscape; then
            print_success "Inkscape installed via Homebrew"
            if ! command -v inkscape &> /dev/null; then
                print_warning "inkscape command not in PATH. You may need to restart your terminal."
                return 1
            fi
            return 0
        else
            print_error "Failed to install Inkscape via Homebrew"
            print_info "You can try installing manually: brew install inkscape"
            return 1
        fi
    else
        print_error "Homebrew not found. Cannot install Inkscape automatically."
        print_info "Please install Inkscape manually: brew install inkscape"
        print_info "Or install CairoSVG: pip install cairosvg"
        return 1
    fi
}

check_prerequisites() {
    print_step "1/6" "Checking prerequisites..."
    
    check_python_version
    check_qmk_cli
    check_keymap_drawer
    
    echo ""
}

# =============================================================================
# Keyboard discovery functions
# =============================================================================

# Find all keyboard variants (directories containing keymaps/)
discover_keyboards() {
    # Find all directories that have a keymaps/ subdirectory (indicates a buildable keyboard)
    find "$SCRIPT_DIR" -type d -name "keymaps" -not -path "*/init/*" -not -path "*/.git/*" 2>/dev/null | while read -r keymap_dir; do
        # Get the keyboard directory (parent of keymaps/)
        local kb_dir=$(dirname "$keymap_dir")
        # Get the relative path from SCRIPT_DIR
        local rel_path="${kb_dir#$SCRIPT_DIR/}"
        echo "$rel_path"
    done
}

# =============================================================================
# Keymap discovery functions
# =============================================================================

# Find all keymaps for a given keyboard
discover_keymaps() {
    local keyboard_path="$1"
    local keymaps_dir="$SCRIPT_DIR/$keyboard_path/keymaps"
    
    if [ -d "$keymaps_dir" ]; then
        for keymap in "$keymaps_dir"/*/; do
            if [ -d "$keymap" ]; then
                basename "$keymap"
            fi
        done
    fi
}

# =============================================================================
# Menu functions
# =============================================================================

# Display keyboard selection menu
select_keyboard() {
    print_header "Select Keyboard to Visualize"
    
    # Discover keyboards into array (bash 3.2 compatible)
    local i=0
    while IFS= read -r kb; do
        if [ -n "$kb" ]; then
            keyboards[i]="$kb"
            ((i++)) || true
        fi
    done < <(discover_keyboards)
    
    if [ ${#keyboards[@]} -eq 0 ]; then
        print_error "No keyboards found in workspace."
        print_info "Add keyboard directories under: $SCRIPT_DIR"
        exit 1
    fi
    
    echo "Available keyboards:"
    echo ""
    
    i=1
    for kb in "${keyboards[@]}"; do
        printf "  ${CYAN}%2d)${NC} %s\n" "$i" "$kb"
        ((i++)) || true
    done
    
    echo ""
    printf "Enter selection [1-%d]: " "${#keyboards[@]}"
    read -r selection
    
    # Validate input
    if ! echo "$selection" | grep -qE '^[0-9]+$'; then
        print_error "Invalid selection. Please enter a number."
        exit 1
    fi
    
    if [ "$selection" -lt 1 ] || [ "$selection" -gt "${#keyboards[@]}" ]; then
        print_error "Selection out of range. Please enter 1-${#keyboards[@]}."
        exit 1
    fi
    
    SELECTED_KEYBOARD="${keyboards[$((selection-1))]}"
    print_success "Selected: $SELECTED_KEYBOARD"
    echo ""
}

# Display keymap selection menu
select_keymap() {
    print_header "Select Keymap"
    
    # Discover keymaps into array (bash 3.2 compatible)
    local keymaps=()
    local i=0
    while IFS= read -r km; do
        if [ -n "$km" ]; then
            keymaps[i]="$km"
            ((i++)) || true
        fi
    done < <(discover_keymaps "$SELECTED_KEYBOARD")
    
    if [ ${#keymaps[@]} -eq 0 ]; then
        print_error "No keymaps found for $SELECTED_KEYBOARD"
        exit 1
    fi
    
    echo "Available keymaps:"
    echo ""
    
    i=1
    for km in "${keymaps[@]}"; do
        printf "  ${CYAN}%2d)${NC} %s\n" "$i" "$km"
        ((i++)) || true
    done
    
    echo ""
    printf "Enter selection [1-%d]: " "${#keymaps[@]}"
    read -r selection
    
    # Validate input
    if ! echo "$selection" | grep -qE '^[0-9]+$'; then
        print_error "Invalid selection. Please enter a number."
        exit 1
    fi
    
    if [ "$selection" -lt 1 ] || [ "$selection" -gt "${#keymaps[@]}" ]; then
        print_error "Selection out of range. Please enter 1-${#keymaps[@]}."
        exit 1
    fi
    
    SELECTED_KEYMAP="${keymaps[$((selection-1))]}"
    print_success "Selected keymap: $SELECTED_KEYMAP"
    echo ""
}

# Display columns parameter selection menu
select_columns() {
    print_header "Select Columns Parameter"
    
    echo "The columns parameter helps reorganize output layers."
    echo ""
    echo "Options:"
    echo ""
    printf "  ${CYAN}1)${NC} Auto-detect (try to infer from layout)\n"
    printf "  ${CYAN}2)${NC} Manual entry\n"
    printf "  ${CYAN}3)${NC} Default (${DEFAULT_COLUMNS})\n"
    echo ""
    printf "Enter selection [1-3]: "
    read -r selection
    
    # Validate input
    if ! echo "$selection" | grep -qE '^[0-9]+$'; then
        print_error "Invalid selection. Please enter a number."
        exit 1
    fi
    
    case "$selection" in
        1)
            SELECTED_COLUMNS="auto"
            print_info "Will attempt to auto-detect columns (may fallback to default)"
            ;;
        2)
            printf "Enter number of columns: "
            read -r columns
            if ! echo "$columns" | grep -qE '^[0-9]+$'; then
                print_error "Invalid number. Using default: ${DEFAULT_COLUMNS}"
                SELECTED_COLUMNS="$DEFAULT_COLUMNS"
            else
                SELECTED_COLUMNS="$columns"
                print_success "Columns set to: $SELECTED_COLUMNS"
            fi
            ;;
        3)
            SELECTED_COLUMNS="$DEFAULT_COLUMNS"
            print_success "Using default columns: $SELECTED_COLUMNS"
            ;;
        *)
            print_error "Selection out of range. Using default: ${DEFAULT_COLUMNS}"
            SELECTED_COLUMNS="$DEFAULT_COLUMNS"
            ;;
    esac
    echo ""
}

# Display output format selection menu
select_output_format() {
    print_header "Select Output Format"
    
    echo "Options:"
    echo ""
    printf "  ${CYAN}1)${NC} SVG only (vector graphics, scalable)\n"
    printf "  ${CYAN}2)${NC} PNG only (requires CairoSVG or Inkscape)\n"
    printf "  ${CYAN}3)${NC} Both SVG and PNG\n"
    echo ""
    printf "Enter selection [1-3]: "
    read -r selection
    
    # Validate input
    if ! echo "$selection" | grep -qE '^[0-9]+$'; then
        print_error "Invalid selection. Please enter a number."
        exit 1
    fi
    
    case "$selection" in
        1)
            OUTPUT_FORMAT="svg"
            print_success "Output format: SVG only"
            ;;
        2)
            OUTPUT_FORMAT="png"
            if ! check_png_tools; then
                if install_png_tools; then
                    print_success "Output format: PNG only"
                else
                    print_warning "PNG tools not available. Will generate SVG instead."
                    OUTPUT_FORMAT="svg"
                fi
            else
                print_success "Output format: PNG only"
            fi
            ;;
        3)
            OUTPUT_FORMAT="both"
            if ! check_png_tools; then
                if install_png_tools; then
                    print_success "Output format: Both SVG and PNG"
                else
                    print_warning "PNG tools not available. Will generate SVG only."
                    OUTPUT_FORMAT="svg"
                fi
            else
                print_success "Output format: Both SVG and PNG"
            fi
            ;;
        *)
            print_error "Selection out of range. Using default: SVG"
            OUTPUT_FORMAT="svg"
            ;;
    esac
    echo ""
}

# Display output directory selection menu
select_output_dir() {
    print_header "Select Output Directory"
    
    local keymap_dir="$SCRIPT_DIR/$SELECTED_KEYBOARD/keymaps/$SELECTED_KEYMAP"
    local default_dir="$DEFAULT_OUTPUT_DIR"
    
    echo "Output will be organized as: <base_path>/<keyboard>/<keymap>/<format>/"
    echo ""
    echo "Options:"
    echo ""
    printf "  ${CYAN}1)${NC} Default (${default_dir}/)\n"
    printf "  ${CYAN}2)${NC} Custom path\n"
    printf "  ${CYAN}3)${NC} Same as keymap location (${keymap_dir}/)\n"
    echo ""
    printf "Enter selection [1-3]: "
    read -r selection
    
    # Validate input
    if ! echo "$selection" | grep -qE '^[0-9]+$'; then
        print_error "Invalid selection. Please enter a number."
        exit 1
    fi
    
    case "$selection" in
        1)
            OUTPUT_BASE_DIR="$default_dir"
            print_success "Output base directory: $OUTPUT_BASE_DIR"
            ;;
        2)
            printf "Enter custom path: "
            read -r custom_path
            if [ -z "$custom_path" ]; then
                print_error "Empty path. Using default: $default_dir"
                OUTPUT_BASE_DIR="$default_dir"
            else
                # Expand ~ and resolve relative paths
                custom_path=$(eval echo "$custom_path")
                # Try to resolve to absolute path if it's a directory
                if [ -d "$(dirname "$custom_path" 2>/dev/null)" ]; then
                    OUTPUT_BASE_DIR="$(cd "$(dirname "$custom_path")" 2>/dev/null && pwd)/$(basename "$custom_path")"
                else
                    # If parent doesn't exist, use as-is (will be created)
                    OUTPUT_BASE_DIR="$custom_path"
                fi
                print_success "Output base directory: $OUTPUT_BASE_DIR"
            fi
            ;;
        3)
            OUTPUT_BASE_DIR="$keymap_dir"
            print_success "Output base directory: $OUTPUT_BASE_DIR"
            ;;
        *)
            print_error "Selection out of range. Using default: $default_dir"
            OUTPUT_BASE_DIR="$default_dir"
            ;;
    esac
    echo ""
}

# Display YAML handling selection menu
select_yaml_handling() {
    print_header "YAML File Handling"
    
    echo "The intermediate YAML file can be saved for manual tweaking or cleaned up."
    echo ""
    echo "Options:"
    echo ""
    printf "  ${CYAN}1)${NC} Save YAML to output directory\n"
    printf "  ${CYAN}2)${NC} Use temporary file (cleanup after)\n"
    echo ""
    printf "Enter selection [1-2]: "
    read -r selection
    
    # Validate input
    if ! echo "$selection" | grep -qE '^[0-9]+$'; then
        print_error "Invalid selection. Please enter a number."
        exit 1
    fi
    
    case "$selection" in
        1)
            SAVE_YAML=true
            print_success "YAML file will be saved to output directory"
            ;;
        2)
            SAVE_YAML=false
            print_success "YAML file will be temporary (cleaned up after)"
            ;;
        *)
            print_error "Selection out of range. Using default: Save YAML"
            SAVE_YAML=true
            ;;
    esac
    echo ""
}

# =============================================================================
# Diagram generation functions
# =============================================================================

generate_diagrams() {
    print_step "2/6" "Generating keymap diagrams..."
    
    local keymap_file="$SCRIPT_DIR/$SELECTED_KEYBOARD/keymaps/$SELECTED_KEYMAP/keymap.c"
    
    # Validate keymap file exists
    if [ ! -f "$keymap_file" ]; then
        print_error "Keymap file not found: $keymap_file"
        exit 1
    fi
    
    print_info "Keymap file: $keymap_file"
    
    # Construct final output directory: <base_path>/<keyboard>/<keymap>/<format>/
    # Determine format subdirectory based on output format
    local format_subdir
    if [ "$OUTPUT_FORMAT" = "svg" ]; then
        format_subdir="svg"
    elif [ "$OUTPUT_FORMAT" = "png" ]; then
        format_subdir="png"
    else
        format_subdir="both"
    fi
    
    # Build final output path: <base>/<keyboard>/<keymap>/<format>/
    OUTPUT_DIR="$OUTPUT_BASE_DIR/$SELECTED_KEYBOARD/$SELECTED_KEYMAP/$format_subdir"
    
    # Create output directory structure
    mkdir -p "$OUTPUT_DIR"
    print_success "Output directory: $OUTPUT_DIR"
    
    # Determine YAML file location
    # YAML is saved in the parent directory (same level as format subdirectories)
    local yaml_base_dir="$OUTPUT_BASE_DIR/$SELECTED_KEYBOARD/$SELECTED_KEYMAP"
    local yaml_file
    if [ "$SAVE_YAML" = true ]; then
        yaml_file="$yaml_base_dir/keymap.yaml"
        mkdir -p "$yaml_base_dir"
    else
        yaml_file=$(mktemp /tmp/keymap_XXXXXX.yaml)
        print_info "Using temporary YAML file: $yaml_file"
    fi
    
    # Step 1: Convert keymap.c to JSON via qmk c2json
    print_step "3/6" "Converting keymap.c to JSON..."
    # Save JSON to output directory (same location as YAML)
    local json_file="$yaml_base_dir/keymap.json"
    mkdir -p "$yaml_base_dir"
    local json_output="$json_file"
    local error_output
    error_output=$(mktemp /tmp/keymap_error_XXXXXX.txt)
    
    # Extract keyboard name from SELECTED_KEYBOARD (e.g., "keychron/q11/ansi_encoder")
    local qmk_keyboard="$SELECTED_KEYBOARD"
    local qmk_keymap="$SELECTED_KEYMAP"
    
    print_info "Keyboard: $qmk_keyboard"
    print_info "Keymap: $qmk_keymap"
    
    # Check if keyboard exists in QMK firmware directory
    local qmk_keyboard_path="$QMK_FIRMWARE_DIR/keyboards/$qmk_keyboard"
    if [ ! -d "$qmk_keyboard_path" ]; then
        print_warning "Keyboard not found in QMK firmware directory: $qmk_keyboard_path"
        print_info "qmk c2json requires the keyboard to be in the QMK firmware repository."
        print_info ""
        print_info "Options:"
        print_info "  1. Copy your keyboard to QMK firmware directory manually"
        print_info "  2. Run './build.sh' first (it copies the keyboard to QMK)"
        print_info "  3. Ensure the keyboard exists at: $qmk_keyboard_path"
        echo ""
        printf "Continue anyway? (y/n): "
        read -r response
        if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
            print_info "Exiting. Please ensure the keyboard is in the QMK firmware directory."
            exit 1
        fi
        print_warning "Continuing, but conversion may fail..."
    else
        print_success "Keyboard found in QMK firmware directory"
    fi
    
    # Run qmk c2json with keyboard and keymap parameters
    if ! qmk c2json -kb "$qmk_keyboard" -km "$qmk_keymap" "$keymap_file" > "$json_output" 2> "$error_output"; then
        print_error "Failed to convert keymap.c to JSON"
        echo ""
        print_info "Error details:"
        if [ -s "$error_output" ]; then
            cat "$error_output" | while IFS= read -r line; do
                echo -e "  ${RED}$line${NC}"
            done
        else
            print_info "  (No error details available)"
        fi
        echo ""
        print_info "Common causes:"
        print_info "  - Keyboard not found in QMK firmware repository"
        print_info "  - Missing QMK keyboard definition"
        print_info "  - Invalid keymap.c syntax"
        print_info ""
        print_info "To fix:"
        print_info "  1. Ensure the keyboard exists at: $qmk_keyboard_path"
        print_info "  2. Run './build.sh' first to copy keyboard to QMK directory"
        print_info "  3. Run 'qmk setup' if you haven't already"
        print_info "  4. Check that the keyboard path matches QMK's structure"
        rm -f "$json_output" "$error_output"
        exit 1
    fi
    
    # Check if JSON output is valid (not empty and contains valid JSON)
    if [ ! -s "$json_output" ]; then
        print_error "JSON output is empty"
        if [ -s "$error_output" ]; then
            print_info "Error details:"
            cat "$error_output" | while IFS= read -r line; do
                echo -e "  ${RED}$line${NC}"
            done
        fi
        rm -f "$json_output" "$error_output"
        exit 1
    fi
    
    rm -f "$error_output"
    print_success "Converted to JSON"
    
    # Step 2: Parse JSON to YAML via keymap parse
    print_step "4/6" "Parsing JSON to YAML..."
    
    local columns_arg=""
    if [ "$SELECTED_COLUMNS" != "auto" ]; then
        columns_arg="-c $SELECTED_COLUMNS"
    else
        # Try to auto-detect columns (default to 10 if detection fails)
        columns_arg="-c 10"
        print_info "Using columns: 10 (auto-detect attempted)"
    fi
    
    if ! cat "$json_output" | keymap parse $columns_arg -q - > "$yaml_file" 2>&1; then
        print_error "Failed to parse JSON to YAML"
        print_info "Check the keymap structure and columns parameter"
        rm -f "$json_output" "$yaml_file"
        exit 1
    fi
    print_success "Parsed to YAML: $yaml_file"
    print_success "JSON saved to: $json_file"
    
    # Step 3: Generate SVG via keymap draw
    print_step "5/6" "Generating SVG diagram..."
    
    local svg_file="$OUTPUT_DIR/keymap.svg"
    
    if ! keymap draw "$yaml_file" > "$svg_file" 2>&1; then
        print_error "Failed to generate SVG diagram"
        print_info "This may indicate:"
        print_info "  - Invalid YAML structure"
        print_info "  - Layout detection issues"
        print_info "  - Missing keyboard layout definition"
        if [ "$SAVE_YAML" = false ]; then
            rm -f "$yaml_file"
        fi
        exit 1
    fi
    print_success "Generated SVG: $svg_file"
    
    # Step 4: Convert to PNG if requested
    if [ "$OUTPUT_FORMAT" = "png" ] || [ "$OUTPUT_FORMAT" = "both" ]; then
        print_step "6/6" "Converting SVG to PNG..."
        
        local png_file="$OUTPUT_DIR/keymap.png"
        local conversion_success=false
        local error_output_png
        error_output_png=$(mktemp /tmp/keymap_png_error_XXXXXX.txt)
        
        # Prefer Inkscape (more reliable, better quality, no rendering issues)
        if command -v inkscape &> /dev/null; then
            print_info "Using Inkscape for PNG conversion (recommended)"
            # Use high DPI for better quality (96 DPI default, 144 for high-res)
            # --export-type=png ensures PNG output
            # --export-filename sets output file
            # --export-dpi=144 for high quality
            if inkscape "$svg_file" --export-type=png --export-filename="$png_file" --export-dpi=144 2> "$error_output_png"; then
                print_success "Generated PNG via Inkscape: $png_file"
                conversion_success=true
            else
                print_warning "Inkscape conversion failed"
                if [ -s "$error_output_png" ]; then
                    print_info "Error details:"
                    cat "$error_output_png" | while IFS= read -r line; do
                        echo -e "  ${YELLOW}$line${NC}"
                    done
                fi
            fi
        # Fallback to CairoSVG (may have rendering issues)
        elif command -v cairosvg &> /dev/null; then
            print_warning "Using CairoSVG (Inkscape recommended for better quality)"
            # CairoSVG doesn't support DPI options well, but we can try
            if cairosvg "$svg_file" -o "$png_file" 2> "$error_output_png"; then
                print_success "Generated PNG via CairoSVG: $png_file"
                print_warning "If you see rendering issues, try Inkscape instead: brew install inkscape"
                conversion_success=true
            else
                print_warning "CairoSVG conversion failed"
                if [ -s "$error_output_png" ]; then
                    print_info "Error details:"
                    cat "$error_output_png" | while IFS= read -r line; do
                        echo -e "  ${YELLOW}$line${NC}"
                    done
                fi
            fi
        else
            print_warning "No PNG conversion tool available (Inkscape or CairoSVG required)"
        fi
        
        rm -f "$error_output_png"
        
        if [ "$conversion_success" = false ]; then
            print_warning "PNG conversion failed. SVG file is available: $svg_file"
            if [ "$OUTPUT_FORMAT" = "png" ]; then
                print_info "Install Inkscape (recommended): brew install inkscape"
                print_info "Or install CairoSVG: pip install cairosvg"
            fi
        fi
    fi
    
    # Cleanup temporary YAML if not saving
    if [ "$SAVE_YAML" = false ]; then
        rm -f "$yaml_file"
        print_info "Cleaned up temporary YAML file"
    fi
    
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header "QMK Keymap Visualizer"
    
    # Initialize global variables
    keyboards=()
    SELECTED_KEYBOARD=""
    SELECTED_KEYMAP=""
    SELECTED_COLUMNS="$DEFAULT_COLUMNS"
    OUTPUT_FORMAT="svg"
    OUTPUT_BASE_DIR="$DEFAULT_OUTPUT_DIR"
    OUTPUT_DIR=""
    SAVE_YAML=true
    
    # Run workflow
    check_prerequisites
    select_keyboard
    select_keymap
    select_columns
    select_output_format
    select_output_dir
    select_yaml_handling
    generate_diagrams
    
    # Final summary
    print_header "Visualization Complete!"
    echo -e "  Keyboard: ${CYAN}$SELECTED_KEYBOARD${NC}"
    echo -e "  Keymap:   ${CYAN}$SELECTED_KEYMAP${NC}"
    echo -e "  Output:   ${GREEN}$OUTPUT_DIR/${NC}"
    echo ""
    
    # List generated files
    print_info "Generated files:"
    if [ -f "$OUTPUT_DIR/keymap.svg" ]; then
        echo -e "  ${GREEN}✓${NC} $OUTPUT_DIR/keymap.svg"
    fi
    if [ -f "$OUTPUT_DIR/keymap.png" ]; then
        echo -e "  ${GREEN}✓${NC} $OUTPUT_DIR/keymap.png"
    fi
    local json_path="$OUTPUT_BASE_DIR/$SELECTED_KEYBOARD/$SELECTED_KEYMAP/keymap.json"
    if [ -f "$json_path" ]; then
        echo -e "  ${GREEN}✓${NC} $json_path"
    fi
    if [ "$SAVE_YAML" = true ]; then
        local yaml_path="$OUTPUT_BASE_DIR/$SELECTED_KEYBOARD/$SELECTED_KEYMAP/keymap.yaml"
        if [ -f "$yaml_path" ]; then
            echo -e "  ${GREEN}✓${NC} $yaml_path"
        fi
    fi
    echo ""
    
    print_info "You can open the SVG/PNG files in your browser or image viewer."
    echo ""
}

# Run main function
main "$@"
