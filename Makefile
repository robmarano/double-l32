# Makefile for double-l32 Emulator

# Project settings
PROJECT = double-l32
TOP_MODULE = mips_top

# Directories
SRC_DIR = src
SIM_DIR = sim
BUILD_DIR = build

# Source files
SV_SOURCES = $(wildcard $(SRC_DIR)/*.sv)
CPP_SOURCES = $(wildcard $(SIM_DIR)/*.cpp)

# Test files
TEST_SV = test/alu_regfile_tb.sv
TEST_CPP = test/test_alu_regfile.cpp

# Verilator settings
VERILATOR = verilator
VFLAGS = --cc --exe --build -j 0 -Wall -Wno-DECLFILENAME -Mdir $(BUILD_DIR) --top-module $(TOP_MODULE)

# SDL2 Flags
SDL2_CFLAGS = $(shell sdl2-config --cflags)
SDL2_LDFLAGS = $(shell sdl2-config --libs) -lSDL2_ttf
VFLAGS += -CFLAGS "$(SDL2_CFLAGS)" -LDFLAGS "$(SDL2_LDFLAGS)"

.PHONY: all clean run test_alu

# Default target
all: $(BUILD_DIR)/V$(TOP_MODULE)

# Build the executable
$(BUILD_DIR)/V$(TOP_MODULE): $(SV_SOURCES) $(CPP_SOURCES)
	@echo "Building Verilator model..."
	$(VERILATOR) $(VFLAGS) $(SV_SOURCES) $(CPP_SOURCES)

# Run the simulation
run: all
	@echo "Running simulation..."
	./$(BUILD_DIR)/V$(TOP_MODULE)

# Run ALU/Regfile Unit Test
test_alu: $(SV_SOURCES) $(TEST_SV) $(TEST_CPP)
	@echo "Building ALU/Regfile testbench..."
	$(VERILATOR) --cc --exe --build -j 0 -Wall -Wno-DECLFILENAME -Mdir $(BUILD_DIR)_test \
		--top-module alu_regfile_tb $(SRC_DIR)/alu.sv $(SRC_DIR)/regfile.sv $(TEST_SV) $(TEST_CPP)
	@echo "Running ALU/Regfile unit test..."
	./$(BUILD_DIR)_test/Valu_regfile_tb

# Clean build artifacts
clean:
	@echo "Cleaning up..."
	rm -rf $(BUILD_DIR)
