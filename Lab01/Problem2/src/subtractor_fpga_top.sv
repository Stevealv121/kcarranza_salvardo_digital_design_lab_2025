module subtractor_fpga_top (
    input  logic [7:0] switches,    // SW[7:4] = minuend, SW[3:0] = subtrahend
    input  logic       reset_btn,   // Reset button (optional)
    output logic [6:0] hex0,        // Right 7-segment display (ones)
    output logic [6:0] hex1,        // Middle 7-segment display (tens) 
    output logic [6:0] hex2,        // Left 7-segment display (hundreds)
    output logic [9:0] leds         // LEDs for additional status
);

    // Internal signals
    logic [3:0] minuend, subtrahend, difference;
    logic borrow_out, negative;
    logic [7:0] result_magnitude;
    logic [3:0] bcd_hundreds, bcd_tens, bcd_ones;
    
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
    
    // Handle negative results (convert to magnitude)
    always_comb begin
        if (negative) begin
            // Two's complement to get positive magnitude
            result_magnitude = (~{4'b0000, difference}) + 8'b00000001;
        end else begin
            result_magnitude = {4'b0000, difference};
        end
    end
    
    // Convert binary result to BCD for decimal display
    binary_to_bcd bcd_converter (
        .binary_in(result_magnitude),
        .hundreds(bcd_hundreds),
        .tens(bcd_tens),
        .ones(bcd_ones)
    );
    
    // Display BCD digits on 7-segment displays (decimal)
    bcd_to_7seg seg0 (
        .bcd_in(bcd_ones),          // Ones digit
        .segments(hex0)
    );
    
    bcd_to_7seg seg1 (
        .bcd_in(bcd_tens),          // Tens digit
        .segments(hex1)
    );
    
    bcd_to_7seg seg2 (
        .bcd_in(bcd_hundreds),      // Hundreds digit (usually 0 for 4-bit results)
        .segments(hex2)
    );
    
    // LED status indicators
    assign leds[0] = negative;           // LED indicates negative result
    assign leds[1] = borrow_out;         // LED indicates borrow
    assign leds[3:2] = 2'b00;           // Unused
    assign leds[7:4] = difference;       // Show raw difference on LEDs
    assign leds[9:8] = 2'b00;           // Unused

endmodule