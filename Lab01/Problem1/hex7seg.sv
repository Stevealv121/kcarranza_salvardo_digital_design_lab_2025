module hex7seg #(
    parameter bit ACTIVE_LOW = 1'b1 
)(
    input  logic [3:0] val,          
    output logic [6:0] seg           
);

    localparam logic [6:0] HEX_LUT [16] = '{
        7'b1111110, // 0
        7'b0110000, // 1
        7'b1101101, // 2
        7'b1111001, // 3
        7'b0110011, // 4
        7'b1011011, // 5
        7'b1011111, // 6
        7'b1110000, // 7
        7'b1111111, // 8
        7'b1111011, // 9
        7'b1110111, // A
        7'b0011111, // b
        7'b1001110, // C
        7'b0111101, // d
        7'b1001111, // E
        7'b1000111  // F
    };

    logic [6:0] seg_active_high;
    always_comb seg_active_high = HEX_LUT[val];

    always_comb begin
        if (ACTIVE_LOW)
            seg = ~seg_active_high;   
        else
            seg =  seg_active_high;   
    end
endmodule
