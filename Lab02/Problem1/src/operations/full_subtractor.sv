module full_subtractor(
    input logic a, b, bin,
    output logic diff, bout
);
    logic d1, b1, b2;
    
    // Gate-level implementation
    xor(d1, a, b);
    xor(diff, d1, bin);
    
    and(b1, ~a, b);
    and(b2, ~d1, bin);
    or(bout, b1, b2);
endmodule