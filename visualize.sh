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
# Layer name extraction functions
# =============================================================================

# Extract layer names from keymap.c enum layers
extract_layer_names() {
    local keymap_file="$1"
    
    # Extract enum layers block and parse layer names
    # Pattern: enum layers { NAME1, NAME2, ... };
    if [ -f "$keymap_file" ]; then
        # Extract the enum layers section (from "enum layers {" to "};")
        awk '/enum layers[[:space:]]*\{/,/^[[:space:]]*\};/' "$keymap_file" 2>/dev/null | \
            # Extract identifiers that are followed by comma or closing brace
            grep -E '^[[:space:]]*[A-Z_][A-Z0-9_]*[[:space:]]*[,}]' | \
            # Extract just the identifier name
            sed -E 's/^[[:space:]]*([A-Z_][A-Z0-9_]*).*/\1/' | \
            # Remove empty lines
            grep -v '^[[:space:]]*$'
    fi
}

# Count layers in keymap.c
count_layers() {
    local keymap_file="$1"
    
    if [ ! -f "$keymap_file" ]; then
        echo "0"
        return 1
    fi
    
    # Extract layer names and count them
    local count=0
    while IFS= read -r name; do
        if [ -n "$name" ]; then
            ((count++)) || true
        fi
    done < <(extract_layer_names "$keymap_file")
    
    echo "$count"
    return 0
}

# Update YAML file to replace L0, L1, etc. with layer names
update_yaml_layer_names() {
    local yaml_file="$1"
    local keymap_file="$2"
    
    if [ ! -f "$yaml_file" ] || [ ! -f "$keymap_file" ]; then
        return 1
    fi
    
    # Extract layer names
    local layer_index=0
    local temp_yaml=$(mktemp /tmp/keymap_yaml_XXXXXX.yaml)
    
    # Read layer names into array
    local layer_names=()
    while IFS= read -r name; do
        if [ -n "$name" ]; then
            layer_names[layer_index]="$name"
            ((layer_index++)) || true
        fi
    done < <(extract_layer_names "$keymap_file")
    
    if [ ${#layer_names[@]} -eq 0 ]; then
        print_warning "Could not extract layer names from keymap.c"
        rm -f "$temp_yaml"
        return 1
    fi
    
    # Create a backup and update YAML
    cp "$yaml_file" "$temp_yaml"
    
    # Replace L0, L1, L2, etc. with "L0-LAYER_NAME:" format
    local i=0
    for layer_name in "${layer_names[@]}"; do
        # Replace "L${i}:" with "L${i}-${layer_name}:" in the YAML
        # Handle both GNU sed (Linux) and BSD sed (macOS)
        if sed --version >/dev/null 2>&1; then
            # GNU sed (Linux)
            sed -i "s/^  L${i}:/  L${i}-${layer_name}:/" "$temp_yaml" 2>/dev/null
        else
            # BSD sed (macOS)
            sed -i '' "s/^  L${i}:/  L${i}-${layer_name}:/" "$temp_yaml" 2>/dev/null
        fi
        ((i++)) || true
    done
    
    # Replace original with updated version
    mv "$temp_yaml" "$yaml_file"
    
    print_success "Updated YAML with layer names"
    return 0
}

# Update JSON file to replace layer indices with layer names (optional)
update_json_layer_names() {
    local json_file="$1"
    local keymap_file="$2"
    
    if [ ! -f "$json_file" ] || [ ! -f "$keymap_file" ]; then
        return 1
    fi
    
    # Check if Python is available for JSON processing
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 not available, skipping JSON layer name update"
        return 1
    fi
    
    # Extract layer names
    local layer_names=()
    local layer_index=0
    while IFS= read -r name; do
        if [ -n "$name" ]; then
            layer_names[layer_index]="$name"
            ((layer_index++)) || true
        fi
    done < <(extract_layer_names "$keymap_file")
    
    if [ ${#layer_names[@]} -eq 0 ]; then
        return 1
    fi
    
    # Use Python to update JSON (add layer names as metadata)
    # Build Python array string from bash array
    local python_array="["
    local first=true
    for name in "${layer_names[@]}"; do
        if [ "$first" = true ]; then
            python_array="${python_array}'${name}'"
            first=false
        else
            python_array="${python_array}, '${name}'"
        fi
    done
    python_array="${python_array}]"
    
    python3 << EOF 2>/dev/null
import json
import sys

try:
    with open('$json_file', 'r') as f:
        data = json.load(f)
    
    # Add layer_names array to JSON metadata
    layer_names = $python_array
    
    # Create a mapping of layer index to name
    layer_map = {}
    for i, name in enumerate(layer_names):
        layer_map[str(i)] = name
        layer_map[i] = name
    
    # Add layer_names and layer_map to the root of JSON
    data['layer_names'] = layer_names
    data['layer_map'] = layer_map
    
    with open('$json_file', 'w') as f:
        json.dump(data, f, indent=2)
    
    sys.exit(0)
except Exception as e:
    sys.exit(1)
EOF
    
    if [ $? -eq 0 ]; then
        print_success "Updated JSON with layer names metadata"
        return 0
    else
        print_warning "Could not update JSON with layer names"
        return 1
    fi
}

# =============================================================================
# Split keyboard detection and configuration functions
# =============================================================================

# Find info.json file for the keyboard (local or QMK directory)
find_info_json() {
    local keyboard_path="$1"
    
    # Try local info.json first (in keyboard directory)
    local local_info_json="$SCRIPT_DIR/$keyboard_path/info.json"
    if [ -f "$local_info_json" ]; then
        echo "$local_info_json"
        return 0
    fi
    
    # Try parent directory (for keyboards like keychron/q11/ansi_encoder)
    local parent_info_json="$SCRIPT_DIR/$(dirname "$keyboard_path")/info.json"
    if [ -f "$parent_info_json" ]; then
        echo "$parent_info_json"
        return 0
    fi
    
    # Try QMK firmware directory
    local qmk_info_json="$QMK_FIRMWARE_DIR/keyboards/$keyboard_path/info.json"
    if [ -f "$qmk_info_json" ]; then
        echo "$qmk_info_json"
        return 0
    fi
    
    # Try QMK firmware parent directory
    local qmk_parent_info_json="$QMK_FIRMWARE_DIR/keyboards/$(dirname "$keyboard_path")/info.json"
    if [ -f "$qmk_parent_info_json" ]; then
        echo "$qmk_parent_info_json"
        return 0
    fi
    
    return 1
}

# Check if keyboard is split by examining info.json
is_split_keyboard() {
    local info_json="$1"
    
    if [ ! -f "$info_json" ]; then
        return 1
    fi
    
    # Check if split.enabled is true in info.json
    # Use Python for reliable JSON parsing (more robust than grep)
    if command -v python3 &> /dev/null; then
        python3 << EOF 2>/dev/null
import json
import sys

try:
    with open('$info_json', 'r') as f:
        data = json.load(f)
    
    # Check if split is enabled
    if 'split' in data and isinstance(data['split'], dict):
        if data['split'].get('enabled', False):
            sys.exit(0)
    
    sys.exit(1)
except Exception:
    sys.exit(1)
EOF
        return $?
    fi
    
    # Fallback to grep (less reliable but works if Python not available)
    if grep -q '"split"' "$info_json" && grep -q '"enabled"' "$info_json" && grep -q 'true' "$info_json"; then
        return 0
    fi
    
    return 1
}

# Create config file with split_gap for split keyboards
create_split_config() {
    local config_file="$1"
    local split_gap="${2:-30.0}"  # Default 30.0 pixels
    
    # Create config file with split_gap setting
    cat > "$config_file" << EOF
draw_config:
  split_gap: $split_gap
EOF
    
    print_info "Created split keyboard config with gap: ${split_gap}px"
}

# Post-process SVG to add visual gap for split keyboards
# This shifts right half keys to the right by split_gap pixels
add_split_gap_to_svg() {
    local svg_file="$1"
    local info_json="$2"
    local split_gap="${3:-60.0}"  # Default 60 pixels
    
    if [ ! -f "$svg_file" ] || [ ! -f "$info_json" ]; then
        return 1
    fi
    
    # Use Python to post-process the SVG
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 not available, skipping SVG split gap post-processing"
        return 1
    fi
    
    python3 << PYEOF 2>/dev/null
import re
import json
import sys

svg_file = '$svg_file'
info_json = '$info_json'
split_gap = float('$split_gap')

try:
    # Read info.json to get layout mapping
    with open(info_json, 'r') as f:
        info_data = json.load(f)
    
    # Get layout (use LAYOUT_91_ansi as default)
    layout_name = 'LAYOUT_91_ansi'
    if 'layouts' in info_data and layout_name in info_data['layouts']:
        layout = info_data['layouts'][layout_name]['layout']
    else:
        # Try to find any layout
        if 'layouts' in info_data and len(info_data['layouts']) > 0:
            layout_name = list(info_data['layouts'].keys())[0]
            layout = info_data['layouts'][layout_name]['layout']
        else:
            sys.exit(1)
    
    # Build mapping: keypos index -> is_right_half (matrix[0] >= 6)
    keypos_to_right_half = {}
    for idx, key_def in enumerate(layout):
        matrix_row = key_def.get('matrix', [0, 0])[0]
        is_right_half = matrix_row >= 6
        keypos_to_right_half[idx] = is_right_half
    
    # Read SVG
    with open(svg_file, 'r') as f:
        svg_content = f.read()
    
    # Find all key elements with keypos class and shift right half keys
    # Pattern: <g transform="translate(X, Y)" class="key keypos-N">
    def shift_key_transform(match):
        full_match = match.group(0)
        transform = match.group(1)
        classes = match.group(2)
        
        # Extract keypos number
        keypos_match = re.search(r'keypos-(\d+)', classes)
        if not keypos_match:
            return full_match
        
        keypos = int(keypos_match.group(1))
        
        # Check if this is a right half key
        if keypos in keypos_to_right_half and keypos_to_right_half[keypos]:
            # Extract x and y from transform
            coords_match = re.search(r'translate\(([0-9.]+),\s*([0-9.]+)\)', transform)
            if coords_match:
                x = float(coords_match.group(1))
                y = float(coords_match.group(2))
                # Shift x by split_gap
                new_x = x + split_gap
                new_transform = f'translate({new_x:.1f}, {y:.1f})'
                return f'<g transform="{new_transform}" class="{classes}">'
        
        return full_match
    
    # Replace all key transforms (match keys with keypos class)
    svg_content = re.sub(
        r'<g transform="([^"]+)" class="([^"]*key[^"]*keypos-\d+[^"]*)"',
        shift_key_transform,
        svg_content
    )
    
    # Also shift text elements and other content that might be positioned relative to right half keys
    # Find the split point in SVG coordinates by looking at the transition
    # We'll find the rightmost left-half key and shift everything after that
    left_max_x = 0
    right_min_x = float('inf')
    
    for match in re.finditer(r'<g transform="translate\(([0-9.]+),\s*([0-9.]+)\)" class="[^"]*key[^"]*keypos-(\d+)', svg_content):
        x = float(match.group(1))
        keypos = int(match.group(3))
        if keypos in keypos_to_right_half:
            if not keypos_to_right_half[keypos]:
                left_max_x = max(left_max_x, x)
            else:
                right_min_x = min(right_min_x, x)
    
    # Use the midpoint as split threshold
    if right_min_x != float('inf') and left_max_x > 0:
        split_threshold = (left_max_x + right_min_x) / 2
    else:
        # Fallback: approximate split point (around 450-500px based on layout)
        split_threshold = 450
    
    # Shift other elements (text, combos, etc.) that are positioned on the right half
    def shift_other_transform(match):
        full_match = match.group(0)
        transform = match.group(1)
        coords_match = re.search(r'translate\(([0-9.]+),\s*([0-9.]+)\)', transform)
        if coords_match:
            x = float(coords_match.group(1))
            y = float(coords_match.group(2))
            # Only shift if x is beyond split threshold and not already a key element
            if x > split_threshold and 'keypos-' not in full_match:
                new_x = x + split_gap
                new_transform = f'translate({new_x:.1f}, {y:.1f})'
                return full_match.replace(transform, new_transform)
        return full_match
    
    # Shift other group transforms (but avoid double-shifting keys)
    svg_content = re.sub(
        r'<g transform="translate\(([0-9.]+),\s*([0-9.]+)\)"',
        shift_other_transform,
        svg_content
    )
    
    # Update viewBox width to accommodate the gap
    viewbox_match = re.search(r'viewBox="0\s+0\s+([0-9.]+)\s+([0-9.]+)"', svg_content)
    if viewbox_match:
        width = float(viewbox_match.group(1))
        height = float(viewbox_match.group(2))
        new_width = width + split_gap
        svg_content = re.sub(
            r'viewBox="0\s+0\s+([0-9.]+)\s+([0-9.]+)"',
            f'viewBox="0 0 {new_width:.1f} {height:.1f}"',
            svg_content,
            count=1
        )
    
    # Update SVG width attribute if present
    width_match = re.search(r'<svg[^>]*width="([0-9.]+)"', svg_content)
    if width_match:
        width = float(width_match.group(1))
        new_width = width + split_gap
        svg_content = re.sub(
            r'(<svg[^>]*width=")([0-9.]+)(")',
            f'\\g<1>{new_width:.1f}\\g<3>',
            svg_content,
            count=1
        )
    
    # Write back to file
    with open(svg_file, 'w') as f:
        f.write(svg_content)
    
    sys.exit(0)
except Exception as e:
    # Silently fail - don't break the workflow
    sys.exit(1)
PYEOF

    if [ $? -eq 0 ]; then
        print_success "Added split gap (${split_gap}px) to SVG visualization"
        return 0
    else
        print_warning "Failed to add split gap to SVG (non-critical)"
        return 1
    fi
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
    
    # Early layer detection - count layers before processing
    local layer_count
    layer_count=$(count_layers "$keymap_file")
    if [ "$layer_count" -gt 0 ]; then
        print_success "Detected $layer_count layer(s) in keymap"
        
        # Extract and display layer names early
        local layer_names=()
        local layer_index=0
        while IFS= read -r name; do
            if [ -n "$name" ]; then
                layer_names[layer_index]="$name"
                ((layer_index++)) || true
            fi
        done < <(extract_layer_names "$keymap_file")
        
        if [ ${#layer_names[@]} -gt 0 ]; then
            print_info "Layers: ${layer_names[*]}"
        fi
    else
        print_warning "Could not detect layers in keymap.c"
    fi
    
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
        print_warning "qmk c2json failed. Retrying with --no-cpp..."
        if ! qmk c2json --no-cpp -kb "$qmk_keyboard" -km "$qmk_keymap" "$keymap_file" > "$json_output" 2> "$error_output"; then
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
        else
            print_warning "Converted to JSON with --no-cpp (preprocessor disabled)"
        fi
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
        print_info "Using columns: $SELECTED_COLUMNS (manual)"
    else
        # Auto-detect columns from keyboard layout (info.json) when available, else use default.
        # Do NOT use layer count for columns - columns = physical layout key grouping (keys per row).
        local auto_columns="$DEFAULT_COLUMNS"
        local info_json_for_cols
        info_json_for_cols=$(find_info_json "$SELECTED_KEYBOARD")
        if [ -n "$info_json_for_cols" ] && [ -f "$info_json_for_cols" ] && command -v python3 &> /dev/null; then
            # Try to get first row key count from LAYOUT_91_ansi (or first layout) in info.json
            local first_row_keys
            first_row_keys=$(python3 - "$info_json_for_cols" << 'PYEOF' 2>/dev/null
import json
import sys
try:
    if len(sys.argv) < 2:
        sys.exit(1)
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)
    layouts = data.get('layouts', {})
    for name in ('LAYOUT_91_ansi', 'LAYOUT_92_iso'):
        if name in layouts:
            layout = layouts[name].get('layout', [])
            if layout:
                y0 = layout[0].get('y', 0)
                count = sum(1 for k in layout if k.get('y') == y0)
                if count > 0:
                    print(count)
                    sys.exit(0)
    from collections import defaultdict
    by_y = defaultdict(int)
    for name, spec in layouts.items():
        for k in spec.get('layout', []):
            by_y[k.get('y', 0)] += 1
    if by_y:
        print(max(by_y.values()))
except Exception:
    sys.exit(1)
PYEOF
)
            if [ -n "$first_row_keys" ] && [ "$first_row_keys" -gt 0 ] 2>/dev/null; then
                auto_columns="$first_row_keys"
                print_info "Auto-detected columns: $auto_columns (from layout in info.json)"
            else
                print_info "Auto-detected columns: $auto_columns (default)"
            fi
        else
            print_info "Auto-detected columns: $auto_columns (default)"
        fi
        columns_arg="-c $auto_columns"
    fi
    
    # keymap parse expects -q <file path>; use file path and -o for output (do not pipe stdin)
    local parse_err
    parse_err=$(mktemp /tmp/keymap_parse_err_XXXXXX.txt)
    if ! keymap parse -q "$json_output" $columns_arg -o "$yaml_file" 2> "$parse_err"; then
        print_error "Failed to parse JSON to YAML"
        print_info "Check the keymap structure and columns parameter"
        if [ -s "$parse_err" ]; then
            print_info "Parser output:"
            cat "$parse_err" | while IFS= read -r line; do
                echo -e "  ${RED}$line${NC}"
            done
        fi
        rm -f "$parse_err" "$json_output" "$yaml_file"
        exit 1
    fi
    rm -f "$parse_err"
    print_success "Parsed to YAML: $yaml_file"
    print_success "JSON saved to: $json_file"
    
    # Validate YAML layer count matches detected layers
    if [ "$layer_count" -gt 0 ]; then
        local yaml_layer_count=0
        if [ -f "$yaml_file" ]; then
            # Count layers in YAML (lines starting with "  L" followed by number)
            yaml_layer_count=$(grep -E '^  L[0-9]+' "$yaml_file" 2>/dev/null | wc -l | tr -d ' ')
        fi
        
        if [ "$yaml_layer_count" -gt 0 ]; then
            if [ "$yaml_layer_count" -eq "$layer_count" ]; then
                print_success "YAML layer count matches detected layers ($layer_count)"
            else
                print_warning "Layer count mismatch: keymap.c has $layer_count layers, YAML has $yaml_layer_count layers"
                print_info "This may be normal if some layers are empty or transparent"
            fi
        fi
    fi
    
    # Step 2.5: Update YAML and JSON with layer names
    print_info "Applying layer names to YAML and JSON..."
    
    # Re-extract layer names (in case they weren't extracted earlier)
    local layer_names=()
    local layer_index=0
    while IFS= read -r name; do
        if [ -n "$name" ]; then
            layer_names[layer_index]="$name"
            ((layer_index++)) || true
        fi
    done < <(extract_layer_names "$keymap_file")
    
    # Verify layer count matches
    if [ ${#layer_names[@]} -ne "$layer_count" ] && [ "$layer_count" -gt 0 ]; then
        print_warning "Layer count mismatch: detected $layer_count, extracted ${#layer_names[@]}"
    fi
    
    if [ ${#layer_names[@]} -gt 0 ]; then
        # Display layer summary
        print_info "Layer summary (${#layer_names[@]} total):"
        for i in "${!layer_names[@]}"; do
            print_info "  Layer $i: ${layer_names[i]}"
        done
        
        if update_yaml_layer_names "$yaml_file" "$keymap_file"; then
            print_success "Layer names applied to YAML"
        else
            print_warning "Could not apply layer names to YAML (will use L0, L1, etc.)"
        fi
        
        if update_json_layer_names "$json_file" "$keymap_file"; then
            print_success "Layer names metadata added to JSON"
        else
            print_info "JSON layer names update skipped (optional)"
        fi
    else
        print_warning "No layer names found in keymap.c (will use L0, L1, etc.)"
        if [ "$layer_count" -gt 0 ]; then
            print_info "Note: Detected $layer_count layers but could not extract names"
        fi
    fi
    
    # Step 3: Generate SVG via keymap draw
    print_step "5/6" "Generating SVG diagram..."
    
    local svg_file="$OUTPUT_DIR/keymap.svg"
    
    # Find info.json for layout information
    local info_json
    info_json=$(find_info_json "$SELECTED_KEYBOARD")
    
    # Check if keyboard is split and prepare config
    local config_file=""
    local draw_args=""
    
    if [ -n "$info_json" ] && is_split_keyboard "$info_json"; then
        print_info "Detected split keyboard layout"
        
        # Create temporary config file with split_gap
        # Use a larger gap (60px) for better visibility of split
        config_file=$(mktemp /tmp/keymap_config_XXXXXX.yaml)
        create_split_config "$config_file" "60.0"
        
        # Add config file to draw args
        draw_args="-c $config_file"
        
        print_success "Using split keyboard visualization (gap: 60px)"
    fi
    
    # Extract layout name from YAML if available
    local layout_name=""
    if [ -f "$yaml_file" ]; then
        # Extract layout_name from YAML format: layout: {qmk_keyboard: ..., layout_name: LAYOUT_91_ansi}
        # Use Python for reliable extraction
        if command -v python3 &> /dev/null; then
            layout_name=$(python3 << PYEOF 2>/dev/null
import re
import sys
try:
    with open('$yaml_file', 'r') as f:
        for line in f:
            if line.startswith('layout:'):
                # Match layout_name: followed by the value (alphanumeric and underscores)
                match = re.search(r'layout_name:\s*([A-Za-z0-9_]+)', line)
                if match:
                    print(match.group(1))
                    sys.exit(0)
except:
    pass
PYEOF
)
        else
            # Fallback to sed (less reliable)
            layout_name=$(grep -E "^layout:" "$yaml_file" | sed -E 's/.*layout_name:[[:space:]]*([A-Z0-9_]+).*/\1/' | head -1)
        fi
    fi
    
    # Add info.json to draw args if found
    if [ -n "$info_json" ]; then
        draw_args="$draw_args -j $info_json"
        print_info "Using layout from: $info_json"
        # Explicitly specify layout name if found in YAML
        if [ -n "$layout_name" ]; then
            draw_args="$draw_args -l $layout_name"
            print_info "Using layout name: $layout_name"
        fi
    fi
    
    # Generate SVG with appropriate arguments
    # Build command array for proper argument handling
    # Note: -c (config) is a GLOBAL option and must come BEFORE the subcommand
    local draw_cmd_array=("keymap")
    if [ -n "$config_file" ]; then
        draw_cmd_array+=("-c" "$config_file")
    fi
    draw_cmd_array+=("draw")
    if [ -n "$info_json" ]; then
        draw_cmd_array+=("-j" "$info_json")
        if [ -n "$layout_name" ]; then
            draw_cmd_array+=("-l" "$layout_name")
        fi
    fi
    draw_cmd_array+=("$yaml_file")
    
    # Capture both stdout and stderr to see errors
    local draw_error_output
    draw_error_output=$(mktemp /tmp/keymap_draw_error_XXXXXX.txt)
    
    if ! "${draw_cmd_array[@]}" > "$svg_file" 2> "$draw_error_output"; then
        print_error "Failed to generate SVG diagram"
        echo ""
        print_info "Command executed: ${draw_cmd_array[*]}"
        echo ""
        if [ -s "$draw_error_output" ]; then
            print_info "Error details:"
            cat "$draw_error_output" | while IFS= read -r line; do
                echo -e "  ${RED}$line${NC}"
            done
            echo ""
        fi
        print_info "This may indicate:"
        print_info "  - Invalid YAML structure"
        print_info "  - Layout detection issues"
        print_info "  - Missing keyboard layout definition"
        print_info "  - Config file format issues"
        rm -f "$draw_error_output"
        if [ -n "$config_file" ]; then
            rm -f "$config_file"
        fi
        if [ "$SAVE_YAML" = false ]; then
            rm -f "$yaml_file"
        fi
        exit 1
    fi
    
    rm -f "$draw_error_output"
    
    # Cleanup config file
    if [ -n "$config_file" ]; then
        rm -f "$config_file"
    fi
    
    print_success "Generated SVG: $svg_file"
    
    # Post-process SVG to add visual split gap if keyboard is split
    if [ -n "$info_json" ] && is_split_keyboard "$info_json"; then
        print_info "Post-processing SVG to add visual split gap..."
        add_split_gap_to_svg "$svg_file" "$info_json" "60.0"
    fi
    
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
    
    # Show layer count in summary if available
    local final_layer_count
    final_layer_count=$(count_layers "$SCRIPT_DIR/$SELECTED_KEYBOARD/keymaps/$SELECTED_KEYMAP/keymap.c" 2>/dev/null)
    if [ "$final_layer_count" -gt 0 ]; then
        echo -e "  Layers:   ${CYAN}$final_layer_count${NC} detected"
    fi
    
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
