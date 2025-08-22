module subtractor_fpga_top (
    input  logic [7:0] switches,    // SW[7:4] = A (minuend), SW[3:0] = B (subtrahend)
    output logic [6:0] hex0,        // Result C (A - B) 
    output logic [6:0] hex1,        // Input B (subtrahend)
    output logic [6:0] hex2,        // Input A (minuend)
    output logic [9:0] leds         // LEDs for additional status
);

    // Internal signals
    logic [3:0] minuend, subtrahend, difference;
    logic borrow_out, negative;
	 logic [3:0] display_result;
    
    // Extract inputs from switches
    assign minuend = switches[7:4];      // A
    assign subtrahend = switches[3:0];   // B
    
    // Instantiate 4-bit subtractor
    full_subtractor_4bit subtractor (
        .minuend(minuend),
        .subtrahend(subtrahend),
        .borrow_in(1'b0),                // No initial borrow
        .difference(difference),         
        .borrow_out(borrow_out),
        .negative(negative)
    );
	 
    assign display_result = negative ? (~difference + 1'b1) : difference;
	 
    // Display A on HEX2
    binary_to_7seg display_A (
        .binary_in(minuend),            // Show A
        .segments(hex2)
    );
    
    // Display B on HEX1  
    binary_to_7seg display_B (
        .binary_in(subtrahend),         // Show B
        .segments(hex1)
    );
    
    // Display C (result) on HEX0
    binary_to_7seg display_C (
        .binary_in(display_result),         // Show C = A - B
        .segments(hex0)
    );
    
    // LED status indicators
    assign leds[0] = negative;           // LED0: indicates negative result
    assign leds[1] = borrow_out;         // LED1: indicates borrow occurred

endmodule