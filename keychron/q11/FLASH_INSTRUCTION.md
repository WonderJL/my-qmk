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
1. **Hold down the DEL key** (top row, on the right side, just before the right encoder - it's the key between INS and the right encoder/mute key)
2. While holding the DEL key, **plug in the USB cable** to the slave side
3. Release the key once the keyboard enters bootloader mode

**Important:** This method uses **physical key positions** (hardware-level), so it works regardless of what your keymap is programmed to do. Even if you've remapped DEL to something else, holding the physical DEL key position while plugging in USB will still work.

## Alternative Method: Using Hardware Reset Button

If you're having trouble with the key-holding method, you can use the hardware reset button located on the PCB:

### Master Side (Left)
To enter bootloader mode using the reset button on the **master side**:
1. **Remove the left space bar keycap** to access the PCB
2. **Locate the reset button** on the left side of the space bar switch on the PCB
3. **Press down and hold the reset button**
4. While holding the reset button, **plug in the USB cable** to the master side
5. Release the reset button once the keyboard enters bootloader mode

### Slave Side (Right)
To enter bootloader mode using the reset button on the **slave side**:
1. **Remove the right space bar keycap** to access the PCB
2. **Locate the reset button** on the left side of the space bar switch on the PCB
3. **Press down and hold the reset button**
4. While holding the reset button, **plug in the USB cable** to the slave side
5. Release the reset button once the keyboard enters bootloader mode

**Note:** The reset button method is a reliable alternative if the key-holding method doesn't work, and it doesn't require any specific keymap configuration.

## Flashing Firmware

After entering bootloader mode, you can flash the firmware using:

```bash
qmk flash <firmware_file>
```

**Important Notes:**
- Flash the master side first, then the slave side
- Make sure the keyboard is in bootloader mode before running the flash command
- The keyboard will automatically exit bootloader mode after successful flashing

## Troubleshooting

If you're having trouble entering bootloader mode on the right side:

1. **Verify the DEL key position**: The DEL key is in the top row, between the INS key and the right encoder/mute key. Make sure you're holding the correct physical key.

2. **Check USB connection**: Ensure the USB cable is plugged directly into the **right side** of the keyboard (not the left side).

3. **Timing**: Hold the DEL key **before** plugging in the USB cable, and keep holding it until the keyboard enters bootloader mode (usually indicated by the keyboard appearing as a USB device).

4. **Try unplugging and replugging**: Sometimes you need to unplug the keyboard completely, then hold DEL and plug it back in.

5. **Check if keyboard is detected**: After entering bootloader mode, the keyboard should appear as a USB device. You can verify this with `lsusb` (Linux) or System Information (macOS).

## Additional Resources

For official Keychron documentation and detailed instructions on factory reset and firmware flashing using QMK Toolbox, refer to:

- [Keychron Q11 Factory Reset and Firmware Flashing Guide](https://keychron.ca/pages/how-to-factory-reset-or-flash-firmware-for-your-keychron-q11-keyboard)
