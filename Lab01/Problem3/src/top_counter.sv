module top_counter(
    input  logic clk,
    input  logic rst_n,      // KEY0 - active low when pressed
    input  logic start_btn,  // KEY1 - active low when pressed  
    input  logic up_btn,     // KEY2 - active low when pressed
    input  logic down_btn,   // KEY3 - active low when pressed
    input  logic mode_switch,
    output logic [6:0] seg_units,
    output logic [6:0] seg_tens
);
    logic [5:0] count;
    logic [3:0] tens, units;
    
    // Edge detection registers
    logic start_prev, up_prev, down_prev;
    
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            count <= 0;
            start_prev <= 1'b1;
            up_prev <= 1'b1; 
            down_prev <= 1'b1;
        end else begin
            // Update previous button states
            start_prev <= start_btn;
            up_prev <= up_btn;
            down_prev <= down_btn;
            
            // Simple logic: UP increments, DOWN decrements
            if (up_prev && ~up_btn) begin          // UP button pressed
                if (count < 63)
                    count <= count + (mode_switch ? 10 : 1);
            end else if (down_prev && ~down_btn) begin  // DOWN button pressed  
                if (count >= (mode_switch ? 10 : 1))
                    count <= count - (mode_switch ? 10 : 1);
            end
        end
    end

    // Convert to BCD
    binary_to_decimal bcd(.bin(count), .tens(tens), .units(units));

    // 7-segment decoders
    seven_segment_decoder dec_units(.digit(units), .segments(seg_units));
    seven_segment_decoder dec_tens(.digit(tens), .segments(seg_tens));

endmodule