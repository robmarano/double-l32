---
name: mips-textbooks
description: Reference skill for MIPS architecture, Verilog HDL, and computer organization theory. Use when needing deep theoretical knowledge, MIPS assembly reference, CPU design strategies, or Verilog hardware implementation examples.
---

# MIPS Textbooks Reference

## Overview

This skill provides a curated library of academic textbooks and reference materials regarding MIPS architecture, Computer Organization, and Verilog HDL. 

Whenever you need foundational theory, specific MIPS instruction encoding details, cache/memory hierarchy design strategies, or Verilog coding examples for hardware logic, you can consult these resources.

## Available Textbooks (Absolute Paths)

You can use the `read_file` tool to read the contents of these PDF files. 

### Computer Architecture & Organization
*   **Computer Organization and Design MIPS Edition (6th Ed.)**
    *   `/Users/rob/dev/robmarano.github.io/COaD-MIPS-6ed.pdf`
*   **Computer Organization and Embedded Systems (Hamacher, Vranesic, Zaky, Manjikian, 6th Ed.)**
    *   `/Users/rob/dev/robmarano.github.io/Computer.Organization.and.Embedded.Systems,.Hamacher,.Vranesic,..Zaky,.Manjikian,.6ed,.MGH,.2012.pdf`
*   **Digital Design and Computer Architecture (2nd Edition, Harris & Harris)**
    *   `/Users/rob/dev/robmarano.github.io/Digital Design and Computer Architecture - 2nd Edition - Harris.pdf`
*   **Computer Organization with MIPS**
    *   `/Users/rob/dev/robmarano.github.io/courses/ece251/mips/Computer Organization with MIPS.pdf`

### Verilog & Digital Design
*   **Digital Design and Verilog HDL Fundamentals**
    *   `/Users/rob/dev/robmarano.github.io/Digital Design and Verilog HDL Fundamentals.pdf`
*   **Structural Design with Verilog (Harris)**
    *   `/Users/rob/dev/robmarano.github.io/Structural Design with Verilog - Harris.pdf`
*   **Verilog HDL Design Examples**
    *   `/Users/rob/dev/robmarano.github.io/Verilog HDL Design Examples.pdf`

### MIPS Assembly & System Level
*   **See MIPS Run**
    *   `/Users/rob/dev/robmarano.github.io/courses/ece251/mips/See MIPS Run book.pdf`
*   **MIPS Assembly Programming (Britton)**
    *   `/Users/rob/dev/robmarano.github.io/courses/ece251/mips/MIPS Assembly Programming - Britton.pdf`

## How to Consult These Books

1.  **Tool Usage:** Use the `read_file` tool and pass the absolute path of the desired book.
2.  **Handling Size Limits:** Because these are large textbooks, the `read_file` tool will automatically truncate output exceeding 2000 lines. 
3.  **Pagination:** To navigate these books efficiently, always use the `start_line` and `end_line` parameters in your `read_file` tool call to read specific sections or chapters once you locate the table of contents.
4.  **Searching:** Since they are local PDFs, `grep_search` may not be able to search the raw binary PDF data effectively. Rely on `read_file` to parse the PDF to text, reading the table of contents first to find the relevant pages/lines.
