module binary_to_decimal (
    input  logic [5:0] bin,
    output logic [3:0] tens,
    output logic [3:0] units
);
    always_comb begin
        tens  = bin / 10;
        units = bin % 10;
    end
endmodule