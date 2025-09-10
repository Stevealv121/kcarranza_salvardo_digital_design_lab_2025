module full_subtractor_nbit #(parameter N = 4) (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic bin,
    output logic [N-1:0] diff,
    output logic bout,
    output logic overflow
);
    logic [N:0] b_temp;
    
    assign b_temp[0] = bin;
    
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : sub
            full_subtractor fs(
                .a(a[i]),
                .b(b[i]),
                .bin(b_temp[i]),
                .diff(diff[i]),
                .bout(b_temp[i+1])
            );
        end
    endgenerate
    
    assign bout = b_temp[N];
    assign overflow = b_temp[N-1] ^ b_temp[N];  // Overflow detection
endmodule