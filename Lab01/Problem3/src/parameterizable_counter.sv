module parameterizable_counter #(
    parameter int N_BITS = 4
)(
    input  logic                clk,
    input  logic                async_reset_n,
    input  logic                enable,
    input  logic                load_enable,
    input  logic [N_BITS-1:0]   load_value,
    output logic [N_BITS-1:0]   counter_out
);

    // Internal counter register
    logic [N_BITS-1:0] counter_reg;
    
    // Asynchronous reset and synchronous counting
    always_ff @(posedge clk or negedge async_reset_n) begin
        if (!async_reset_n) begin
            counter_reg <= '0;  // Reset to 0
        end else begin
            if (load_enable) begin
                counter_reg <= load_value;
            end else if (enable) begin
                // Use hardware adder for increment
                if (counter_reg == (2**N_BITS - 1)) begin
                    counter_reg <= '0; // Wrap around
                end else begin
                    counter_reg <= counter_reg + 1'b1;
                end
            end
        end
    end
    
    assign counter_out = counter_reg;

endmodule