module button_debouncer #(
    parameter int DEBOUNCE_DELAY = 1000000 // 20ms at 50MHz
)(
    input  logic clk,
    input  logic reset_n,
    input  logic button_in,
    output logic button_out
);

    logic [$clog2(DEBOUNCE_DELAY)-1:0] counter;
    logic button_sync_0, button_sync_1;
    logic button_stable;
    
    // Two-stage synchronizer
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            button_sync_0 <= 1'b0;
            button_sync_1 <= 1'b0;
        end else begin
            button_sync_0 <= button_in;
            button_sync_1 <= button_sync_0;
        end
    end
    
    // Debounce counter
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= '0;
            button_stable <= 1'b0;
        end else begin
            if (button_sync_1 == button_stable) begin
                counter <= '0;
            end else begin
                counter <= counter + 1'b1;
                if (counter == DEBOUNCE_DELAY - 1) begin
                    button_stable <= button_sync_1;
                end
            end
        end
    end
    
    assign button_out = button_stable;

endmodule