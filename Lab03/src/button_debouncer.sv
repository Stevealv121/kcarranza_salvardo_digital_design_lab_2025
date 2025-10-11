module button_debouncer(
    input logic clk,
    input logic rst_n,
    input logic button_in,
    output logic button_out,
    output logic button_pulse
);

    logic [19:0] counter;
    logic button_sync1, button_sync2;
    logic button_stable;
    logic button_prev;
    
    // Synchronize input
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            button_sync1 <= 1'b0;
            button_sync2 <= 1'b0;
        end else begin
            button_sync1 <= button_in;
            button_sync2 <= button_sync1;
        end
    end
    
    // Debounce counter (20ms at 50MHz = 1,000,000 cycles)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 20'd0;
            button_stable <= 1'b0;
        end else if (button_sync2 != button_stable) begin
            counter <= counter + 20'd1;
            if (counter >= 20'd1000000) begin
                button_stable <= button_sync2;
                counter <= 20'd0;
            end
        end else begin
            counter <= 20'd0;
        end
    end
    
    // Generate pulse on rising edge
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            button_prev <= 1'b0;
        end else begin
            button_prev <= button_stable;
        end
    end
    
    assign button_out = button_stable;
    assign button_pulse = button_stable & ~button_prev;
    
endmodule