module debounce(
    input logic clk,          // 50MHz clock (DE10-Standard)
    input logic button,       // Raw button input (active-low)
    output logic pressed      // Debounced output (1-clock pulse)
);

    // Parameters for 20ms debounce period (1e6 clocks at 50MHz)
    parameter DEBOUNCE_LIMIT = 1_000_000;
    
    // Synchronizer flip-flops
    logic [1:0] sync_ff;
    always_ff @(posedge clk) begin
        sync_ff <= {sync_ff[0], ~button};  // Invert button (active-high)
    end
    
    // Debounce counter
    logic [19:0] counter;
    logic button_stable;
    
    always_ff @(posedge clk) begin
        if (sync_ff[1] != button_stable) begin
            counter <= 0;
            button_stable <= sync_ff[1];
        end else if (counter < DEBOUNCE_LIMIT) begin
            counter <= counter + 1;
        end
        
        // Generate single-clock pulse on press
        pressed <= (counter == DEBOUNCE_LIMIT-1) && button_stable;
    end
endmodule