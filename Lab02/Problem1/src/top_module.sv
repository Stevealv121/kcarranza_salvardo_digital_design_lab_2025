module top_module #(parameter N = 4) (
    input logic CLOCK_50,
    input logic [2*N-1:0] SW,
    input logic [2:0] KEY,
    output logic [6:0] HEX5,  // Operand A
    output logic [6:0] HEX4,  // Operand B
    output logic [6:0] HEX3,  // Flags
    output logic [6:0] HEX2,  // Result
    //output logic [6:0] HEX1,  // Status
    output logic [6:0] HEX0,  // Operation code
    output logic [9:0] LEDR
);
    // Internal signals
    logic [N-1:0] operand_a, operand_b, alu_result, result_reg;
    logic [3:0] operation;
    logic result_valid, mode, error;
    logic N_flag, Z_flag, C_flag, V_flag;
    logic key0_pressed, key1_pressed, key2_pressed;
	 logic div_error_signal, mod_error_signal;
    
    // Debouncers
    debounce db_key0(CLOCK_50, ~KEY[0], key0_pressed);
    debounce db_key1(CLOCK_50, ~KEY[1], key1_pressed);
    debounce db_key2(CLOCK_50, ~KEY[2], key2_pressed);
    
    // ALU
    alu #(N) calculator(
        .a(operand_a),
        .b(operand_b),
        .opcode(operation),
        .result(alu_result),
        .N_flag(N_flag),
        .Z_flag(Z_flag),
        .C_flag(C_flag),
        .V_flag(V_flag),
		  .div_by_zero_error(div_error_signal),
        .mod_by_zero_error(mod_error_signal)
    );
    
    // Control Unit
    control_unit #(N) ctrl(
        .clk(CLOCK_50),
        .key0_pressed(key0_pressed),
        .key1_pressed(key1_pressed),
        .key2_pressed(key2_pressed),
        .sw_high(SW[2*N-1:N]),
        .sw_low(SW[N-1:0]),
        .alu_result(alu_result),
        .N_flag(N_flag),
        .Z_flag(Z_flag),
        .C_flag(C_flag),
        .V_flag(V_flag),
        .div_by_zero_error(div_error_signal),
        .mod_by_zero_error(mod_error_signal),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(operation),
        .result_reg(result_reg),
        .result_valid(result_valid),
        .error(error),
        .mode(mode)
    );
    
    // Display drivers
    bin_to_bcd_decoder disp_op(.bin_number(operation), .bcd_number(HEX0));
    bin_to_bcd_decoder disp_a(.bin_number(operand_a), .bcd_number(HEX5));
    bin_to_bcd_decoder disp_b(.bin_number(operand_b), .bcd_number(HEX4));
    
    // Status display
    assign HEX3 = (error) ? 7'b0000110 :  // 'E'
                 7'b1111111;             // blank
    
    // Result display
    bin_to_bcd_decoder #(N) disp_res(
        .bin_number(result_reg),
		  .blank(~result_valid),
        .bcd_number(HEX2)
    );
    
    // LED indicators
    assign LEDR[9] = mode;
    assign LEDR[8] = error;
    assign LEDR[7] = V_flag;
    assign LEDR[6] = C_flag;
    assign LEDR[5] = Z_flag;
    assign LEDR[4] = N_flag;
    assign LEDR[3:0] = operation;
endmodule