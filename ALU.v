module ALU #(parameter NUM_BITS = 8) (
    input [NUM_BITS-1:0] A,
    input [NUM_BITS-1:0] B, 
    input signed_mode,
    input [3:0] opcode,
    output reg [NUM_BITS-1:0] Result,
    output reg Z, N, C, V
);
    reg signed [2*NUM_BITS-1:0] s_mult_result; 
    reg [2*NUM_BITS-1:0] us_mult_result; 
    reg signed [NUM_BITS:0] temp_result;
    reg signed [NUM_BITS-1:0] signed_A, signed_B;

    always @(*) begin
        Z = 0; N = 0; C = 0; V = 0;
        Result = {NUM_BITS{1'b0}};
        
        signed_A = $signed(A); 
        signed_B = $signed(B);

        case (opcode)
            // Addition
            4'b0000: begin
                if (signed_mode) begin
                    temp_result = signed_A + signed_B;
                    Result = temp_result[NUM_BITS-1:0];
                    V = ((signed_A[NUM_BITS-1] == signed_B[NUM_BITS-1]) 
                        && (signed_A[NUM_BITS-1] != Result[NUM_BITS-1]));
                end else begin
                    {C, Result} = A + B;
                end
            end

            // Subtraction
            4'b0001: begin
                if (signed_mode) begin
                    temp_result = signed_A - signed_B;
                    Result = temp_result[NUM_BITS-1:0];
                    V = (signed_A[NUM_BITS-1] != signed_B[NUM_BITS-1]) 
                        && (signed_A[NUM_BITS-1] != Result[NUM_BITS-1]);
                end else begin
                    {C, Result} = A - B;
                end
            end
            
            // Multiplication
            4'b0010: begin
                if (signed_mode) begin
                    s_mult_result = signed_A * signed_B;
                    Result = s_mult_result[NUM_BITS-1:0];
                    V = (s_mult_result[2*NUM_BITS-1:NUM_BITS] != {NUM_BITS{s_mult_result[NUM_BITS-1]}});
                    N = Result[NUM_BITS-1];
                    $display("A = %d, B = %d, s_mult_result = %d, us_mult_result = %d, Result = %d, N = %b, V = %b, C = %b",
                    A, B, s_mult_result, us_mult_result, Result, N, V, C);

                end else begin
                    us_mult_result = A * B;
                    Result = us_mult_result[NUM_BITS-1:0];
                    C = |us_mult_result[2*NUM_BITS-1:NUM_BITS];
                    N = 0;
                    V = 0;
                    $display("A = %d, B = %d, s_mult_result = %d, us_mult_result = %d, Result = %d, N = %b, V = %b, C = %b",
                     A, B, s_mult_result, us_mult_result, Result, N, V, C);

                end
            end


            // Division
            4'b0011: begin
                if (B == 0) begin
                    V = 1; // Division by zero error
                    Result = {NUM_BITS{1'b0}};
                end else if (signed_mode) begin
                    if ((signed_A == -(1 << (NUM_BITS - 1))) && (signed_B == -1)) begin
                        V = 1; // Overflow on signed division
                        Result = {NUM_BITS{1'b0}};
                    end else begin
                        Result = signed_A / signed_B;
                    end
                end else begin
                    Result = A / B;
                end
            end


            // Logical Operations
            4'b0100: Result = A & B; // AND
            4'b0101: Result = A | B; // OR
            4'b0110: Result = A ^ B; // XOR
            4'b0111: Result = ~(A | B); // NOR
            4'b1000: Result = ~A; // NOT on A

            // Comparisons
            4'b1001: Result = (signed_mode ? (signed_A > signed_B) : (A > B)) ? 1 : 0; // Greater Than
            4'b1010: Result = (signed_mode ? (signed_A < signed_B) : (A < B)) ? 1 : 0; // Less Than
            4'b1011: Result = (A == B) ? 1 : 0; // Equality

            // Shifts
            4'b1100: begin // Logical Left Shift by 1
                Result = A << 1;
                C = A[NUM_BITS-1];
            end
            4'b1101: begin // Logical Right Shift by 1
                Result = A >> 1;
                C = A[0];
            end
            4'b1110: begin // Arithmetic Right Shift by 1 (Signed)
                Result = signed_mode ? 
                        {A[NUM_BITS-1], A[NUM_BITS-1:1]} :  // Preserve sign bit (MSB) for signed mode
                        {1'b0, A[NUM_BITS-1:1]};           // Fill MSB with 0 for unsigned mode
                //(signed_A >>> 1) : (A >> 1);
                C = A[0];
            end

            default: Result = {NUM_BITS{1'b0}};
        endcase

        // Set flags based on Result
        Z = (Result == 0);
        N = signed_mode ? Result[NUM_BITS-1]:0; // Set Negative flag only 
        
    end
endmodule
