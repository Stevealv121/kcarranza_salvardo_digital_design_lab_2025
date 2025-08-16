module subtractor_fpga_top (
    input  logic [7:0] switches,    // SW[7:4] = minuend, SW[3:0] = subtrahend
    input  logic       reset_btn,   // Reset button (optional)
    output logic [6:0] hex0,        // Right 7-segment display (LSB)
    output logic [6:0] hex1,        // Left 7-segment display (MSB)
    output logic [9:0] leds         // LEDs for additional status
);

    // Internal signals
    logic [3:0] minuend, subtrahend, difference;
    logic borrow_out, negative;
    logic [3:0] display_value;
    logic [7:0] result_magnitude;
    
    // Extract inputs from switches
    assign minuend = switches[7:4];
    assign subtrahend = switches[3:0];
    
    // Instantiate 4-bit subtractor
    full_subtractor_4bit subtractor (
        .minuend(minuend),
        .subtrahend(subtrahend),
        .borrow_in(1'b0),           // No initial borrow
        .difference(difference),
        .borrow_out(borrow_out),
        .negative(negative)
    );
    
    // Handle negative results (two's complement)
    always_comb begin
        if (negative) begin
            // Convert to positive magnitude for display
            result_magnitude = (~{4'b0000, difference}) + 8'b00000001;
        end else begin
            result_magnitude = {4'b0000, difference};
        end
    end
    
    // Display on 7-segment displays
    binary_to_7seg seg0 (
        .binary_in(result_magnitude[3:0]),  // LSB
        .segments(hex0)
    );
    
    binary_to_7seg seg1 (
        .binary_in(result_magnitude[7:4]),  // MSB
        .segments(hex1)
    );
    
    // LED status indicators
    assign leds[0] = negative;           // LED indicates negative result
    assign leds[1] = borrow_out;         // LED indicates borrow
    assign leds[3:2] = 2'b00;           // Unused
    assign leds[7:4] = difference;       // Show raw difference on LEDs
    assign leds[9:8] = 2'b00;           // Unused

endmodule