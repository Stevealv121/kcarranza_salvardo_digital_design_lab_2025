module memory_game_fsm(
    input logic clk,                    // 50MHz system clock
    input logic rst_n,                  // Active low reset
    
    // Player inputs
    input logic [3:0] sw_column,        // SW[3:0] - Column selection
    input logic [3:0] sw_row,           // SW[7:4] - Row selection  
    input logic btn_confirm,            // KEY[0] - Confirm selection
    input logic btn_reset,              // KEY[1] - Reset game
    
    // Timer interface
    input logic timer_timeout,          // From 15s timer
    output logic timer_start,           // Start timer signal
    output logic timer_pause,           // Pause timer signal
    
    // Game state outputs
    output logic [2:0] game_state,      // Current game state
    output logic [1:0] current_player,  // Current player (1 or 2)
    output logic [3:0] card_grid[3:0][3:0],     // Card IDs (0-7 for 8 different symbols)
    output logic [2:0] card_states[3:0][3:0],   // [2]=matched, [1]=face_up, [0]=selected
    output logic [1:0] selected_row,    // Currently selected row
    output logic [1:0] selected_col,    // Currently selected col
    output logic [3:0] player1_score,   // Player 1 matches found
    output logic [3:0] player2_score,   // Player 2 matches found
    output logic [1:0] winner           // Winner (0=none, 1=P1, 2=P2, 3=tie)
);

    // FSM States
    typedef enum logic [2:0] {
        INIT        = 3'b000,    // Initialize game
        PLAYER_SELECT = 3'b001,  // Player selecting first card
        FIRST_CARD  = 3'b010,    // First card selected, selecting second
        CARD_SHOW   = 3'b011,    // Show both cards for 2 seconds
        CHECK_MATCH = 3'b100,    // Check if cards match
        GAME_OVER   = 3'b101     // Game finished
    } state_t;
    
    state_t current_state, next_state;
    
    // Internal registers
    logic [1:0] first_card_row, first_card_col;   // Position of first selected card
    logic [3:0] first_card_id;                    // ID of first selected card
    logic [1:0] second_card_row, second_card_col; // Position of second selected card
    logic [3:0] second_card_id;                   // ID of second selected card
    logic [25:0] show_counter;                    // Counter for showing cards (2 seconds)
    logic show_timeout;
    logic cards_match;
    logic game_complete;
    logic [3:0] total_matches;
    
    // Random card generation (simple LFSR for initial card placement)
    logic [7:0] lfsr;
    
    // Constants
    localparam SHOW_TIME = 26'd100_000_000; // 2 seconds at 50MHz
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || btn_reset) begin
            current_state <= INIT;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            INIT: begin
                next_state = PLAYER_SELECT;
            end
            
            PLAYER_SELECT: begin
                if (btn_confirm && !card_states[sw_row[1:0]][sw_column[1:0]][2]) begin
                    // Valid card selected (not already matched)
                    next_state = FIRST_CARD;
                end else if (timer_timeout) begin
                    // Timeout - auto select random available card
                    next_state = FIRST_CARD;
                end
            end
            
            FIRST_CARD: begin
                if (btn_confirm && !card_states[sw_row[1:0]][sw_column[1:0]][2] && 
                    (sw_row[1:0] != first_card_row || sw_column[1:0] != first_card_col)) begin
                    // Valid second card selected (different from first)
                    next_state = CARD_SHOW;
                end else if (timer_timeout) begin
                    // Timeout - auto select random available card
                    next_state = CARD_SHOW;
                end
            end
            
            CARD_SHOW: begin
                if (show_timeout) begin
                    next_state = CHECK_MATCH;
                end
            end
            
            CHECK_MATCH: begin
                if (game_complete) begin
                    next_state = GAME_OVER;
                end else if (cards_match) begin
                    // Same player continues
                    next_state = PLAYER_SELECT;
                end else begin
                    // Switch player
                    next_state = PLAYER_SELECT;
                end
            end
            
            GAME_OVER: begin
                if (btn_reset) begin
                    next_state = INIT;
                end
            end
        endcase
    end
    
    // Show counter for CARD_SHOW state
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            show_counter <= 26'd0;
            show_timeout <= 1'b0;
        end else if (current_state == CARD_SHOW) begin
            if (show_counter >= SHOW_TIME) begin
                show_counter <= 26'd0;
                show_timeout <= 1'b1;
            end else begin
                show_counter <= show_counter + 26'd1;
                show_timeout <= 1'b0;
            end
        end else begin
            show_counter <= 26'd0;
            show_timeout <= 1'b0;
        end
    end
    
    // Initialize card grid (simple pattern for now - 8 pairs)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || btn_reset) begin
            // Initialize with pairs of cards (0-7, each appears twice)
            card_grid[0][0] <= 4'd0; card_grid[0][1] <= 4'd1; card_grid[0][2] <= 4'd2; card_grid[0][3] <= 4'd3;
            card_grid[1][0] <= 4'd4; card_grid[1][1] <= 4'd5; card_grid[1][2] <= 4'd6; card_grid[1][3] <= 4'd7;
            card_grid[2][0] <= 4'd0; card_grid[2][1] <= 4'd1; card_grid[2][2] <= 4'd2; card_grid[2][3] <= 4'd3;
            card_grid[3][0] <= 4'd4; card_grid[3][1] <= 4'd5; card_grid[3][2] <= 4'd6; card_grid[3][3] <= 4'd7;
        end
    end
    
    // Card states management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || btn_reset) begin
            // Initialize all cards face down
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    card_states[i][j] <= 3'b000; // Not matched, face down, not selected
                end
            end
            first_card_row <= 2'b00;
            first_card_col <= 2'b00;
            first_card_id <= 4'd0;
            second_card_row <= 2'b00;
            second_card_col <= 2'b00;
            second_card_id <= 4'd0;
        end else begin
            case (current_state)
                PLAYER_SELECT: begin
                    // Clear all selections and face-up states (except matched cards)
                    for (int i = 0; i < 4; i++) begin
                        for (int j = 0; j < 4; j++) begin
                            if (!card_states[i][j][2]) begin // If not matched
                                card_states[i][j][1:0] <= 2'b00; // Face down, not selected
                            end
                        end
                    end
                    
                    if (btn_confirm && !card_states[sw_row[1:0]][sw_column[1:0]][2]) begin
                        first_card_row <= sw_row[1:0];
                        first_card_col <= sw_column[1:0];
                        first_card_id <= card_grid[sw_row[1:0]][sw_column[1:0]];
                        card_states[sw_row[1:0]][sw_column[1:0]][1:0] <= 2'b11; // Face up, selected
                    end
                end
                
                FIRST_CARD: begin
                    if (btn_confirm && !card_states[sw_row[1:0]][sw_column[1:0]][2] && 
                        (sw_row[1:0] != first_card_row || sw_column[1:0] != first_card_col)) begin
                        second_card_row <= sw_row[1:0];
                        second_card_col <= sw_column[1:0];
                        second_card_id <= card_grid[sw_row[1:0]][sw_column[1:0]];
                        card_states[sw_row[1:0]][sw_column[1:0]][1:0] <= 2'b11; // Face up, selected
                    end
                end
                
                CHECK_MATCH: begin
                    if (cards_match) begin
                        // Mark both cards as matched
                        card_states[first_card_row][first_card_col][2] <= 1'b1;
                        card_states[second_card_row][second_card_col][2] <= 1'b1;
                    end
                end
            endcase
        end
    end
    
    // Player management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || btn_reset) begin
            current_player <= 2'b01; // Start with player 1
        end else if (current_state == CHECK_MATCH && !cards_match) begin
            // Switch player only if no match
            current_player <= (current_player == 2'b01) ? 2'b10 : 2'b01;
        end
    end
    
    // Score tracking
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || btn_reset) begin
            player1_score <= 4'd0;
            player2_score <= 4'd0;
        end else if (current_state == CHECK_MATCH && cards_match) begin
            if (current_player == 2'b01) begin
                player1_score <= player1_score + 4'd1;
            end else begin
                player2_score <= player2_score + 4'd1;
            end
        end
    end
    
    // Timer control
    always_comb begin
        timer_start = (current_state == PLAYER_SELECT) || (current_state == FIRST_CARD);
        timer_pause = (current_state != PLAYER_SELECT) && (current_state != FIRST_CARD);
    end
    
    // Game logic
    assign cards_match = (first_card_id == second_card_id);
    assign total_matches = player1_score + player2_score;
    assign game_complete = (total_matches == 4'd8); // All 8 pairs found
    assign selected_row = sw_row[1:0];
    assign selected_col = sw_column[1:0];
    assign game_state = current_state;
    
    // Winner determination
    always_comb begin
        if (game_complete) begin
            if (player1_score > player2_score) begin
                winner = 2'b01; // Player 1 wins
            end else if (player2_score > player1_score) begin
                winner = 2'b10; // Player 2 wins
            end else begin
                winner = 2'b11; // Tie
            end
        end else begin
            winner = 2'b00; // No winner yet
        end
    end
    
endmodule