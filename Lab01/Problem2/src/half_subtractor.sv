module half_subtractor (
    input  logic a,      // Minuend
    input  logic b,      // Subtrahend
    output logic diff,   // Difference
    output logic borrow  // Borrow
);

    assign diff = a ^ b;        // XOR for difference
    assign borrow = ~a & b;     // Borrow when a=0 and b=1

endmodule