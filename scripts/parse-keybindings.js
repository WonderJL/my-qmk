#!/usr/bin/env node

const fs = require('fs');

const keybindingsFile = '/tmp/cursor-default-keybindings.json';

if (!fs.existsSync(keybindingsFile)) {
  console.error('Keybindings file not found. Please download it first.');
  process.exit(1);
}

// Read and strip comments
let content = fs.readFileSync(keybindingsFile, 'utf8');
// Remove single-line comments
content = content.replace(/\/\/.*$/gm, '');
// Remove multi-line comments (if any)
content = content.replace(/\/\*[\s\S]*?\*\//g, '');
const keybindings = JSON.parse(content);

// Filter for cmd+k keybindings
const cmdKKeybindings = keybindings.filter(k => 
  k.key && k.key.toLowerCase().includes('cmd+k')
);

// Sort by key
cmdKKeybindings.sort((a, b) => {
  if (a.key < b.key) return -1;
  if (a.key > b.key) return 1;
  return 0;
});

console.log(`Total keybindings: ${keybindings.length}`);
console.log(`Cmd+K keybindings: ${cmdKKeybindings.length}\n`);

// Create markdown table
console.log('## Cmd+K Keybindings\n');
console.log('| Keybinding | Command | When | Source |');
console.log('|------------|---------|------|--------|');

cmdKKeybindings.forEach(k => {
  const key = k.key || '-';
  const command = k.command || '-';
  const when = k.when || '-';
  const source = 'Default';
  console.log(`| \`${key}\` | \`${command}\` | ${when} | ${source} |`);
});

// Also create full list
console.log('\n\n## All Keybindings (Sample - First 50)\n');
console.log('| Keybinding | Command | When | Source |');
console.log('|------------|---------|------|--------|');

keybindings.slice(0, 50).forEach(k => {
  const key = k.key || '-';
  const command = k.command || '-';
  const when = k.when || '-';
  const source = 'Default';
  console.log(`| \`${key}\` | \`${command}\` | ${when} | ${source} |`);
});

console.log(`\n\n... and ${keybindings.length - 50} more keybindings`);
