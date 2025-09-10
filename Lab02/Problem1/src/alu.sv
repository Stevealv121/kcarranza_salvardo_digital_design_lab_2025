module alu #(parameter N = 4) (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic [3:0] opcode,
    output logic [N-1:0] result,
    output logic N_flag,  // Negative
    output logic Z_flag,  // Zero
    output logic C_flag,  // Carry
    output logic V_flag,  // Overflow
	 output logic div_by_zero_error,
    output logic mod_by_zero_error
);
    // Internal signals
    logic [N-1:0] sum, diff;
    logic [2*N-1:0] product;
    logic carry_out, borrow_out;
    logic overflow_add, overflow_sub;
    
    full_adder_nbit #(N) adder(
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(sum),
        .cout(carry_out),
        .overflow(overflow_add)
    );
    
    full_subtractor_nbit #(N) sub(
        .a(a),
        .b(b),
        .bin(1'b0),
        .diff(diff),
        .bout(borrow_out),
        .overflow(overflow_sub)
    );
    
		shift_add_multiplier #(N) mult(
			 .a(a),
			 .b(b),
			 .product(product)
		);
    
    always_comb begin
        // Default values
        result = {N{1'b0}};
        N_flag = 1'b0;
        Z_flag = 1'b0;
        C_flag = 1'b0;
        V_flag = 1'b0;
		  div_by_zero_error = 1'b0;  // Default: no error
        mod_by_zero_error = 1'b0;  // Default: no error
        
        case(opcode)
            // Addition
            4'b0000: begin
                result = sum;
                C_flag = carry_out;
                V_flag = overflow_add;
            end
            
            // Subtraction
            4'b0001: begin
                result = diff;
                N_flag = result[N-1];
                C_flag = borrow_out;
                V_flag = overflow_sub;
            end
            
            // Multiplication
            4'b0010: begin
                result = product[N-1:0];
                V_flag = |product[2*N-1:N];
            end
            
            // Other operations
		      4'b0011: begin  // Division
					 if (b == 0) begin
						  result = {N{1'b0}};  // Return 0 for safety
						  div_by_zero_error = 1'b1;  // Explicit error flag
					 end else begin
						  result = a / b;
						  div_by_zero_error = 1'b0;
					 end
				end

				4'b0100: begin  // Modulo
					 if (b == 0) begin
						  result = {N{1'b0}};  // Return 0 for safety
						  mod_by_zero_error = 1'b1;  // Explicit error flag
					 end else begin
						  result = a % b;
						  mod_by_zero_error = 1'b0;
					 end
				end
            4'b0101: result = a & b;  // AND
            4'b0110: result = a | b;  // OR
            4'b0111: result = a ^ b;  // XOR
            4'b1000: result = a << b[$clog2(N)-1:0];  // Shift left
            4'b1001: result = a >> b[$clog2(N)-1:0];  // Shift right
            
            default: result = {N{1'b0}};
        endcase
        
        // Zero flag (common to all operations)
        Z_flag = (result == {N{1'b0}});
    end
endmodule