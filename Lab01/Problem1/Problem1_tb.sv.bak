`timescale 1ns/1ps
module tb_bin_to_gray_7seg;
    logic [3:0] bin_in;
    logic [3:0] gray_out;
    logic [6:0] seg;

    // Instancia del módulo top
    top_bin_to_gray_7seg #(.ACTIVE_LOW(1)) dut (
        .bin_in   (bin_in),
        .gray_out (gray_out),
        .seg      (seg)
    );

    initial begin
        $display("BIN\tGRAY\t7SEG (a..g, active low)");

        // Prueba con 8 valores distintos
        foreach (bin_in) begin end 
        bin_in = 4'h0; #1; $display("%h\t%b\t%b", bin_in, gray_out, seg);
        bin_in = 4'h1; #1; $display("%h\t%b\t%b", bin_in, gray_out, seg);
        bin_in = 4'h2; #1; $display("%h\t%b\t%b", bin_in, gray_out, seg);
        bin_in = 4'h3; #1; $display("%h\t%b\t%b", bin_in, gray_out, seg);
        bin_in = 4'h4; #1; $display("%h\t%b\t%b", bin_in, gray_out, seg);
        bin_in = 4'h5; #1; $display("%h\t%b\t%b", bin_in, gray_out, seg);
        bin_in = 4'hA; #1; $display("%h\t%b\t%b", bin_in, gray_out, seg);
        bin_in = 4'hF; #1; $display("%h\t%b\t%b", bin_in, gray_out, seg);

        $finish;
    end
endmodule
