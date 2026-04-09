#!/usr/bin/env bash

# Exit on any error
set -e

echo "============================================="
echo " Installing double-l32 Emulator Toolbelt"
echo "============================================="

# Ensure we are in the project root
if [ ! -f "Makefile" ] || [ ! -d "src" ]; then
    echo "Error: Please run this script from the root of the double-l32 repository."
    exit 1
fi

# 1. Compile the Emulator
echo ">>> Building the emulator..."
make all

# 2. Define Installation Paths
INSTALL_DIR="/usr/local/bin"
ASSETS_DIR="$HOME/.double-l32"

echo ">>> Creating assets directory at $ASSETS_DIR..."
mkdir -p "$ASSETS_DIR"

# 3. Copy assets, docs, and examples
echo ">>> Installing assets, documentation, and examples..."
cp assets/font.ttf "$ASSETS_DIR/font.ttf"

mkdir -p "$ASSETS_DIR/docs"
cp docs/green_sheet.md "$ASSETS_DIR/docs/green_sheet.md"
cp docs/USAGE.md "$ASSETS_DIR/docs/USAGE.md"

mkdir -p "$ASSETS_DIR/examples"
cp asm/*.s "$ASSETS_DIR/examples/"
cp roms/*.hex "$ASSETS_DIR/examples/"

# 4. Create the wrapper script for the Emulator
echo ">>> Creating 'double-l32-run' wrapper script..."
cat << 'EOF' > build/double-l32-run
#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: double-l32-run <path_to_rom.hex>"
    exit 1
fi

# Set the font path for the emulator
export DOUBLE_L32_FONT="$HOME/.double-l32/font.ttf"

# Locate the actual compiled binary (installed alongside this wrapper)
BIN_PATH="$(dirname "$0")/Vmips_top"

# Run it with the +rom argument
exec "$BIN_PATH" "+rom=$1"
EOF

chmod +x build/double-l32-run

# 5. Create the wrapper script for the Assembler
echo ">>> Creating 'double-l32-asm' wrapper script..."
cat << 'EOF' > build/double-l32-asm
#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
    echo "Usage: double-l32-asm <input.s> <output.hex>"
    exit 1
fi

# Locate the python assembler script (installed alongside this wrapper)
ASM_PATH="$(dirname "$0")/assembler.py"

python3 "$ASM_PATH" "$1" "$2"
EOF

chmod +x build/double-l32-asm

# 6. Create a helper command
echo ">>> Creating 'double-l32-help' wrapper script..."
cat << 'EOF' > build/double-l32-help
#!/usr/bin/env bash
echo "============================================="
echo " double-l32 Emulator Toolbelt "
echo "============================================="
echo "Commands:"
echo "  double-l32-asm <in.s> <out.hex>  : Compile MIPS assembly"
echo "  double-l32-run <out.hex>         : Run emulator"
echo "  double-l32-help                  : Show this message"
echo ""
echo "Documentation & Examples installed at: $HOME/.double-l32/"
echo "  Usage Guide: cat $HOME/.double-l32/docs/USAGE.md"
echo "  Green Sheet: cat $HOME/.double-l32/docs/green_sheet.md"
echo "  Examples:    ls $HOME/.double-l32/examples/"
echo "============================================="
EOF

chmod +x build/double-l32-help

# 7. Install to /usr/local/bin
echo ">>> Installing binaries to $INSTALL_DIR (this may require sudo)..."
sudo cp build/Vmips_top "$INSTALL_DIR/Vmips_top"
sudo cp build/double-l32-run "$INSTALL_DIR/"
sudo cp tools/assembler.py "$INSTALL_DIR/"
sudo cp build/double-l32-asm "$INSTALL_DIR/"
sudo cp build/double-l32-help "$INSTALL_DIR/"

echo "============================================="
echo " Installation Complete!"
echo "============================================="
echo "Run 'double-l32-help' to get started."
