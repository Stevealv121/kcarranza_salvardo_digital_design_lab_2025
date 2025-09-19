module timer_15s(
    input logic clk,           // 50MHz system clock
    input logic rst_n,         // Active low reset
    input logic start_timer,   // Start/restart the countdown
    input logic pause_timer,   // Pause the countdown
    output logic [3:0] seconds_remaining, // Current seconds (0-15)
    output logic timeout       // High when timer reaches 0
);

    // Internal signals
    logic [25:0] clock_counter;  // Counter for 50MHz clock (50M cycles = 1 second)
    logic [3:0] second_counter;  // Seconds counter (0-15)
    logic timer_active;          // Timer is running
    logic second_tick;           // Pulse every second
    
    // Parameters
    localparam CLOCK_FREQ = 50_000_000; // 50MHz
    localparam COUNTER_MAX = CLOCK_FREQ - 1; // Count from 0 to 49,999,999
    
    // Clock divider - Generate 1 second tick
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 26'd0;
            second_tick <= 1'b0;
        end else if (!timer_active) begin
            clock_counter <= 26'd0;
            second_tick <= 1'b0;
        end else if (clock_counter >= COUNTER_MAX) begin
            clock_counter <= 26'd0;
            second_tick <= 1'b1;
        end else begin
            clock_counter <= clock_counter + 26'd1;
            second_tick <= 1'b0;
        end
    end
    
    // Timer control logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_active <= 1'b0;
        end else if (start_timer) begin
            timer_active <= 1'b1;
        end else if (pause_timer || timeout) begin
            timer_active <= 1'b0;
        end
    end
    
    // Seconds counter (countdown from 15 to 0)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            second_counter <= 4'd15;
        end else if (start_timer) begin
            second_counter <= 4'd15; // Reset to 15 seconds
        end else if (timer_active && second_tick && second_counter > 0) begin
            second_counter <= second_counter - 4'd1;
        end
    end
    
    // Output assignments
    assign seconds_remaining = second_counter;
    assign timeout = (second_counter == 4'd0) && timer_active;

endmodule