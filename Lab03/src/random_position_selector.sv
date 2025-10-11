module random_position_selector(
    input logic clk,
    input logic rst_n,
    input logic select_enable,     // Level signal to select random position
    input logic [2:0] card_states[3:0][3:0], // Current card states
    output logic [1:0] random_row, // Selected random row
    output logic [1:0] random_col, // Selected random column
    output logic selection_valid,   // High if a valid position was found
    // Debug outputs
    output logic [3:0] debug_available_count,
    output logic [1:0] debug_current_state
);

    logic [7:0] random_num;
    logic [3:0] available_count;
    logic select_enable_prev;
    logic select_trigger;
    logic [1:0] debug_state;
    
    // Edge detection
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            select_enable_prev <= 1'b0;
        end else begin
            select_enable_prev <= select_enable;
        end
    end
    
    assign select_trigger = select_enable && !select_enable_prev;
    
    // Random number generator
    random_generator pos_rng(
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1), // Always running
        .random_out(random_num)
    );
    
    // Count available positions (combinational)
    always_comb begin
        available_count = 4'd0;
        
        // Count available positions (not matched cards)
        if (!card_states[0][0][2]) available_count = available_count + 1;
        if (!card_states[0][1][2]) available_count = available_count + 1;
        if (!card_states[0][2][2]) available_count = available_count + 1;
        if (!card_states[0][3][2]) available_count = available_count + 1;
        if (!card_states[1][0][2]) available_count = available_count + 1;
        if (!card_states[1][1][2]) available_count = available_count + 1;
        if (!card_states[1][2][2]) available_count = available_count + 1;
        if (!card_states[1][3][2]) available_count = available_count + 1;
        if (!card_states[2][0][2]) available_count = available_count + 1;
        if (!card_states[2][1][2]) available_count = available_count + 1;
        if (!card_states[2][2][2]) available_count = available_count + 1;
        if (!card_states[2][3][2]) available_count = available_count + 1;
        if (!card_states[3][0][2]) available_count = available_count + 1;
        if (!card_states[3][1][2]) available_count = available_count + 1;
        if (!card_states[3][2][2]) available_count = available_count + 1;
        if (!card_states[3][3][2]) available_count = available_count + 1;
    end
    
    // pick a random position and check if it's valid
    // If not valid, try a few more positions sequentially
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            random_row <= 2'b00;
            random_col <= 2'b00;
            selection_valid <= 1'b0;
            debug_state <= 2'b00;
        end else if (select_trigger) begin
            logic [3:0] try_position;
            logic [1:0] try_row, try_col;
            logic found;
            
            debug_state <= 2'b01; // Processing
            found = 1'b0;
            
            // Try up to 16 positions starting from a random one
            try_position = random_num[3:0]; // 0-15
            
            // Try position 0 (random_num[3:0])
            try_row = try_position[3:2];
            try_col = try_position[1:0];
            if (!card_states[try_row][try_col][2] && !found) begin
                random_row <= try_row;
                random_col <= try_col;
                selection_valid <= 1'b1;
                debug_state <= 2'b10;
                found = 1'b1;
            end
            
            // If not found, try position 1
            if (!found) begin
                try_position = (random_num[3:0] + 1) % 16;
                try_row = try_position[3:2];
                try_col = try_position[1:0];
                if (!card_states[try_row][try_col][2]) begin
                    random_row <= try_row;
                    random_col <= try_col;
                    selection_valid <= 1'b1;
                    debug_state <= 2'b10;
                    found = 1'b1;
                end
            end
            
            // If still not found, try position 2
            if (!found) begin
                try_position = (random_num[3:0] + 2) % 16;
                try_row = try_position[3:2];
                try_col = try_position[1:0];
                if (!card_states[try_row][try_col][2]) begin
                    random_row <= try_row;
                    random_col <= try_col;
                    selection_valid <= 1'b1;
                    debug_state <= 2'b10;
                    found = 1'b1;
                end
            end
            
            // If still not found, just take first available (fallback)
            if (!found) begin
                if (!card_states[0][0][2]) begin random_row <= 2'b00; random_col <= 2'b00; selection_valid <= 1'b1; debug_state <= 2'b10; end
                else if (!card_states[0][1][2]) begin random_row <= 2'b00; random_col <= 2'b01; selection_valid <= 1'b1; debug_state <= 2'b10; end
                else if (!card_states[0][2][2]) begin random_row <= 2'b00; random_col <= 2'b10; selection_valid <= 1'b1; debug_state <= 2'b10; end
                else if (!card_states[0][3][2]) begin random_row <= 2'b00; random_col <= 2'b11; selection_valid <= 1'b1; debug_state <= 2'b10; end
                else if (!card_states[1][0][2]) begin random_row <= 2'b01; random_col <= 2'b00; selection_valid <= 1'b1; debug_state <= 2'b10; end
                else if (!card_states[1][1][2]) begin random_row <= 2'b01; random_col <= 2'b01; selection_valid <= 1'b1; debug_state <= 2'b10; end
                else if (!card_states[1][2][2]) begin random_row <= 2'b01; random_col <= 2'b10; selection_valid <= 1'b1; debug_state <= 2'b10; end
                else if (!card_states[1][3][2]) begin random_row <= 2'b01; random_col <= 2'b11; selection_valid <= 1'b1; debug_state <= 2'b10; end
                else begin selection_valid <= 1'b0; debug_state <= 2'b00; end // No cards available
            end
            
        end else if (!select_enable) begin
            selection_valid <= 1'b0;
            debug_state <= 2'b00;
        end
    end

    // Debug outputs
    assign debug_available_count = available_count;
    assign debug_current_state = debug_state;

endmodule