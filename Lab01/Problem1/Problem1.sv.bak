module top_bin_to_gray_7seg #(
    parameter bit ACTIVE_LOW = 1'b1
)(
    input  logic [3:0] bin_in,   
    output logic [3:0] gray_out, 
    output logic [6:0] seg       
);
    // Conversión a Gray
    bin2gray u_b2g (
        .bin  (bin_in),
        .gray (gray_out)
    );

    // Mostrar el código Gray (interpretado como valor HEX) en el display
    hex7seg #(.ACTIVE_LOW(ACTIVE_LOW)) u_hex (
        .val (gray_out),
        .seg (seg)
    );
endmodule
