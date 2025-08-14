module bcd_to_7seg (
    input  logic [3:0] bcd_in,       // 4-bit BCD input (0-9)
    output logic [6:0] segments      // 7-segment output (active low)
);

    // 7-segment encoding for decimal digits (0-9)
    // Segments: {g, f, e, d, c, b, a}
    always_comb begin
        case (bcd_in)
            4'd0: segments = 7'b1000000; // 0
            4'd1: segments = 7'b1111001; // 1
            4'd2: segments = 7'b0100100; // 2
            4'd3: segments = 7'b0110000; // 3
            4'd4: segments = 7'b0011001; // 4
            4'd5: segments = 7'b0010010; // 5
            4'd6: segments = 7'b0000010; // 6
            4'd7: segments = 7'b1111000; // 7
            4'd8: segments = 7'b0000000; // 8
            4'd9: segments = 7'b0010000; // 9
            default: segments = 7'b1111111; // All off (blank)
        endcase
    end

endmodule