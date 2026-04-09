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

# 3. Copy the font asset
echo ">>> Installing font asset..."
cp assets/font.ttf "$ASSETS_DIR/font.ttf"

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

# 6. Install to /usr/local/bin
echo ">>> Installing binaries to $INSTALL_DIR (this may require sudo)..."
sudo cp build/Vmips_top "$INSTALL_DIR/Vmips_top"
sudo cp build/double-l32-run "$INSTALL_DIR/"
sudo cp tools/assembler.py "$INSTALL_DIR/"
sudo cp build/double-l32-asm "$INSTALL_DIR/"

echo "============================================="
echo " Installation Complete!"
echo "============================================="
echo "You can now use the following commands from anywhere on your system:"
echo "  1. Assemble a program: double-l32-asm my_program.s my_program.hex"
echo "  2. Run the emulator:   double-l32-run my_program.hex"
