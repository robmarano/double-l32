# double-l32 Architecture Overview

## 1. System Architecture (Component Diagram)

The overall system bridges hardware simulation (via Verilator) and software I/O (via SDL2/C++). The `sim/main.cpp` wrapper handles window events and ticks the hardware clock.

```mermaid
flowchart TD
    %% Define Subgraphs
    subgraph Frontend [C++ Software Environment]
        A(SDL2 Window) -->|Keyboard Events| B(Main Simulation Loop)
        B -->|Phosphor Text Render| A
    end

    subgraph Hardware [SystemVerilog Hardware Environment]
        C(mips_top.sv)
        D(mips_core.sv)
        E(mmio_decoder.sv)
        F[(ram_dp.sv)]
        
        C --> D
        C --> E
        C --> F
        D <-->|Address/Data| E
        E <-->|Instruction/Data| F
    end

    %% Connections across boundary
    B -->|Tick Clock & +plusarg| C
    B -->|Write ASCII Key| E
    E -->|Write ASCII Char| B
```

## 2. Core CPU Architecture (Datapath)

The `mips_core.sv` module follows a classic single-cycle datapath, extended with custom support for HI/LO registers and parameterized shifts.

```mermaid
flowchart LR
    PC[Program Counter] -->|inst_addr_o| IM[Instruction Memory]
    IM -->|inst_data_i| CU(Control Unit)
    IM -->|inst_data_i| REG(Register File)
    
    CU -->|alu_control| ALU(ALU)
    CU -->|reg_write| REG
    CU -->|hilo_write| HILO(HI/LO Regs)
    
    REG -->|read_data1| ALU
    REG -->|read_data2| ALU
    ALU -->|alu_hi_out / alu_lo_out| HILO
    
    ALU -->|alu_result| MM(MMIO Decoder / RAM)
    REG -->|read_data2| MM
    MM -->|data_rdata_i| WB(Writeback Mux)
    WB -->|write_data| REG
```

## 3. Keyboard Echo Flow (Sequence Diagram)

This sequence illustrates what happens when a user types a key on their physical keyboard while the emulator is running.

```mermaid
sequenceDiagram
    participant User
    participant SDL2 as C++ Wrapper (SDL2)
    participant Core as MIPS CPU Core
    participant MMIO as MMIO Decoder
    
    User->>SDL2: Presses 'H' Key
    SDL2->>SDL2: Maps to ASCII 0x48
    SDL2->>MMIO: Writes 0x48 to mmio_keys_i (0x10001000)
    
    loop Every Clock Cycle
        Core->>MMIO: LW $t3, 0($t1) (Read 0x10001000)
        MMIO-->>Core: Returns 0x48
        
        Core->>Core: BNE $t3, $zero, proceed (Key detected!)
        
        Core->>MMIO: SW $t3, 0($t2) (Write 0x48 to 0x10000000)
        MMIO->>SDL2: mmio_screen_we_o is asserted!
        SDL2->>SDL2: Buffers 'H' into screen.data[0][0]
    end
    
    SDL2->>User: Renders Phosphor 'H' on Window
```
