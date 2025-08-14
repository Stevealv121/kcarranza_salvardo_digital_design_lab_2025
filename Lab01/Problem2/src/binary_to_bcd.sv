module binary_to_bcd (
    input  logic [7:0] binary_in,    // 8-bit binary input (0-255)
    output logic [3:0] hundreds,     // BCD hundreds digit
    output logic [3:0] tens,         // BCD tens digit  
    output logic [3:0] ones          // BCD ones digit
);

    logic [19:0] shift_reg;  // Working register for double dabble
    integer i;
    
    always_comb begin
        // Initialize shift register with binary input
        shift_reg = {12'b0, binary_in};
        
        // Double dabble algorithm
        for (i = 0; i < 8; i++) begin
            // Check and adjust hundreds digit
            if (shift_reg[19:16] >= 5)
                shift_reg[19:16] = shift_reg[19:16] + 3;
                
            // Check and adjust tens digit
            if (shift_reg[15:12] >= 5)
                shift_reg[15:12] = shift_reg[15:12] + 3;
                
            // Check and adjust ones digit
            if (shift_reg[11:8] >= 5)
                shift_reg[11:8] = shift_reg[11:8] + 3;
                
            // Shift left by 1
            shift_reg = shift_reg << 1;
        end
        
        // Extract BCD digits
        hundreds = shift_reg[19:16];
        tens = shift_reg[15:12];
        ones = shift_reg[11:8];
    end

endmodule