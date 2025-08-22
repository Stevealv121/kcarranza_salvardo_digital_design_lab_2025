module counter #(
    parameter WIDTH = 6
)(
    input  logic clk,
    input  logic rst_n,         // async reset, active low
    input  logic start,         // start counting
    input  logic [WIDTH-1:0] start_value, // initial value
    output logic [WIDTH-1:0] count,
    output logic full           // goes high when max reached
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            count <= start_value;
        else if (start) begin
            if (count < (2**WIDTH - 1))
                count <= count + 1;
        end
    end

    assign full = (count == (2**WIDTH - 1));

endmodule
