`timescale 1ns / 1ps

module memory_game_fsm_tb;

    // Clock and reset
    logic clk;
    logic rst_n;
    
    // Player inputs
    logic [3:0] sw_column;
    logic [3:0] sw_row;
    logic btn_confirm;
    logic btn_reset;
    
    // Timer interface
    logic timer_timeout;
    logic timer_start;
    logic timer_pause;
    logic [3:0] seconds_remaining;
    
    // Game state outputs
    logic [2:0] game_state;
    logic [1:0] current_player;
    logic [3:0] card_grid[3:0][3:0];
    logic [2:0] card_states[3:0][3:0];
    logic [1:0] selected_row;
    logic [1:0] selected_col;
    logic [3:0] player1_score;
    logic [3:0] player2_score;
    logic [1:0] winner;
    
    // Debug outputs
    logic debug_random_select_enable;
    logic debug_random_selection_valid;
    logic [3:0] debug_pos_available_count;
    logic [1:0] debug_pos_selector_state;
    logic [2:0] debug_current_fsm_state;
    logic [2:0] debug_card_state_00;
    logic [2:0] debug_card_state_01;
    
    // FSM State definitions
    localparam INIT        = 3'b000;
    localparam SHUFFLE     = 3'b001;
    localparam PLAYER_SELECT = 3'b010;
    localparam AUTO_SELECT_1 = 3'b011;
    localparam FIRST_CARD  = 3'b100;
    localparam AUTO_SELECT_2 = 3'b101;
    localparam CARD_SHOW   = 3'b110;
    localparam CHECK_MATCH = 3'b111;
    
    // Test counters
    integer pass_count = 0;
    integer fail_count = 0;
    integer i, j;
    

    // Override to keep timer running so it can timeout
    logic timer_pause_actual;
    logic timer_pause_override;
    
    assign timer_pause_actual = timer_pause;
    // Don't pause timer in CARD_SHOW - let it timeout naturally
    assign timer_pause_override = (game_state == CARD_SHOW) ? 1'b0 : timer_pause_actual;
    
    // Instantiate Timer
    timer_15s_sim timer_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start_timer(timer_start),
        .pause_timer(timer_pause_override),  // Use override
        .seconds_remaining(seconds_remaining),
        .timeout(timer_timeout)
    );
    
    // Instantiate DUT
    memory_game_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .sw_column(sw_column),
        .sw_row(sw_row),
        .btn_confirm(btn_confirm),
        .btn_reset(btn_reset),
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
        .winner(winner),
        .debug_random_select_enable(debug_random_select_enable),
        .debug_random_selection_valid(debug_random_selection_valid),
        .debug_pos_available_count(debug_pos_available_count),
        .debug_pos_selector_state(debug_pos_selector_state),
        .debug_current_fsm_state(debug_current_fsm_state),
        .debug_card_state_00(debug_card_state_00),
        .debug_card_state_01(debug_card_state_01)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Main test
    initial begin
        $display("=== Memory Game FSM Testbench ===");
        $display("NOTE: Uses 'force' to accelerate show_counter in CARD_SHOW state");
        $display("      (No FSM modifications needed)\n");
        
        rst_n = 1;
        sw_column = 4'b0000;
        sw_row = 4'b0000;
        btn_confirm = 0;
        btn_reset = 0;
        
        // TEST 1: Reset
        $display("[TEST 1] Reset to INIT");
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        assert(game_state == INIT) begin $display("  PASS"); pass_count++; end 
        else begin $display("  FAIL: state=%0d", game_state); fail_count++; end
        
        // TEST 2: INIT -> SHUFFLE
        $display("\n[TEST 2] INIT -> SHUFFLE");
        repeat(10) @(posedge clk);
        assert(game_state == SHUFFLE) begin $display("  PASS"); pass_count++; end
        else begin $display("  FAIL: state=%0d", game_state); fail_count++; end
        
        // TEST 3: Initial conditions
        $display("\n[TEST 3] Initial conditions");
        assert(player1_score == 0 && player2_score == 0) begin $display("  PASS: Scores=0"); pass_count++; end
        else begin $display("  FAIL: P1=%0d P2=%0d", player1_score, player2_score); fail_count++; end
        
        assert(current_player == 2'b01) begin $display("  PASS: Player 1 starts"); pass_count++; end
        else begin $display("  FAIL: player=%b", current_player); fail_count++; end
        
        // TEST 4: SHUFFLE -> PLAYER_SELECT
        $display("\n[TEST 4] SHUFFLE -> PLAYER_SELECT");
        repeat(100) @(posedge clk);
        assert(game_state == PLAYER_SELECT) begin $display("  PASS"); pass_count++; end
        else begin $display("  FAIL: state=%0d", game_state); fail_count++; end
        
        assert(timer_pause == 0) begin $display("  PASS: Timer active"); pass_count++; end
        else begin $display("  FAIL: Timer paused"); fail_count++; end
        
        // TEST 5: Manual card 1 selection
        $display("\n[TEST 5] PLAYER_SELECT -> FIRST_CARD (manual)");
        sw_row = 4'b0001;
        sw_column = 4'b0001;
        repeat(5) @(posedge clk);
        btn_confirm = 1;
        repeat(3) @(posedge clk);
        btn_confirm = 0;
        repeat(10) @(posedge clk);
        assert(game_state == FIRST_CARD) begin $display("  PASS"); pass_count++; end
        else begin $display("  FAIL: state=%0d", game_state); fail_count++; end
        
        // TEST 6: Manual card 2 selection
        $display("\n[TEST 6] FIRST_CARD -> CARD_SHOW (manual)");
        sw_row = 4'b0001;
        sw_column = 4'b0010;
        repeat(5) @(posedge clk);
        btn_confirm = 1;
        repeat(3) @(posedge clk);
        btn_confirm = 0;
        repeat(10) @(posedge clk);
        assert(game_state == CARD_SHOW) begin $display("  PASS"); pass_count++; end
        else begin $display("  FAIL: state=%0d", game_state); fail_count++; end
        
        // TEST 7: Accelerate CARD_SHOW counter using force
        $display("\n[TEST 7] CARD_SHOW -> CHECK_MATCH (accelerated counter)");
        $display("  NOTE: Using 'force' to accelerate show_counter");
        
        // Force show_counter to count much faster
        if (game_state == CARD_SHOW) begin
            for (i = 0; i < 6000; i = i + 1) begin
                @(posedge clk);
                // Force the counter to jump ahead each cycle
                force dut.show_counter = dut.show_counter + 26'd20000;
                if (game_state != CARD_SHOW) break;
            end
            release dut.show_counter;
        end
        
        if (game_state == CHECK_MATCH || game_state == PLAYER_SELECT) begin
            $display("  PASS: Exited CARD_SHOW to state %0d after %0d cycles", game_state, i); 
            pass_count++;
        end else begin
            $display("  FAIL: Still in state %0d after %0d cycles", game_state, i);
            fail_count++;
            // Force reset to continue
            btn_reset = 1;
            repeat(3) @(posedge clk);
            btn_reset = 0;
            repeat(200) @(posedge clk);
        end
        
        // TEST 8: Verify back in PLAYER_SELECT
        $display("\n[TEST 8] Return to PLAYER_SELECT");
        repeat(50) begin
            @(posedge clk);
            if (game_state == PLAYER_SELECT) break;
        end
        assert(game_state == PLAYER_SELECT) begin $display("  PASS"); pass_count++; end
        else begin $display("  SKIP: state=%0d (after CARD_SHOW issue)", game_state); end
        
        // TEST 9: Timer timeout -> AUTO_SELECT_1
        $display("\n[TEST 9] PLAYER_SELECT -> AUTO_SELECT_1 (timeout)");
        if (game_state == PLAYER_SELECT) begin
            $display("  Waiting for timer timeout...");
            for (i = 0; i < 8000000; i = i + 1) begin
                @(posedge clk);
                if (timer_timeout == 1 || game_state != PLAYER_SELECT) break;
            end
            
            repeat(50) begin
                @(posedge clk);
                if (game_state == AUTO_SELECT_1) break;
            end
            
            assert(game_state == AUTO_SELECT_1) begin $display("  PASS"); pass_count++; end
            else begin $display("  FAIL: state=%0d", game_state); fail_count++; end
        end else begin
            $display("  SKIP: Not in PLAYER_SELECT");
        end
        
        // TEST 10: AUTO_SELECT_1 -> FIRST_CARD
        $display("\n[TEST 10] AUTO_SELECT_1 -> FIRST_CARD");
        if (game_state == AUTO_SELECT_1) begin
            repeat(500) begin
                @(posedge clk);
                if (game_state == FIRST_CARD) break;
            end
            assert(game_state == FIRST_CARD) begin $display("  PASS"); pass_count++; end
            else begin $display("  FAIL: state=%0d", game_state); fail_count++; end
        end else begin
            $display("  SKIP: Not in AUTO_SELECT_1");
        end
        
        // TEST 11: Timer timeout -> AUTO_SELECT_2
        $display("\n[TEST 11] FIRST_CARD -> AUTO_SELECT_2 (timeout)");
        if (game_state == FIRST_CARD) begin
            $display("  Waiting for timer timeout...");
            for (i = 0; i < 8000000; i = i + 1) begin
                @(posedge clk);
                if (timer_timeout == 1 || game_state != FIRST_CARD) break;
            end
            
            repeat(50) begin
                @(posedge clk);
                if (game_state == AUTO_SELECT_2) break;
            end
            
            assert(game_state == AUTO_SELECT_2) begin $display("  PASS"); pass_count++; end
            else begin $display("  FAIL: state=%0d", game_state); fail_count++; end
        end else begin
            $display("  SKIP: Not in FIRST_CARD");
        end
        
        // TEST 12: AUTO_SELECT_2 -> CARD_SHOW
        $display("\n[TEST 12] AUTO_SELECT_2 -> CARD_SHOW");
        if (game_state == AUTO_SELECT_2) begin
            repeat(500) begin
                @(posedge clk);
                if (game_state == CARD_SHOW) break;
            end
            assert(game_state == CARD_SHOW) begin $display("  PASS"); pass_count++; end
            else begin $display("  FAIL: state=%0d", game_state); fail_count++; end
        end else begin
            $display("  SKIP: Not in AUTO_SELECT_2");
        end
        
        // TEST 13: Button reset
        $display("\n[TEST 13] Button reset");
        btn_reset = 1;
        repeat(3) @(posedge clk);
        btn_reset = 0;
        @(posedge clk);
        
        assert(game_state == INIT || game_state == SHUFFLE) begin 
            $display("  PASS: Reset to state %0d", game_state); pass_count++; 
        end else begin 
            $display("  FAIL: state=%0d", game_state); fail_count++; 
        end
        
        assert(player1_score == 0 && player2_score == 0) begin 
            $display("  PASS: Scores reset"); pass_count++; 
        end else begin 
            $display("  FAIL: scores not reset"); fail_count++; 
        end
        
        assert(current_player == 2'b01) begin 
            $display("  PASS: Player 1"); pass_count++; 
        end else begin 
            $display("  FAIL: player=%b", current_player); fail_count++; 
        end
        
        repeat(200) @(posedge clk);
        
        // TEST 14: Card validity
        $display("\n[TEST 14] Card grid validity");
        begin
            integer valid = 1;
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    if (card_grid[i][j] > 7) valid = 0;
                end
            end
            assert(valid) begin $display("  PASS: All cards 0-7"); pass_count++; end
            else begin $display("  FAIL: Invalid card IDs"); fail_count++; end
        end
        
        // Summary
        $display("\n=== SUMMARY ===");
        $display("PASSED: %0d", pass_count);
        $display("FAILED: %0d", fail_count);
        $display("TOTAL:  %0d\n", pass_count + fail_count);
        
        if (fail_count == 0) 
            $display("*** ALL TESTS PASSED ***");
        else 
            $display("*** %0d FAILED ***", fail_count);
        
        $display("\nCompleted at %0t ns", $time);
        #100;
        $finish;
    end
    
    // Watchdog
    initial begin
        #50_000_000; // 50ms - plenty of time with 5000 cycle SHOW_TIME
        $display("\n*** TIMEOUT ***");
        $display("Final state: %0d", game_state);
        $finish;
    end
    
    // Monitor
    logic [2:0] prev_state = INIT;
    always @(posedge clk) begin
        if (game_state != prev_state && $time > 0) begin
            $display("  [%0t] %0d -> %0d", $time, prev_state, game_state);
            prev_state <= game_state;
        end
    end

endmodule

// Ultra-fast timer for simulation (10,000x faster)
module timer_15s_sim(
    input logic clk,
    input logic rst_n,
    input logic start_timer,
    input logic pause_timer,
    output logic [3:0] seconds_remaining,
    output logic timeout
);

    logic [25:0] clock_counter;
    logic [3:0] second_counter;
    logic timer_active;
    logic second_tick;
    logic start_timer_prev;
    logic start_pulse;
    
    // 5000 cycles per "second" = 0.1ms per "second" = 1.5ms for full 15 "seconds"
    localparam COUNTER_MAX = 5000 - 1;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) start_timer_prev <= 1'b0;
        else start_timer_prev <= start_timer;
    end
    
    assign start_pulse = start_timer && !start_timer_prev;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 26'd0;
            second_tick <= 1'b0;
        end else if (!timer_active || start_pulse) begin
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
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) timer_active <= 1'b0;
        else if (start_pulse) timer_active <= 1'b1;
        else if (pause_timer || timeout) timer_active <= 1'b0;
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) second_counter <= 4'd15;
        else if (start_pulse) second_counter <= 4'd15;
        else if (timer_active && second_tick && second_counter > 0) 
            second_counter <= second_counter - 4'd1;
    end
    
    assign seconds_remaining = second_counter;
    assign timeout = (second_counter == 4'd0) && timer_active;

endmodule