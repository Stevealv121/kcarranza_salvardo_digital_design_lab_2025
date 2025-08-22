module Problem1 (
    input  logic [3:0] SW,      // switches como entrada
    output logic [6:0] HEX0,    // unidades
    output logic [6:0] HEX1     // decenas
);

    logic [3:0] gray_out;
    logic [3:0] dec_unidades;
    logic [3:0] dec_decenas;

    // Conversión binario a Gray
    bin2gray u_b2g (
        .bin  (SW),
        .gray (gray_out)
    );

    // Conversión a decimal (0-15) para mostrar en dos displays
    assign dec_decenas  = gray_out / 10;
    assign dec_unidades = gray_out % 10;

    // Mostrar unidades en HEX0
    hex7seg u_hex0 (
        .val (dec_unidades),
        .seg (HEX0)
    );

    // Mostrar decenas en HEX1
    hex7seg u_hex1 (
        .val (dec_decenas),
        .seg (HEX1)
    );

endmodule
