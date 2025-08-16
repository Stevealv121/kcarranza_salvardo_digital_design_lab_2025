module binary_to_decimal (
    input  logic [5:0] binary_in,
    output logic [3:0] tens,
    output logic [3:0] units
);

    logic [5:0] temp;
    logic [3:0] tens_temp, units_temp;
    
    always_comb begin
        temp = binary_in;
        tens_temp = 4'd0;
        units_temp = 4'd0;
        
        // Combinational double dabble algorithm
        // For 6-bit input (max 63),
        if (temp >= 6'd50) begin
            tens_temp = 4'd5;
            temp = temp - 6'd50;
        end else if (temp >= 6'd40) begin
            tens_temp = 4'd4;
            temp = temp - 6'd40;
        end else if (temp >= 6'd30) begin
            tens_temp = 4'd3;
            temp = temp - 6'd30;
        end else if (temp >= 6'd20) begin
            tens_temp = 4'd2;
            temp = temp - 6'd20;
        end else if (temp >= 6'd10) begin
            tens_temp = 4'd1;
            temp = temp - 6'd10;
        end
        
        units_temp = temp[3:0];
    end
    
    assign tens = tens_temp;
    assign units = units_temp;

endmodule