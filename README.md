# ALU in Verilog #
This is a simple Arithmetic Logic Unit (ALU) written in Verilog that handles basic arithmetic, logical, comparison, and shift operations, supporting both signed and unsigned numbers.

## Motivation ##
I took on this project to refresh my digital design skills and to get some hands-on experience with Verilog, since I had mostly worked with VHDL before. Along the way, I also wanted to get comfortable with Vivado again and build something that could eventually scale into a more complex processor.

## Features ##
* 8-bit ALU (default) with the option to increase bit-width.
* Arithmetic operations: Addition, subtraction, multiplication, and division.
* Logical operations: AND, OR, XOR, NOR, NOT.
* Comparison operations: Greater than, less than, and equality checks.
* Shift operations: Logical and arithmetic shifts.
* Overflow detection and flag updates.

## How to Run ##
Load ALU.v and ALU_tb.v (included in this repo) into Vivado. Run the testbench, and check the Tcl console for printed results.

## Future Improvements ##
* Expand testbench to test for various bit configurations.
* Optimize design for FGPA implementation.
* Implement on FPGA board for validation.
* Expand into a larger processor design. 
