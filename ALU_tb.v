`timescale 1ns/1ps

module ALU_tb;

    // Parameters
    parameter NUM_BITS = 8;

    // Testbench Signals
    reg [NUM_BITS-1:0] A, B;
    reg signed_mode;
    reg [3:0] opcode;
    wire [NUM_BITS-1:0] Result;
    wire Z, N, C, V;

    // Instantiate the ALU
    ALU #(NUM_BITS) alu_inst (
        .A(A),
        .B(B),
        .signed_mode(signed_mode),
        .opcode(opcode),
        .Result(Result),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V)
    );

    // Task for running a single test case with signed/unsigned support
   integer test_counter=0; 
   task run_test(
    input [NUM_BITS-1:0] a,
    input [NUM_BITS-1:0] b,
    input s_mode,
    input [3:0] op,
    input signed [NUM_BITS-1:0] expected_result, 
    input expected_z,
    input expected_n,
    input expected_c,
    input expected_v
);
    reg signed [NUM_BITS-1:0] actual_result; 
    begin
        test_counter = test_counter+1; 
        A = a;
        B = b;
        signed_mode = s_mode;
        opcode = op;
        #10; // Wait for the result to settle

        if (signed_mode) begin
            actual_result = $signed(Result); // Interpret Result as signed
        end else begin
            actual_result = Result; // Treat Result as unsigned
        end

        // Verification and display
        $display("| %3d | %3d | %3d | %1b           | %04b     | %4d   | %1b  | %1b  | %1b  | %1b  |",
                  test_counter, A, B, signed_mode, opcode, actual_result, Z, N, C, V);

        if (actual_result !== expected_result) begin
            $fatal("Error: Result mismatch. Expected %d, got %d", expected_result, actual_result);
        end
        if (Z !== expected_z) begin
            $fatal("Error: Z mismatch. Expected %b, got %b", expected_z, Z);
        end
        if (N !== expected_n) begin
            $fatal("Error: N mismatch. Expected %b, got %b", expected_n, N);
        end
        if (C !== expected_c) begin
            $fatal("Error: C mismatch. Expected %b, got %b", expected_c, C);
        end
        if (V !== expected_v) begin
            $fatal("Error: V mismatch. Expected %b, got %b", expected_v, V);
        end
    end
 endtask


    initial begin
        // Print the header for the truth table
        $display("-------------------------------------------------------------");
        $display("| Line |   A  |  B  | Signed Mode | OpCode | Result | Z | N | C | V |");
        $display("-------------------------------------------------------------");

        // Edge Cases for Addition
        run_test(255, 1, 0, 4'b0000, 0, 1, 0, 1, 0);    // Unsigned addition
        run_test(0, 1, 0, 4'b0000, 1, 0, 0, 0, 0);      // Unsigned addition
        run_test(127, 1, 1, 4'b0000, -128, 0, 1, 0, 1); // Signed addition

        // Edge Cases for Subtraction
        run_test(128, 255, 1, 4'b0001, -127, 0, 1, 0, 0); // Signed subtraction
        run_test(0, 1, 0, 4'b0001, 255, 0, 0, 1, 0);      // Unsigned subtraction
        run_test(127, 255, 1, 4'b0001, -128, 0, 1, 0, 1); // Signed subtraction
       // passed above 
       
        // Edge Cases for Multiplication
        run_test(127, 2, 1, 4'b0010, 254, 0, 1, 0, 1);    // Signed multiplication
        run_test(127, 2, 0, 4'b0010, 254, 0, 0, 0, 0);    // Unsigned multiplication
        run_test(128, 2, 1, 4'b0010, 0, 1, 0, 0, 1);   // Signed multiplication

        // Edge Cases for Division
        run_test(255, 0, 0, 4'b0011, 0, 1, 0, 0, 1);      // Unsigned division by zero
        run_test(128, 255, 1, 4'b0011, 0, 1, 0, 0, 1); // Signed division

        // Logical Operations
        run_test(240, 15, 0, 4'b0100, 0, 1, 0, 0, 0);     // AND
        run_test(240, 15, 0, 4'b0101, 255, 0, 0, 0, 0);   // OR
        run_test(240, 15, 0, 4'b0110, 255, 0, 0, 0, 0);   // XOR
        run_test(240, 15, 0, 4'b0111, 0, 1, 0, 0, 0);     // NOR
        run_test(240, 0, 0, 4'b1000, 15, 0, 0, 0, 0);     // NOT (only A)

        // Comparisons
        run_test(255, 1, 0, 4'b1001, 1, 0, 0, 0, 0);    // Unsigned Greater Than (True)
        run_test(127, 255, 1, 4'b1001, 1, 0, 0, 0, 0);  // Signed Greater Than (False)
        run_test(1, 255, 0, 4'b1010, 1, 0, 0, 0, 0);    // Unsigned Less Than (True)
        run_test(128, 127, 1, 4'b1010, 1, 0, 0, 0, 0);  // Signed Less Than (True)
        
        // Shift Operations
        run_test(128, 0, 0, 4'b1100, 0, 1, 0, 1, 0);      // Logical Left Shift
        run_test(1, 0, 0, 4'b1101, 0, 1, 0, 1, 0);        // Logical Right Shift
        run_test(128, 0, 1, 4'b1110, 192, 0, 1, 0, 0);    // Arithmetic Right Shift

        $display("-------------------------------------------------------------");
        $finish;
    end
endmodule
