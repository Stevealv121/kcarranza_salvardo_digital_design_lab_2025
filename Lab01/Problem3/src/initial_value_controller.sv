module initial_value_controller (
    input  logic       clk,
    input  logic       reset_n,
    input  logic       btn_up,
    input  logic       btn_down,
    output logic [5:0] initial_value
);

    logic [5:0] init_reg;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            init_reg <= 6'd0;
        end else begin
            if (btn_up && init_reg < 6'd63) begin
                init_reg <= init_reg + 1'b1;
            end else if (btn_down && init_reg > 6'd0) begin
                init_reg <= init_reg - 1'b1;
            end
        end
    end
    
    assign initial_value = init_reg;

endmodule