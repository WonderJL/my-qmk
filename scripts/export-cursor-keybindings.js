#!/usr/bin/env node

/**
 * Script to export all Cursor IDE keybindings
 * This script attempts to read keybindings from Cursor's configuration
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const CURSOR_USER_DIR = path.join(
  process.env.HOME,
  'Library/Application Support/Cursor/User'
);

const KEYBINDINGS_FILE = path.join(CURSOR_USER_DIR, 'keybindings.json');

console.log('Exporting Cursor IDE Keybindings...\n');

// Read user keybindings
let userKeybindings = [];
if (fs.existsSync(KEYBINDINGS_FILE)) {
  try {
    const content = fs.readFileSync(KEYBINDINGS_FILE, 'utf8');
    userKeybindings = JSON.parse(content);
    console.log(`Found ${userKeybindings.length} custom keybindings\n`);
  } catch (e) {
    console.error('Error reading keybindings.json:', e.message);
  }
}

// Note: To get ALL default keybindings, you need to:
// 1. Open Cursor IDE
// 2. Press Cmd+Shift+P
// 3. Type "Preferences: Open Default Keyboard Shortcuts (JSON)"
// 4. Copy the contents

console.log('To get ALL default keybindings:');
console.log('1. Open Cursor IDE');
console.log('2. Press Cmd+Shift+P');
console.log('3. Type "Preferences: Open Default Keyboard Shortcuts (JSON)"');
console.log('4. Copy the contents\n');

console.log('User keybindings file location:');
console.log(KEYBINDINGS_FILE);
