module random_generator(
    input logic clk,
    input logic rst_n,
    input logic enable,          // Enable random number generation
    output logic [7:0] random_out // 8-bit random output
);

    // 8-bit LFSR with taps at positions 8, 6, 5, 4 (polynomial x^8 + x^6 + x^5 + x^4 + 1)
    logic [7:0] lfsr_reg;
    logic feedback;
    
    // Calculate feedback bit
    assign feedback = lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize with non-zero seed to avoid getting stuck at 0
            lfsr_reg <= 8'hA5; // Arbitrary non-zero seed
        end else if (enable) begin
            // Shift left and insert feedback bit at LSB
            lfsr_reg <= {lfsr_reg[6:0], feedback};
        end
    end
    
    assign random_out = lfsr_reg;

endmodule