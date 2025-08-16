module edge_detector (
    input  logic clk,
    input  logic reset_n,
    input  logic signal_in,
    output logic edge_out
);

    logic signal_delayed;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            signal_delayed <= 1'b0;
        end else begin
            signal_delayed <= signal_in;
        end
    end
    
    assign edge_out = signal_in & ~signal_delayed; // Rising edge detection

endmodule