# Flash Instructions for Keychron Q11

## Entering Bootloader Mode

The Keychron Q11 is a split keyboard, and **each side must be flashed individually**.

### Master Side (Left)
To enter bootloader mode on the **master side**:
1. **Hold down the ESC key** (top row, second key from the left, right after the left encoder)
2. While holding the ESC key, **plug in the USB cable** to the master side
3. Release the key once the keyboard enters bootloader mode

### Slave Side (Right)
To enter bootloader mode on the **slave side**:
1. **Hold down the DEL key** (top row, on the right side, just before the right encoder)
2. While holding the DEL key, **plug in the USB cable** to the slave side
3. Release the key once the keyboard enters bootloader mode

## Flashing Firmware

After entering bootloader mode, you can flash the firmware using:

```bash
qmk flash <firmware_file>
```

**Important Notes:**
- Flash the master side first, then the slave side
- Make sure the keyboard is in bootloader mode before running the flash command
- The keyboard will automatically exit bootloader mode after successful flashing
