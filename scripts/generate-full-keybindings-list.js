#!/usr/bin/env node

const fs = require('fs');

const keybindingsFile = '/tmp/cursor-default-keybindings.json';

if (!fs.existsSync(keybindingsFile)) {
  console.error('Keybindings file not found. Please download it first.');
  process.exit(1);
}

// Read and strip comments
let content = fs.readFileSync(keybindingsFile, 'utf8');
content = content.replace(/\/\/.*$/gm, '');
content = content.replace(/\/\*[\s\S]*?\*\//g, '');
const keybindings = JSON.parse(content);

// Sort by key, then by command
keybindings.sort((a, b) => {
  const keyA = (a.key || '').toLowerCase();
  const keyB = (b.key || '').toLowerCase();
  if (keyA < keyB) return -1;
  if (keyA > keyB) return 1;
  const cmdA = (a.command || '').toLowerCase();
  const cmdB = (b.command || '').toLowerCase();
  if (cmdA < cmdB) return -1;
  if (cmdA > cmdB) return 1;
  return 0;
});

// Filter for cmd+k keybindings
const cmdKKeybindings = keybindings.filter(k => 
  k.key && k.key.toLowerCase().includes('cmd+k')
);

const output = [];

output.push('# Cursor IDE - Complete Keyboard Shortcuts Reference');
output.push('');
output.push(`**Total Keybindings:** ${keybindings.length}`);
output.push(`**Cmd+K Keybindings:** ${cmdKKeybindings.length}`);
output.push('');
output.push('---');
output.push('');
output.push('## Table of Contents');
output.push('');
output.push('1. [Cmd+K Keybindings](#cmdk-keybindings)');
output.push('2. [All Keybindings](#all-keybindings)');
output.push('');
output.push('---');
output.push('');
output.push('## Cmd+K Keybindings');
output.push('');
output.push('| Keybinding | Command | When | Source |');
output.push('|------------|---------|------|--------|');

cmdKKeybindings.forEach(k => {
  const key = k.key ? `\`${k.key}\`` : '-';
  const command = k.command ? `\`${k.command}\`` : '-';
  const when = k.when || '-';
  const source = 'Default';
  output.push(`| ${key} | ${command} | ${when} | ${source} |`);
});

output.push('');
output.push('---');
output.push('');
output.push('## All Keybindings');
output.push('');
output.push('| Keybinding | Command | When | Source |');
output.push('|------------|---------|------|--------|');

keybindings.forEach(k => {
  const key = k.key ? `\`${k.key}\`` : '-';
  const command = k.command ? `\`${k.command}\`` : '-';
  const when = k.when || '-';
  const source = 'Default';
  output.push(`| ${key} | ${command} | ${when} | ${source} |`);
});

const outputPath = '/Users/j.leung/workspace/code/keyboard/my-qmk/specs/keychron/q11/custom-refs/keymapping/cursor-keybindings-full-list.md';
fs.writeFileSync(outputPath, output.join('\n'));

console.log(`Generated full keybindings list: ${outputPath}`);
console.log(`Total keybindings: ${keybindings.length}`);
console.log(`Cmd+K keybindings: ${cmdKKeybindings.length}`);
