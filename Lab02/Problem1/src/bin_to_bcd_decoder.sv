module bin_to_bcd_decoder #(parameter N = 4) (
    input logic [N-1:0] bin_number,
    input logic blank,
    input logic is_signed_operation,
    output logic [6:0] bcd_number
);
    logic [3:0] display_num;
    logic is_negative;
    logic [N-1:0] abs_value;
    
    // Detectar si el número es negativo
    assign is_negative = is_signed_operation & bin_number[N-1];
    
    // Calcular valor absoluto si es negativo
    assign abs_value = is_negative ? (~bin_number + 1) : bin_number;
    
    // Para N > 4, mostrar los 4 bits inferiores
    assign display_num = (N > 4) ? abs_value[3:0] : abs_value;
    
    
    always_comb begin
        if (blank) begin
            bcd_number = 7'b1111111; // Apagado
        end else begin
            case(display_num)
                0:  bcd_number = 7'b1000000; // 0
                1:  bcd_number = 7'b1111001; // 1
                2:  bcd_number = 7'b0100100; // 2
                3:  bcd_number = 7'b0110000; // 3
                4:  bcd_number = 7'b0011001; // 4
                5:  bcd_number = 7'b0010010; // 5
                6:  bcd_number = 7'b0000010; // 6
                7:  bcd_number = 7'b1111000; // 7
                8:  bcd_number = 7'b0000000; // 8
                9:  bcd_number = 7'b0010000; // 9
                10: bcd_number = 7'b0001000; // A
                11: bcd_number = 7'b0000011; // b
                12: bcd_number = 7'b1000110; // C
                13: bcd_number = 7'b0100001; // d
                14: bcd_number = 7'b0000110; // E
                15: bcd_number = 7'b0001110; // F
                default: bcd_number = 7'b1111111; // Off
            endcase
        end
    end
endmodule