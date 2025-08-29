module full_adder(
    input logic a, b, cin,
    output logic sum, cout
);
    logic s1, c1, c2;
    
    xor(s1, a, b);
    xor(sum, s1, cin);
    
    and(c1, a, b);
    and(c2, s1, cin);
    or(cout, c1, c2);
endmodule