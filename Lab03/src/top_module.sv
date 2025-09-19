module top_module(
    // Clock and Reset
    input logic CLOCK_50,               // 50MHz system clock
    input logic [3:0] KEY,              // Push buttons (active low)
    input logic [9:0] SW,               // Switches
    
    // VGA Outputs
    output logic VGA_HS,                // VGA Horizontal Sync
    output logic VGA_VS,                // VGA Vertical Sync
    output logic VGA_BLANK_N,           // VGA Blank
    output logic VGA_SYNC_N,            // VGA Sync
    output logic VGA_CLK,               // VGA Clock
    output logic [7:0] VGA_R,           // VGA Red
    output logic [7:0] VGA_G,           // VGA Green
    output logic [7:0] VGA_B,           // VGA Blue
    
    // 7-Segment Displays
    output logic [6:0] HEX0,            // Timer display
    output logic [6:0] HEX1,            // Player 1 score
    output logic [6:0] HEX2,            // Player 2 score
    output logic [6:0] HEX3,            // Current player indicator
    
    // LEDs for feedback
    output logic [9:0] LEDR             // Red LEDs for status
);

    // Internal signals
    logic rst_n;
    logic btn_confirm, btn_reset;
    logic [3:0] sw_column, sw_row;
    
    // Button debouncing
    logic btn_confirm_db, btn_reset_db;
    logic btn_confirm_pulse, btn_reset_pulse;
    
    // Timer signals
    logic timer_start, timer_pause, timer_timeout;
    logic [3:0] timer_seconds;
    
    // FSM signals
    logic [2:0] game_state;
    logic [1:0] current_player;
    logic [3:0] card_grid[3:0][3:0];
    logic [2:0] card_states[3:0][3:0];
    logic [1:0] selected_row, selected_col;
    logic [3:0] player1_score, player2_score;
    logic [1:0] winner;
    
    // VGA interface signals
    logic [1:0] vga_game_state;
    logic [3:0] vga_timer;
    logic [1:0] vga_current_player;
    logic [1:0] vga_selected_row, vga_selected_col;
    
    // Reset logic (active low reset from KEY[3])
    assign rst_n = KEY[3];
    
    // Input mapping
    assign sw_column = SW[3:0];         // Column selection
    assign sw_row = SW[7:4];           // Row selection  
    assign btn_confirm = ~KEY[0];       // Confirm button (active low to active high)
    assign btn_reset = ~KEY[1];        // Reset button (active low to active high)
    
    // Button debouncing modules
    button_debouncer confirm_debouncer(
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .button_in(btn_confirm),
        .button_out(btn_confirm_db),
        .button_pulse(btn_confirm_pulse)
    );
    
    button_debouncer reset_debouncer(
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .button_in(btn_reset),
        .button_out(btn_reset_db),
        .button_pulse(btn_reset_pulse)
    );
    
    // 15-second countdown timer
    timer_15s game_timer(
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .start_timer(timer_start),
        .pause_timer(timer_pause),
        .seconds_remaining(timer_seconds),
        .timeout(timer_timeout)
    );
    
    // Memory Game FSM Controller
    memory_game_fsm game_controller(
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .sw_column(sw_column),
        .sw_row(sw_row),
        .btn_confirm(btn_confirm_pulse),
        .btn_reset(btn_reset_pulse),
        .timer_timeout(timer_timeout),
        .timer_start(timer_start),
        .timer_pause(timer_pause),
        .game_state(game_state),
        .current_player(current_player),
        .card_grid(card_grid),
        .card_states(card_states),
        .selected_row(selected_row),
        .selected_col(selected_col),
        .player1_score(player1_score),
        .player2_score(player2_score),
        .winner(winner)
    );
    
    // VGA signal adaptation
    assign vga_game_state = (game_state == 3'b101) ? 2'b10 : 2'b01;
    assign vga_timer = timer_seconds;
    assign vga_current_player = current_player;
    assign vga_selected_row = selected_row;
    assign vga_selected_col = selected_col;
    
    // VGA Controller
    vga_controller vga_ctrl(
        .clk(CLOCK_50),
        .game_state(vga_game_state),
        .card_grid(card_grid),
        .card_states(card_states),
        .turn_timer(vga_timer),
        .current_player(vga_current_player),
        .selected_row(vga_selected_row),
        .selected_col(vga_selected_col),
        .winner(winner),
        .SYNC_H(VGA_HS),
        .SYNC_V(VGA_VS),
        .SYNC_B(VGA_SYNC_N),
        .SYNC_BLANK(VGA_BLANK_N),
        .CLK_VGA(VGA_CLK),
        .vga_red(VGA_R),
        .vga_green(VGA_G),
        .vga_blue(VGA_B)
    );
    
    // 7-Segment Display Controllers
    seven_segment_decoder timer_display(
        .value(timer_seconds),
        .hex_out(HEX0)
    );
    
    seven_segment_decoder player1_display(
        .value(player1_score),
        .hex_out(HEX1)
    );
    
    seven_segment_decoder player2_display(
        .value(player2_score),
        .hex_out(HEX2)
    );
    
    seven_segment_decoder current_player_display(
        .value({2'b00, current_player}),
        .hex_out(HEX3)
    );
    
    // LED Status indicators
    always_comb begin
        LEDR[9:8] = current_player;      // Show current player
        LEDR[7:4] = sw_row;              // Show selected row
        LEDR[3:0] = sw_column;           // Show selected column
    end

endmodule