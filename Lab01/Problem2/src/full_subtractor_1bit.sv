module full_subtractor_1bit (
    input  logic a,      // Minuend bit
    input  logic b,      // Subtrahend bit  
    input  logic borrow_in,  // Borrow input
    output logic diff,       // Difference output
    output logic borrow_out  // Borrow output
);

    // Internal signals
    logic temp_diff1, temp_borrow1, temp_borrow2;
    
    // First half subtractor: a - b
    half_subtractor hs1 (
        .a(a),
        .b(b),
        .diff(temp_diff1),
        .borrow(temp_borrow1)
    );
    
    // Second half subtractor: temp_diff1 - borrow_in
    half_subtractor hs2 (
        .a(temp_diff1),
        .b(borrow_in),
        .diff(diff),
        .borrow(temp_borrow2)
    );
    
    // Borrow output logic
    assign borrow_out = temp_borrow1 | temp_borrow2;

endmodule