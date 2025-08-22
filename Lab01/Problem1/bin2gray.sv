module bin2gray (
    input  logic [3:0] bin,
    output logic [3:0] gray
);

    always_comb begin
        gray[3] = bin[3];
        gray[2] = bin[3] ^ bin[2];
        gray[1] = bin[2] ^ bin[1];
        gray[0] = bin[1] ^ bin[0];
    end
endmodule
