module full_adder_nbit #(parameter N = 4) (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic cin,
    output logic [N-1:0] sum,
    output logic cout,
    output logic overflow
);
    logic [N:0] c;
    
    assign c[0] = cin;
    
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : adder
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .cin(c[i]),
                .sum(sum[i]),
                .cout(c[i+1])
            );
        end
    endgenerate
    
    assign cout = c[N];
    assign overflow = c[N-1] ^ c[N];  // Overflow occurs when carry into MSB != carry out
endmodule