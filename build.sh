#!/bin/bash
#
# QMK Custom Firmware Build Script
#
# This script builds custom keyboard firmware using QMK.
# Workflow: copy keyboard to QMK → compile → retrieve firmware → cleanup
#
# Usage: ./build.sh
#

set -e  # Exit on error

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QMK_FIRMWARE_DIR="$HOME/qmk_firmware"
QMK_KEYBOARDS_DIR="$QMK_FIRMWARE_DIR/keyboards"
DEFAULT_KEYMAP="j-custom"

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

check_prerequisites() {
    print_step "1/5" "Checking prerequisites..."
    
    # Check QMK CLI
    if ! command -v qmk &> /dev/null; then
        print_error "QMK CLI not found. Please install QMK first."
        print_info "Run: bash init/qmk_install.sh"
        exit 1
    fi
    print_success "QMK CLI found: $(qmk --version 2>/dev/null)"
    
    # Check QMK firmware directory
    if [ ! -d "$QMK_FIRMWARE_DIR" ]; then
        print_error "QMK firmware directory not found at: $QMK_FIRMWARE_DIR"
        print_info "Run: qmk setup"
        exit 1
    fi
    print_success "QMK firmware directory found"
    
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
# Flash instruction functions
# =============================================================================

# Find FLASH_INSTRUCTION.md for a keyboard
# Looks for it at the keyboard base level (e.g., keychron/q11/FLASH_INSTRUCTION.md)
# or variant level (e.g., keychron/q11/ansi_encoder/FLASH_INSTRUCTION.md)
find_flash_instruction() {
    local keyboard_path="$1"
    local vendor_model=$(dirname "$keyboard_path")
    
    # First try at keyboard base level (applies to all variants)
    local base_instruction="$SCRIPT_DIR/$vendor_model/FLASH_INSTRUCTION.md"
    if [ -f "$base_instruction" ]; then
        echo "$base_instruction"
        return 0
    fi
    
    # Fallback to variant-specific level
    local variant_instruction="$SCRIPT_DIR/$keyboard_path/FLASH_INSTRUCTION.md"
    if [ -f "$variant_instruction" ]; then
        echo "$variant_instruction"
        return 0
    fi
    
    return 1
}

# Check for FLASH_INSTRUCTION.md and warn if missing
check_flash_instruction() {
    local keyboard_path="$1"
    local instruction_file
    
    if instruction_file=$(find_flash_instruction "$keyboard_path"); then
        FLASH_INSTRUCTION_FILE="$instruction_file"
        return 0
    else
        FLASH_INSTRUCTION_FILE=""
        print_warning "FLASH_INSTRUCTION.md not found for $keyboard_path"
        print_info "Consider creating FLASH_INSTRUCTION.md at:"
        local vendor_model=$(dirname "$keyboard_path")
        echo "  - $SCRIPT_DIR/$vendor_model/FLASH_INSTRUCTION.md (recommended, applies to all variants)"
        echo "  - $SCRIPT_DIR/$keyboard_path/FLASH_INSTRUCTION.md (variant-specific)"
        echo ""
        return 1
    fi
}

# Display flash instructions from FLASH_INSTRUCTION.md
display_flash_instructions() {
    if [ -n "$FLASH_INSTRUCTION_FILE" ] && [ -f "$FLASH_INSTRUCTION_FILE" ]; then
        echo ""
        print_info "Bootloader Mode Instructions:"
        echo ""
        # Display the content, skipping the first line (title) for cleaner output
        # Show from line 2 onwards, or all if no title
        tail -n +2 "$FLASH_INSTRUCTION_FILE" 2>/dev/null || cat "$FLASH_INSTRUCTION_FILE"
        echo ""
    else
        # Fallback to generic message
        echo ""
        print_info "Make sure your keyboard is in bootloader mode (hold Esc while plugging in)."
        echo ""
    fi
}

# =============================================================================
# Menu functions
# =============================================================================

# Display keyboard selection menu
select_keyboard() {
    print_header "Select Keyboard to Build"
    
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
    
    # Check for FLASH_INSTRUCTION.md
    check_flash_instruction "$SELECTED_KEYBOARD"
    
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
    local default_index=0
    for km in "${keymaps[@]}"; do
        if [ "$km" = "$DEFAULT_KEYMAP" ]; then
            printf "  ${CYAN}%2d)${NC} %s ${GREEN}[default]${NC}\n" "$i" "$km"
            default_index=$i
        else
            printf "  ${CYAN}%2d)${NC} %s\n" "$i" "$km"
        fi
        ((i++)) || true
    done
    
    echo ""
    
    # If j-custom exists, show Enter option
    if [ $default_index -gt 0 ]; then
        printf "Enter selection [1-%d] (press Enter for %s): " "${#keymaps[@]}" "$DEFAULT_KEYMAP"
    else
        printf "Enter selection [1-%d]: " "${#keymaps[@]}"
    fi
    read -r selection
    
    # Handle empty input (use default)
    if [ -z "$selection" ]; then
        if [ $default_index -gt 0 ]; then
            selection=$default_index
        else
            selection=1
        fi
    fi
    
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

# =============================================================================
# Build workflow functions
# =============================================================================

# Copy keyboard files to QMK directory
copy_to_qmk() {
    print_step "2/5" "Copying keyboard files to QMK..."
    
    # Parse keyboard path (e.g., keychron/q11/ansi_encoder)
    # We need to copy the vendor directory (e.g., keychron/q11)
    local kb_path="$SELECTED_KEYBOARD"
    
    # Extract vendor/model (everything up to the variant)
    # e.g., from "keychron/q11/ansi_encoder" get "keychron/q11"
    local vendor_model=$(dirname "$kb_path")
    local vendor=$(echo "$vendor_model" | cut -d'/' -f1)
    
    SOURCE_DIR="$SCRIPT_DIR/$vendor_model"
    TARGET_DIR="$QMK_KEYBOARDS_DIR/$vendor_model"
    BACKUP_DIR=""
    
    # Check if target already exists in QMK
    if [ -d "$TARGET_DIR" ]; then
        # Check if it's our previous build copy
        if [ -f "$TARGET_DIR/.my_qmk_backup" ]; then
            print_warning "Previous build files found. Cleaning up first..."
            rm -rf "$TARGET_DIR"
        else
            # This is the original QMK keyboard - back it up
            BACKUP_DIR="${TARGET_DIR}.original_backup"
            
            # Remove stale backup if exists
            if [ -d "$BACKUP_DIR" ]; then
                rm -rf "$BACKUP_DIR"
            fi
            
            print_info "Backing up original QMK keyboard..."
            mv "$TARGET_DIR" "$BACKUP_DIR"
            print_success "Original backed up to: $BACKUP_DIR"
        fi
    fi
    
    # Create parent directory and copy
    mkdir -p "$(dirname "$TARGET_DIR")"
    cp -R "$SOURCE_DIR" "$TARGET_DIR"
    
    # Create marker file to identify our copy
    echo "Copied by my-qmk build script on $(date)" > "$TARGET_DIR/.my_qmk_backup"
    
    print_success "Copied to: $TARGET_DIR"
}

# Compile firmware using QMK
compile_firmware() {
    print_step "3/5" "Compiling firmware..."
    echo ""
    
    # Build the keyboard path for QMK (vendor/model/variant)
    local qmk_keyboard="$SELECTED_KEYBOARD"
    
    print_info "Running: qmk compile -kb $qmk_keyboard -km $SELECTED_KEYMAP"
    echo ""
    
    # Run compilation (this will output to QMK's default location)
    if ! qmk compile -kb "$qmk_keyboard" -km "$SELECTED_KEYMAP"; then
        print_error "Compilation failed!"
        cleanup_qmk
        exit 1
    fi
    
    echo ""
    print_success "Compilation successful!"
}

# Retrieve compiled firmware
retrieve_firmware() {
    print_step "4/5" "Retrieving firmware..."
    
    # QMK outputs firmware to the qmk_firmware root directory
    # Filename format: keyboard_name_keymap.bin (with / replaced by _)
    local kb_name=$(echo "$SELECTED_KEYBOARD" | tr '/' '_')
    
    # Look for firmware files
    local firmware_files=()
    local fi=0
    for ext in bin uf2 hex; do
        local firmware_file="$QMK_FIRMWARE_DIR/${kb_name}_${SELECTED_KEYMAP}.${ext}"
        if [ -f "$firmware_file" ]; then
            firmware_files[fi]="$firmware_file"
            ((fi++)) || true
        fi
    done
    
    if [ ${#firmware_files[@]} -eq 0 ]; then
        print_warning "No firmware file found. Looking for alternatives..."
        # Try to find any matching firmware
        for ext in bin uf2 hex; do
            for f in "$QMK_FIRMWARE_DIR"/*"${SELECTED_KEYMAP}"*."${ext}"; do
                if [ -f "$f" ]; then
                    firmware_files[fi]="$f"
                    ((fi++)) || true
                fi
            done
        done
    fi
    
    if [ ${#firmware_files[@]} -eq 0 ]; then
        print_error "Could not find compiled firmware!"
        cleanup_qmk
        exit 1
    fi
    
    # Create output directory in source location
    OUTPUT_DIR="$SCRIPT_DIR/$SELECTED_KEYBOARD"
    
    # Copy firmware files to source directory
    for firmware_file in "${firmware_files[@]}"; do
        local filename=$(basename "$firmware_file")
        cp "$firmware_file" "$OUTPUT_DIR/"
        print_success "Firmware saved: $OUTPUT_DIR/$filename"
        
        # Remove from QMK directory
        rm "$firmware_file"
    done
}

# Cleanup copied files from QMK
cleanup_qmk() {
    print_step "5/5" "Cleaning up QMK directory..."
    
    if [ -d "$TARGET_DIR" ]; then
        # Verify it's our copy (has marker file)
        if [ -f "$TARGET_DIR/.my_qmk_backup" ]; then
            rm -rf "$TARGET_DIR"
            print_success "Removed build files: $TARGET_DIR"
            
            # Restore original backup if it exists
            if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
                mv "$BACKUP_DIR" "$TARGET_DIR"
                print_success "Restored original QMK keyboard"
            else
                # Clean up empty parent directories if no backup
                local parent=$(dirname "$TARGET_DIR")
                if [ -d "$parent" ] && [ -z "$(ls -A "$parent")" ]; then
                    rmdir "$parent" 2>/dev/null || true
                fi
            fi
        else
            print_warning "Skipping cleanup - directory may contain original QMK files"
        fi
    elif [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        # Target was removed but backup exists - restore it
        mv "$BACKUP_DIR" "$TARGET_DIR"
        print_success "Restored original QMK keyboard"
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header "QMK Custom Firmware Builder"
    
    # Initialize global variables
    keyboards=()
    BACKUP_DIR=""
    FLASH_INSTRUCTION_FILE=""
    
    # Run build workflow
    check_prerequisites
    select_keyboard
    select_keymap
    copy_to_qmk
    compile_firmware
    retrieve_firmware
    cleanup_qmk
    
    # Final summary
    print_header "Build Complete!"
    echo -e "  Keyboard: ${CYAN}$SELECTED_KEYBOARD${NC}"
    echo -e "  Keymap:   ${CYAN}$SELECTED_KEYMAP${NC}"
    echo -e "  Output:   ${GREEN}$OUTPUT_DIR/${NC}"
    echo ""
    
    # Construct the firmware filename (keyboard path with / replaced by _)
    local kb_name=$(echo "$SELECTED_KEYBOARD" | tr '/' '_')
    local firmware_file="${OUTPUT_DIR}/${kb_name}_${SELECTED_KEYMAP}.bin"
    
    # Display flash instructions from FLASH_INSTRUCTION.md first (if available)
    display_flash_instructions
    
    # Show copy-pasteable flash command
    print_info "To flash your keyboard, run:"
    echo ""
    echo -e "  ${GREEN}qmk flash ${firmware_file}${NC}"
    echo ""
}

# Run main function
main "$@"
