module shift_add_multiplier #(parameter N = 4) (
    input logic [N-1:0] a,  // Multiplicand
    input logic [N-1:0] b,  // Multiplier
    output logic [2*N-1:0] product
);
    logic [2*N-1:0] partial_product;
    assign partial_product = { {N{1'b0}}, a };  // Initialize with multiplicand (right-aligned)

    always_comb begin
        product = 0;
        for (int i = 0; i < N; i++) begin
            if (b[i]) begin
                product = product + (partial_product << i);  // Shift and add
            end
        end
    end
endmodule