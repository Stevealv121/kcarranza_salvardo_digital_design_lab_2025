module control_unit #(parameter N = 4) (
    input logic clk,
    input logic key0_pressed,
    input logic key1_pressed,
    input logic key2_pressed,
    input logic [N-1:0] sw_high,
    input logic [N-1:0] sw_low,
    input logic [N-1:0] alu_result,
    input logic N_flag, Z_flag, C_flag, V_flag,
	 input logic div_by_zero_error,
	 input logic mod_by_zero_error,
    output logic [N-1:0] operand_a,
    output logic [N-1:0] operand_b,
    output logic [3:0] operation,
    output logic [N-1:0] result_reg,
    output logic result_valid,
    output logic error,
    output logic mode
);
    always_ff @(posedge clk) begin
        if (key2_pressed) begin  // AC reset
            operand_a <= {N{1'b0}};
            operand_b <= {N{1'b0}};
            operation <= 4'b0;
            result_reg <= {N{1'b0}};
            result_valid <= 1'b0;
            error <= 1'b0;
            mode <= 1'b0;
        end
        else begin
            if (key0_pressed) begin
                mode <= ~mode;
                result_valid <= 1'b0;
                error <= 1'b0;
            end
            
				if (key1_pressed && mode) begin
					 result_reg <= alu_result;
					 result_valid <= 1'b1;
					 error <= div_by_zero_error || mod_by_zero_error;
				end
            
            if (~mode) begin
                operand_a <= sw_high;
                operand_b <= sw_low;
            end 
            else begin
                operation <= sw_low[3:0];
            end
        end
    end
endmodule