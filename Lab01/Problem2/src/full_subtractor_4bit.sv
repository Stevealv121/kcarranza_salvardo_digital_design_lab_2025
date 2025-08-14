module full_subtractor_4bit (
    input  logic [3:0] minuend,     // 4-bit minuend (A)
    input  logic [3:0] subtrahend,  // 4-bit subtrahend (B)
    input  logic       borrow_in,   // Initial borrow input
    output logic [3:0] difference,  // 4-bit difference (A - B)
    output logic       borrow_out,  // Final borrow output
    output logic       negative     // Indicates if result is negative
);

    // Internal borrow signals
    logic [3:0] borrow_chain;
    
    // Instantiate four 1-bit full subtractors
    full_subtractor_1bit fs0 (
        .a(minuend[0]),
        .b(subtrahend[0]),
        .borrow_in(borrow_in),
        .diff(difference[0]),
        .borrow_out(borrow_chain[0])
    );
    
    full_subtractor_1bit fs1 (
        .a(minuend[1]),
        .b(subtrahend[1]),
        .borrow_in(borrow_chain[0]),
        .diff(difference[1]),
        .borrow_out(borrow_chain[1])
    );
    
    full_subtractor_1bit fs2 (
        .a(minuend[2]),
        .b(subtrahend[2]),
        .borrow_in(borrow_chain[1]),
        .diff(difference[2]),
        .borrow_out(borrow_chain[2])
    );
    
    full_subtractor_1bit fs3 (
        .a(minuend[3]),
        .b(subtrahend[3]),
        .borrow_in(borrow_chain[2]),
        .diff(difference[3]),
        .borrow_out(borrow_chain[3])
    );
    
    // Final borrow output and negative flag
    assign borrow_out = borrow_chain[3];
    assign negative = borrow_out;  // If there's a final borrow, result is negative

endmodule