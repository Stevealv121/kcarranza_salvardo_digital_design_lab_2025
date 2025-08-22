`timescale 1ns/1ps
module Problem1_tb;

    logic [3:0] bin_in;
    logic [3:0] gray_out;

    bin2gray dut (
        .bin(bin_in),
        .gray(gray_out)
    );

    initial begin
        $display("BIN (hex)\tBIN (bin)\tGRAY");

        // Prueba con al menos 8 valores distintos
        bin_in = 4'h0; #1; $display("%h\t\t%b\t\t%b", bin_in, bin_in, gray_out);
        bin_in = 4'h1; #1; $display("%h\t\t%b\t\t%b", bin_in, bin_in, gray_out);
        bin_in = 4'h2; #1; $display("%h\t\t%b\t\t%b", bin_in, bin_in, gray_out);
        bin_in = 4'h3; #1; $display("%h\t\t%b\t\t%b", bin_in, bin_in, gray_out);
        bin_in = 4'h4; #1; $display("%h\t\t%b\t\t%b", bin_in, bin_in, gray_out);
        bin_in = 4'h5; #1; $display("%h\t\t%b\t\t%b", bin_in, bin_in, gray_out);
        bin_in = 4'hA; #1; $display("%h\t\t%b\t\t%b", bin_in, bin_in, gray_out);
        bin_in = 4'hF; #1; $display("%h\t\t%b\t\t%b", bin_in, bin_in, gray_out);

        $finish;
    end
endmodule
