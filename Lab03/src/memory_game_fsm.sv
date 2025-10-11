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
    output logic [1:0] winner,          // Winner (0=none, 1=P1, 2=P2, 3=tie)
	 
    // Debug outputs
    output logic debug_random_select_enable,
    output logic debug_random_selection_valid,
    output logic [3:0] debug_pos_available_count,
    output logic [1:0] debug_pos_selector_state,
    output logic [2:0] debug_current_fsm_state,
    output logic [2:0] debug_card_state_00,
    output logic [2:0] debug_card_state_01
);

    // FSM States - Mantenemos 3 bits
    typedef enum logic [2:0] {
        INIT        = 3'b000,    // Initialize game
        SHUFFLE     = 3'b001,    // Shuffle cards randomly
        PLAYER_SELECT = 3'b010,  // Player selecting first card
        AUTO_SELECT_1 = 3'b011,  // Auto-selecting first card (timeout)
        FIRST_CARD  = 3'b100,    // First card selected, selecting second
        AUTO_SELECT_2 = 3'b101,  // Auto-selecting second card (timeout)
        CARD_SHOW   = 3'b110,    // Show both cards for 2 seconds
        CHECK_MATCH = 3'b111     // Check if cards match
    } state_t;
    
    state_t current_state, next_state;
    
    // Internal registers
    logic [1:0] first_card_row, first_card_col;
    logic [3:0] first_card_id;
    logic [1:0] second_card_row, second_card_col;
    logic [3:0] second_card_id;
    logic [25:0] show_counter;
    logic show_timeout;
    logic cards_match;
    logic game_complete;
    logic [3:0] total_matches;
    logic auto_select_retry;
    logic [2:0] prev_state;
    
    // Random module interfaces
    logic shuffle_enable, shuffle_done;
    logic [3:0] shuffled_cards[3:0][3:0];
    logic random_select_enable, random_selection_valid;
    logic [1:0] random_row, random_col;
    
    // Timer control signals
    logic timer_start_reg, timer_pause_reg;
    
    // Constants
    localparam SHOW_TIME = 26'd100_000_000; // 2 seconds at 50MHz
    
    // Instantiate card shuffler
    card_shuffler shuffler(
        .clk(clk),
        .rst_n(rst_n),
        .shuffle_enable(shuffle_enable),
        .shuffle_done(shuffle_done),
        .card_grid(shuffled_cards)
    );
    
    // Instantiate random position selector
    random_position_selector pos_selector(
        .clk(clk),
        .rst_n(rst_n),
        .select_enable(random_select_enable),
        .card_states(card_states),
        .random_row(random_row),
        .random_col(random_col),
        .selection_valid(random_selection_valid),
        .debug_available_count(debug_pos_available_count),
        .debug_current_state(debug_pos_selector_state)
    );
	 
    // Tracks prev state
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_state <= INIT;
        end else begin
            prev_state <= current_state;
        end
    end
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= INIT;
        end else if (btn_reset) begin
            current_state <= INIT;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Next state logic - CORREGIDO: Manejo explícito de game_complete
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            INIT: begin
                next_state = SHUFFLE;
            end
            
            SHUFFLE: begin
                if (shuffle_done) begin
                    next_state = PLAYER_SELECT;
                end
            end
            
            PLAYER_SELECT: begin
                if (btn_confirm && !card_states[sw_row[1:0]][sw_column[1:0]][2] && 
                    !card_states[sw_row[1:0]][sw_column[1:0]][1]) begin
                    next_state = FIRST_CARD;
                end else if (timer_timeout) begin
                    next_state = AUTO_SELECT_1;
                end
            end
            
            AUTO_SELECT_1: begin
                if (random_selection_valid) begin
                    next_state = FIRST_CARD;
                end
            end
            
            FIRST_CARD: begin
                if (btn_confirm && !card_states[sw_row[1:0]][sw_column[1:0]][2] && 
                    !card_states[sw_row[1:0]][sw_column[1:0]][1] &&
                    (sw_row[1:0] != first_card_row || sw_column[1:0] != first_card_col)) begin
                    next_state = CARD_SHOW;
                end else if (timer_timeout) begin
                    next_state = AUTO_SELECT_2;
                end
            end
            
            AUTO_SELECT_2: begin
                if (random_selection_valid) begin
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
                    next_state = CHECK_MATCH;
                end else begin
                    next_state = PLAYER_SELECT;
                end
            end
            
            default: begin
                next_state = INIT;
            end
        endcase
    end
    
    // Random selection control
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            random_select_enable <= 1'b0;
            auto_select_retry <= 1'b0;
        end else begin
            case (current_state)
                PLAYER_SELECT: begin
                    random_select_enable <= 1'b0;
                    auto_select_retry <= 1'b0;
                end
                
                AUTO_SELECT_1: begin
                    if (prev_state != AUTO_SELECT_1) begin
                        random_select_enable <= 1'b1;
                        auto_select_retry <= 1'b0;
                    end else if (random_selection_valid) begin
                        random_select_enable <= 1'b0;
                    end else if (!random_select_enable) begin
                        random_select_enable <= 1'b1;
                    end
                end
                
                FIRST_CARD: begin
                    random_select_enable <= 1'b0;
                    auto_select_retry <= 1'b0;
                end
                
                AUTO_SELECT_2: begin
                    if (prev_state != AUTO_SELECT_2) begin
                        random_select_enable <= 1'b1;
                        auto_select_retry <= 1'b0;
                    end else if (random_selection_valid && 
                               (random_row != first_card_row || random_col != first_card_col)) begin
                        random_select_enable <= 1'b0;
                    end else if (!random_select_enable) begin
                        random_select_enable <= 1'b1;
                    end
                end
                
                default: begin
                    random_select_enable <= 1'b0;
                    auto_select_retry <= 1'b0;
                end
            endcase
        end
    end
    
    // Shuffle enable logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shuffle_enable <= 1'b0;
        end else if (btn_reset || current_state == INIT) begin
            shuffle_enable <= 1'b1;
        end else begin
            shuffle_enable <= 1'b0;
        end
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
    
    // Initialize card grid from shuffler
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize with default pattern
            card_grid[0][0] <= 4'd0; card_grid[0][1] <= 4'd1; card_grid[0][2] <= 4'd2; card_grid[0][3] <= 4'd3;
            card_grid[1][0] <= 4'd4; card_grid[1][1] <= 4'd5; card_grid[1][2] <= 4'd6; card_grid[1][3] <= 4'd7;
            card_grid[2][0] <= 4'd0; card_grid[2][1] <= 4'd1; card_grid[2][2] <= 4'd2; card_grid[2][3] <= 4'd3;
            card_grid[3][0] <= 4'd4; card_grid[3][1] <= 4'd5; card_grid[3][2] <= 4'd6; card_grid[3][3] <= 4'd7;
        end else if (shuffle_done) begin
            card_grid <= shuffled_cards;
        end
    end
    
    // Card states management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize all cards face down
            for (int i = 0; i < 4; i = i + 1) begin
                for (int j = 0; j < 4; j = j + 1) begin
                    card_states[i][j] <= 3'b000;
                end
            end
            first_card_row <= 2'b00;
            first_card_col <= 2'b00;
            first_card_id <= 4'd0;
            second_card_row <= 2'b00;
            second_card_col <= 2'b00;
            second_card_id <= 4'd0;
        end else if (btn_reset || (current_state == INIT)) begin
            // Reset all cards
            for (int i = 0; i < 4; i = i + 1) begin
                for (int j = 0; j < 4; j = j + 1) begin
                    card_states[i][j] <= 3'b000;
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
                    for (int i = 0; i < 4; i = i + 1) begin
                        for (int j = 0; j < 4; j = j + 1) begin
                            if (!card_states[i][j][2]) begin
                                card_states[i][j][1:0] <= 2'b00;
                            end
                        end
                    end
                    
                    // Handle manual selection
                    if (btn_confirm && !card_states[sw_row[1:0]][sw_column[1:0]][2] && 
                        !card_states[sw_row[1:0]][sw_column[1:0]][1]) begin
                        first_card_row <= sw_row[1:0];
                        first_card_col <= sw_column[1:0];
                        first_card_id <= card_grid[sw_row[1:0]][sw_column[1:0]];
                        card_states[sw_row[1:0]][sw_column[1:0]][1:0] <= 2'b11;
                    end
                end
                
                AUTO_SELECT_1: begin
                    // Handle automatic first card selection
                    if (random_selection_valid) begin
                        first_card_row <= random_row;
                        first_card_col <= random_col;
                        first_card_id <= card_grid[random_row][random_col];
                        card_states[random_row][random_col][1:0] <= 2'b11;
                    end
                end
                
                FIRST_CARD: begin
                    // Handle manual second card selection
                    if (btn_confirm && !card_states[sw_row[1:0]][sw_column[1:0]][2] && 
                        (sw_row[1:0] != first_card_row || sw_column[1:0] != first_card_col)) begin
                        second_card_row <= sw_row[1:0];
                        second_card_col <= sw_column[1:0];
                        second_card_id <= card_grid[sw_row[1:0]][sw_column[1:0]];
                        card_states[sw_row[1:0]][sw_column[1:0]][1:0] <= 2'b11;
                    end
                end
                
                AUTO_SELECT_2: begin
                    // Handle automatic second card selection
                    if (random_selection_valid && 
                        (random_row != first_card_row || random_col != first_card_col)) begin
                        second_card_row <= random_row;
                        second_card_col <= random_col;
                        second_card_id <= card_grid[random_row][random_col];
                        card_states[random_row][random_col][1:0] <= 2'b11;
                    end
                end
                
                CHECK_MATCH: begin
                    if (cards_match) begin
                        // Mark both cards as matched
                        card_states[first_card_row][first_card_col][2] <= 1'b1;
                        card_states[second_card_row][second_card_col][2] <= 1'b1;
                    end
                end
                
                default: begin
                    // Maintain current state
                end
            endcase
        end
    end
    
    // Player management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_player <= 2'b01;
        end else if (btn_reset || (current_state == INIT)) begin
            current_player <= 2'b01;
        end else if (current_state == CHECK_MATCH && !cards_match && !game_complete) begin
            current_player <= (current_player == 2'b01) ? 2'b10 : 2'b01;
        end
    end
    
    // Score tracking
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            player1_score <= 4'd0;
            player2_score <= 4'd0;
        end else if (btn_reset || (current_state == INIT)) begin
            player1_score <= 4'd0;
            player2_score <= 4'd0;
        end else if (current_state == CHECK_MATCH && cards_match && !game_complete) begin
            if (current_player == 2'b01) begin
                player1_score <= player1_score + 4'd1;
            end else begin
                player2_score <= player2_score + 4'd1;
            end
        end
    end
    
    // Timer control
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_start_reg <= 1'b0;
            timer_pause_reg <= 1'b1;
        end else begin
            if ((current_state != PLAYER_SELECT && next_state == PLAYER_SELECT) ||
                (current_state != FIRST_CARD && next_state == FIRST_CARD)) begin
                timer_start_reg <= 1'b1;
                timer_pause_reg <= 1'b0;
            end else if (current_state == PLAYER_SELECT || current_state == FIRST_CARD) begin
                timer_start_reg <= 1'b0;
                timer_pause_reg <= 1'b0;
            end else begin
                timer_start_reg <= 1'b0;
                timer_pause_reg <= 1'b1;
            end
        end
    end
    
    // Assign timer control outputs
    assign timer_start = timer_start_reg;
    assign timer_pause = timer_pause_reg;
    
    // Game logic
    assign cards_match = (first_card_id == second_card_id);
    assign total_matches = player1_score + player2_score;
    assign game_complete = (total_matches == 4'd8); // 8 pares completados
    assign selected_row = sw_row[1:0];
    assign selected_col = sw_column[1:0];
    assign game_state = current_state;
    
    // Winner determination - CORREGIDO completamente
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            winner <= 2'b00;
        end else if (btn_reset) begin
            winner <= 2'b00;
        end else if (game_complete) begin
            if (player1_score > player2_score) begin
                winner <= 2'b01; // Player 1 wins
            end else if (player2_score > player1_score) begin
                winner <= 2'b10; // Player 2 wins
            end else begin
                winner <= 2'b11; // Tie
            end
        end
    end
    
    // Debug signal assignments
    assign debug_random_select_enable = random_select_enable;
    assign debug_random_selection_valid = random_selection_valid;
    assign debug_current_fsm_state = current_state;
    assign debug_card_state_00 = card_states[0][0];
    assign debug_card_state_01 = card_states[0][1];
    
endmodule