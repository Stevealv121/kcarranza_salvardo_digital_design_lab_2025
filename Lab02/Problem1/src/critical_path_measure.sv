`timescale 1ns / 1ps

module critical_path_measure #(parameter N = 32) (
    input logic clk,
    input logic reset,
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic [3:0] opcode,
    output logic [N-1:0] result
);
    logic [N-1:0] a_reg, b_reg;
    logic [3:0] opcode_reg;
    logic [N-1:0] alu_result;
    
    // Registros de entrada
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            a_reg <= 0;
            b_reg <= 0;
            opcode_reg <= 0;
        end else begin
            a_reg <= a;
            b_reg <= b;
            opcode_reg <= opcode;
        end
    end
    
    // Instancia de la ALU
    alu #(N) alu_instance (
        .a(a_reg),
        .b(b_reg),
        .opcode(opcode_reg),
        .result(alu_result),
        .N_flag(), 
        .Z_flag(), 
        .C_flag(), 
        .V_flag(), 
        .div_by_zero_error(), 
        .mod_by_zero_error()
    );
    
    // Registro de salida
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 0;
        end else begin
            result <= alu_result;
        end
    end
endmodule