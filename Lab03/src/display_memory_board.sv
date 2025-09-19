module display_memory_board(
    input logic clk_vga,
    input logic [9:0] x, y,
    input logic [1:0] game_state,
    input logic [3:0] card_grid[3:0][3:0],
    input logic [2:0] card_states[3:0][3:0],
    input logic [3:0] turn_timer,
    input logic [1:0] current_player,
    input logic [1:0] selected_row,
    input logic [1:0] selected_col,
    input logic [1:0] winner,
    input logic sync_blank,
    output logic [7:0] vga_r, vga_g, vga_b
);

    // Layout parameters for 4x4 grid (centered on 640x480 screen)
    localparam BOARD_X_START = 160;     // Center horizontally: (640 - 320)/2 = 160
    localparam BOARD_Y_START = 80;      // Center vertically: (480 - 320)/2 = 80
    localparam CELL_SIZE = 80;          // Each card is 80x80 pixels
    localparam CARD_SIZE = 70;          // Card content is 70x70 (5px border)
    localparam SYMBOL_SIZE = 40;        // Symbol size within card
    
    localparam WIN_TEXT_Y = 420;
    
    // Color definitions
    localparam [23:0] CARD_BACK_COLOR = 24'h4040FF;     // Blue card back
    localparam [23:0] CARD_FRONT_COLOR = 24'hF0F0F0;    // Light gray card front
    localparam [23:0] MATCHED_COLOR = 24'h40FF40;       // Green for matched cards
    localparam [23:0] SELECTED_COLOR = 24'hFFFF40;      // Yellow for selected cards
    localparam [23:0] HIGHLIGHT_COLOR = 24'hFF4040;     // Red selection highlight
    localparam [23:0] BG_COLOR = 24'h202040;            // Dark blue background
    localparam [23:0] WHITE_COLOR = 24'hFFFFFF;
    localparam [23:0] BLACK_COLOR = 24'h000000;
    localparam [23:0] RED_COLOR = 24'hFF0000;
    localparam [23:0] YELLOW_COLOR = 24'hFFFF00;
    localparam [23:0] GREEN_COLOR = 24'h00FF00;
    localparam [23:0] CYAN_COLOR = 24'h00FFFF;
    localparam [23:0] MAGENTA_COLOR = 24'hFF00FF;
    localparam [23:0] ORANGE_COLOR = 24'hFF8000;
	 localparam [23:0] BLUE_COLOR = 24'h0000FF;
    
    // Position calculations
    logic [9:0] rel_x, rel_y;
    logic [1:0] card_col, card_row;
    logic [9:0] card_x_start, card_y_start;
    logic [9:0] card_center_x, card_center_y;
    logic [9:0] symbol_rel_x, symbol_rel_y;
    
    // Area detection
    logic is_in_board_area;
    logic is_in_card;
    logic is_selected_card;
    logic is_win_text_area;
    
    // Calculated values
    assign rel_x = x - BOARD_X_START;
    assign rel_y = y - BOARD_Y_START;
    assign card_col = rel_x / CELL_SIZE;
    assign card_row = rel_y / CELL_SIZE;
    
    assign card_x_start = BOARD_X_START + card_col * CELL_SIZE;
    assign card_y_start = BOARD_Y_START + card_row * CELL_SIZE;
    assign card_center_x = card_x_start + CELL_SIZE/2;
    assign card_center_y = card_y_start + CELL_SIZE/2;
    
    assign symbol_rel_x = x - card_center_x + SYMBOL_SIZE/2;
    assign symbol_rel_y = y - card_center_y + SYMBOL_SIZE/2;
    
    // Area detection logic
    assign is_in_board_area = (x >= BOARD_X_START) && 
                              (x < BOARD_X_START + 4 * CELL_SIZE) && 
                              (y >= BOARD_Y_START) && 
                              (y < BOARD_Y_START + 4 * CELL_SIZE) &&
                              (card_col < 4) && (card_row < 4);
    
    assign is_in_card = is_in_board_area &&
                        (x >= card_x_start + 5) && (x < card_x_start + CELL_SIZE - 5) &&
                        (y >= card_y_start + 5) && (y < card_y_start + CELL_SIZE - 5);
    
    assign is_selected_card = is_in_board_area && 
                              (card_row == selected_row) && (card_col == selected_col);
    
    assign is_win_text_area = (game_state == 2'b10) && 
                              (y >= WIN_TEXT_Y) && (y < WIN_TEXT_Y + 40) &&
                              (x >= 200) && (x < 440); // Added x bounds for centered win text
    
    // Symbol generation logic
    function logic [23:0] get_symbol_color(
        input logic [3:0] symbol_id,
        input logic [9:0] sym_x, sym_y
    );
        logic [9:0] center_x, center_y, dx, dy;
        logic [19:0] dist_sq;
        logic in_symbol;
        
        center_x = SYMBOL_SIZE / 2;
        center_y = SYMBOL_SIZE / 2;
        dx = (sym_x > center_x) ? (sym_x - center_x) : (center_x - sym_x);
        dy = (sym_y > center_y) ? (sym_y - center_y) : (center_y - sym_y);
        dist_sq = dx * dx + dy * dy;
        
        case (symbol_id)
            4'd0: begin // Circle
                in_symbol = (dist_sq <= (SYMBOL_SIZE/2 - 3) * (SYMBOL_SIZE/2 - 3)) &&
                           (dist_sq >= (SYMBOL_SIZE/2 - 8) * (SYMBOL_SIZE/2 - 8));
                get_symbol_color = in_symbol ? RED_COLOR : CARD_FRONT_COLOR;
            end
            4'd1: begin // Square
                in_symbol = ((dx >= SYMBOL_SIZE/2 - 8) && (dx <= SYMBOL_SIZE/2 - 3)) ||
                           ((dy >= SYMBOL_SIZE/2 - 8) && (dy <= SYMBOL_SIZE/2 - 3));
                get_symbol_color = in_symbol ? GREEN_COLOR : CARD_FRONT_COLOR;
            end
            4'd2: begin // Triangle (simplified)
                in_symbol = (sym_y >= SYMBOL_SIZE/2 + 5) && 
                           (sym_x >= center_x - (sym_y - center_y)/2) &&
                           (sym_x <= center_x + (sym_y - center_y)/2) &&
                           (sym_y <= SYMBOL_SIZE - 5);
                get_symbol_color = in_symbol ? BLUE_COLOR : CARD_FRONT_COLOR;
            end
            4'd3: begin // Diamond
                in_symbol = (dx + dy >= SYMBOL_SIZE/2 - 8) && 
                           (dx + dy <= SYMBOL_SIZE/2 - 3);
                get_symbol_color = in_symbol ? YELLOW_COLOR : CARD_FRONT_COLOR;
            end
            4'd4: begin // Plus/Cross
                in_symbol = ((dx <= 3) && (dy <= SYMBOL_SIZE/2 - 3)) ||
                           ((dy <= 3) && (dx <= SYMBOL_SIZE/2 - 3));
                get_symbol_color = in_symbol ? CYAN_COLOR : CARD_FRONT_COLOR;
            end
            4'd5: begin // X
                in_symbol = ((dx >= dy - 2) && (dx <= dy + 2)) ||
                           ((dx >= (SYMBOL_SIZE - dy) - 2) && (dx <= (SYMBOL_SIZE - dy) + 2));
                get_symbol_color = in_symbol ? MAGENTA_COLOR : CARD_FRONT_COLOR;
            end
            4'd6: begin // Star (simplified as asterisk)
                in_symbol = ((dx <= 2) && (dy <= SYMBOL_SIZE/2 - 3)) ||
                           ((dy <= 2) && (dx <= SYMBOL_SIZE/2 - 3)) ||
                           (((dx >= dy - 2) && (dx <= dy + 2)) && (dx <= SYMBOL_SIZE/2 - 3)) ||
                           (((dx >= (SYMBOL_SIZE/2 - dy) - 2) && (dx <= (SYMBOL_SIZE/2 - dy) + 2)) && (dx <= SYMBOL_SIZE/2 - 3));
                get_symbol_color = in_symbol ? ORANGE_COLOR : CARD_FRONT_COLOR;
            end
            4'd7: begin // Heart (simplified as double circle)
                logic in_left, in_right, in_bottom;
                in_left = ((sym_x - SYMBOL_SIZE/4) * (sym_x - SYMBOL_SIZE/4) + 
                          (sym_y - SYMBOL_SIZE/3) * (sym_y - SYMBOL_SIZE/3)) <= (SYMBOL_SIZE/6) * (SYMBOL_SIZE/6);
                in_right = ((sym_x - 3*SYMBOL_SIZE/4) * (sym_x - 3*SYMBOL_SIZE/4) + 
                           (sym_y - SYMBOL_SIZE/3) * (sym_y - SYMBOL_SIZE/3)) <= (SYMBOL_SIZE/6) * (SYMBOL_SIZE/6);
                in_bottom = (sym_y >= SYMBOL_SIZE/2) && (sym_x >= SYMBOL_SIZE/3) && 
                           (sym_x <= 2*SYMBOL_SIZE/3) && (sym_y <= 3*SYMBOL_SIZE/4);
                in_symbol = in_left || in_right || in_bottom;
                get_symbol_color = in_symbol ? 24'hFF4080 : CARD_FRONT_COLOR;
            end
            default: get_symbol_color = CARD_FRONT_COLOR;
        endcase
    endfunction
    
    // Main pixel color logic
    logic [23:0] pixel_color;
    
    always_comb begin
        pixel_color = BG_COLOR; // Default background
        
        if (is_in_board_area) begin
            if (is_in_card) begin
                // Determine card state
                logic card_face_up, card_matched, card_selected;
                logic [3:0] card_id;
                
                card_face_up = card_states[card_row][card_col][1];
                card_matched = card_states[card_row][card_col][2];
                card_selected = card_states[card_row][card_col][0];
                card_id = card_grid[card_row][card_col];
                
                if (card_matched) begin
                    // Matched card - show symbol with green tint
                    pixel_color = get_symbol_color(card_id, symbol_rel_x, symbol_rel_y);
                    if (pixel_color != CARD_FRONT_COLOR) begin
                        // Add green tint to symbol
                        pixel_color = {pixel_color[23:16] >> 1, 8'hFF, pixel_color[7:0] >> 1};
                    end else begin
                        pixel_color = MATCHED_COLOR;
                    end
                end else if (card_face_up || card_selected) begin
                    // Face up card - show symbol
                    pixel_color = get_symbol_color(card_id, symbol_rel_x, symbol_rel_y);
                end else begin
                    // Face down card - show card back
                    pixel_color = CARD_BACK_COLOR;
                end
            end else if (is_selected_card) begin
                // Selection highlight border
                pixel_color = HIGHLIGHT_COLOR;
            end else begin
                // Board background between cards
                pixel_color = BG_COLOR;
            end
        end else if (is_win_text_area) begin
            // Winner announcement
            case (winner)
                2'b01: pixel_color = RED_COLOR;      // Player 1 wins
                2'b10: pixel_color = YELLOW_COLOR;   // Player 2 wins
                2'b11: pixel_color = WHITE_COLOR;    // Tie
                default: pixel_color = BG_COLOR;
            endcase
        end
    end
    
    // Output register with sync blank
    always_ff @(posedge clk_vga) begin
        if (sync_blank) begin
            vga_r <= pixel_color[23:16];
            vga_g <= pixel_color[15:8];
            vga_b <= pixel_color[7:0];
        end else begin
            vga_r <= 8'h00;
            vga_g <= 8'h00;
            vga_b <= 8'h00;
        end
    end

endmodule