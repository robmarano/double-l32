#!/usr/bin/env bash

# Exit on any error
set -e

echo "============================================="
echo " Uninstalling double-l32 Emulator Toolbelt"
echo "============================================="

INSTALL_DIR="/usr/local/bin"
ASSETS_DIR="$HOME/.double-l32"

echo ">>> Removing binaries from $INSTALL_DIR (this may require sudo)..."
# Remove the emulator executable
if [ -f "$INSTALL_DIR/Vmips_top" ]; then
    sudo rm -f "$INSTALL_DIR/Vmips_top"
fi

# Remove the emulator wrapper
if [ -f "$INSTALL_DIR/double-l32-run" ]; then
    sudo rm -f "$INSTALL_DIR/double-l32-run"
fi

# Remove the assembler script
if [ -f "$INSTALL_DIR/assembler.py" ]; then
    sudo rm -f "$INSTALL_DIR/assembler.py"
fi

# Remove the assembler wrapper
if [ -f "$INSTALL_DIR/double-l32-asm" ]; then
    sudo rm -f "$INSTALL_DIR/double-l32-asm"
fi

# Remove the help wrapper
if [ -f "$INSTALL_DIR/double-l32-help" ]; then
    sudo rm -f "$INSTALL_DIR/double-l32-help"
fi

echo ">>> Removing assets directory $ASSETS_DIR..."
if [ -d "$ASSETS_DIR" ]; then
    rm -rf "$ASSETS_DIR"
fi

echo "============================================="
echo " Uninstallation Complete!"
echo "============================================="
