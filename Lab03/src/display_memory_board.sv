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
    
    // Character display parameters
    localparam CHAR_SIZE = 100;         // Size of winner character
    localparam CHAR_X_START = 270;      // Center character horizontally: (640 - 100)/2
    localparam CHAR_Y_START = 190;      // Center character vertically: (480 - 100)/2
    localparam BG_RECT_WIDTH = 120;     // Background rectangle width
    localparam BG_RECT_HEIGHT = 120;    // Background rectangle height
    localparam BG_RECT_X_START = 260;   // Center background horizontally: (640 - 120)/2
    localparam BG_RECT_Y_START = 180;   // Center background vertically: (480 - 120)/2
    
    // Color definitions
    localparam [23:0] CARD_BACK_COLOR = 24'h4040FF;     // Blue card back
    localparam [23:0] CARD_FRONT_COLOR = 24'hF0F0F0;    // Light gray card front
    localparam [23:0] MATCHED_COLOR = 24'h40FF40;       // Green for matched cards
    localparam [23:0] HIGHLIGHT_COLOR = 24'hFFA500;     // Orange selection highlight
    localparam [23:0] BG_COLOR = 24'h202040;            // Dark blue background
    localparam [23:0] FINAL_SCREEN_COLOR = 24'h000000;  // Black final screen
    localparam [23:0] CHAR_COLOR = 24'hFFFFFF;          // White character color
    
    // Different background colors for each result
    localparam [23:0] PLAYER1_BG_COLOR = 24'hFF0000;    // Red for Player 1
    localparam [23:0] PLAYER2_BG_COLOR = 24'h0000FF;    // Blue for Player 2  
    localparam [23:0] TIE_BG_COLOR = 24'h808080;        // Gray for tie
    
    localparam [23:0] WHITE_COLOR = 24'hFFFFFF;
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
    
    // Character position calculations
    logic [9:0] char_rel_x, char_rel_y;
    
    // Area detection
    logic is_in_board_area;
    logic is_in_card;
    logic is_selected_card;
    logic is_card_border;
    logic is_in_character;
    logic is_in_bg_rectangle;
    logic is_in_number_1;
    logic is_in_number_2;
    logic is_in_letter_T;
    
    // Background color selection
    logic [23:0] current_bg_color;
    
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
    
    // Character position calculations
    assign char_rel_x = x - CHAR_X_START;
    assign char_rel_y = y - CHAR_Y_START;
    assign is_in_character = (x >= CHAR_X_START) && (x < CHAR_X_START + CHAR_SIZE) &&
                            (y >= CHAR_Y_START) && (y < CHAR_Y_START + CHAR_SIZE);
    
    // Background rectangle detection
    assign is_in_bg_rectangle = (x >= BG_RECT_X_START) && (x < BG_RECT_X_START + BG_RECT_WIDTH) &&
                               (y >= BG_RECT_Y_START) && (y < BG_RECT_Y_START + BG_RECT_HEIGHT);
    
    // Area detection logic
    assign is_in_board_area = (x >= BOARD_X_START) && 
                              (x < BOARD_X_START + 4 * CELL_SIZE) && 
                              (y >= BOARD_Y_START) && 
                              (y < BOARD_Y_START + 4 * CELL_SIZE) &&
                              (card_col < 4) && (card_row < 4);
    
    assign is_in_card = is_in_board_area &&
                        (x >= card_x_start + 5) && (x < card_x_start + CELL_SIZE - 5) &&
                        (y >= card_y_start + 5) && (y < card_y_start + CELL_SIZE - 5);
    
    assign is_card_border = is_in_board_area && 
                           ((x >= card_x_start && x < card_x_start + 5) ||
                            (x >= card_x_start + CELL_SIZE - 5 && x < card_x_start + CELL_SIZE) ||
                            (y >= card_y_start && y < card_y_start + 5) ||
                            (y >= card_y_start + CELL_SIZE - 5 && y < card_y_start + CELL_SIZE));
    
    assign is_selected_card = is_in_board_area && 
                              (card_row == selected_row) && (card_col == selected_col);
    
    // Character drawing functions
    // Number 1 
    function logic is_number_1(input logic [9:0] cx, input logic [9:0] cy);
        is_number_1 = ((cx >= 45 && cx < 55) && (cy >= 0 && cy < 100));  // Vertical center line
    endfunction
    
    // Number 2  
    function logic is_number_2(input logic [9:0] cx, input logic [9:0] cy);
        is_number_2 = ((cx >= 20 && cx < 80) && (cy >= 0 && cy < 20)) ||   // Top horizontal
                      ((cx >= 60 && cx < 80) && (cy >= 20 && cy < 40)) ||  // Right top vertical
                      ((cx >= 20 && cx < 80) && (cy >= 40 && cy < 60)) ||  // Middle horizontal
                      ((cx >= 20 && cx < 40) && (cy >= 60 && cy < 80)) ||  // Left bottom vertical
                      ((cx >= 20 && cx < 80) && (cy >= 80 && cy < 100));   // Bottom horizontal
    endfunction
    
    // Letter T
    function logic is_letter_T(input logic [9:0] cx, input logic [9:0] cy);
        is_letter_T = ((cx >= 20 && cx < 80) && (cy >= 0 && cy < 20)) ||   // Top horizontal
                      ((cx >= 45 && cx < 55) && (cy >= 20 && cy < 100));   // Vertical stem
    endfunction
    
    // Determine which character to display based on winner
    always_comb begin
        is_in_number_1 = 1'b0;
        is_in_number_2 = 1'b0;
        is_in_letter_T = 1'b0;
        
        if (is_in_character) begin
            case (winner)
                2'b01: is_in_number_1 = is_number_1(char_rel_x, char_rel_y);  // Player 1 wins
                2'b10: is_in_number_2 = is_number_2(char_rel_x, char_rel_y);  // Player 2 wins
                2'b11: is_in_letter_T = is_letter_T(char_rel_x, char_rel_y);  // Tie
                default: begin
                    is_in_number_1 = 1'b0;
                    is_in_number_2 = 1'b0;
                    is_in_letter_T = 1'b0;
                end
            endcase
        end
    end
    
    // Determine background color based on winner
    always_comb begin
        case (winner)
            2'b01: current_bg_color = PLAYER1_BG_COLOR; 
            2'b10: current_bg_color = PLAYER2_BG_COLOR;  
            2'b11: current_bg_color = TIE_BG_COLOR;      
            default: current_bg_color = FINAL_SCREEN_COLOR; 
        endcase
    end
    
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
        // MAXIMUM PRIORITY: FINAL SCREEN
        if (game_state == 2'b10) begin
            pixel_color = FINAL_SCREEN_COLOR;
            
            if (is_in_bg_rectangle) begin
                pixel_color = current_bg_color; // Color based on who won
            end
            
            // PRIORITY 3: WHITE CHARACTERS 
            if (is_in_character) begin
                case (winner)
                    2'b01: begin // Player 1 wins 
                        if (is_in_number_1) begin
                            pixel_color = CHAR_COLOR; 
                        end
                    end
                    2'b10: begin // Player 2 wins
                        if (is_in_number_2) begin
                            pixel_color = CHAR_COLOR; 
                        end
                    end
                    2'b11: begin // Tie - show "T" white on GRAY background
                        if (is_in_letter_T) begin
                            pixel_color = CHAR_COLOR; 
                        end
                    end
                    default: begin
                        pixel_color = FINAL_SCREEN_COLOR;
                    end
                endcase
            end
        end else begin
            // NORMAL GAME
            pixel_color = BG_COLOR;
            
            if (is_in_board_area) begin
                // Orange selector around selected card
                if (is_selected_card && is_card_border) begin
                    pixel_color = HIGHLIGHT_COLOR;
                end 
                // Card interior
                else if (is_in_card) begin
                    logic card_face_up, card_matched;
                    logic [3:0] card_id;
                    
                    card_face_up = card_states[card_row][card_col][1];
                    card_matched = card_states[card_row][card_col][2];
                    card_id = card_grid[card_row][card_col];
                    
                    if (card_matched) begin
                        // Matched card - symbol with green tint
                        pixel_color = get_symbol_color(card_id, symbol_rel_x, symbol_rel_y);
                        if (pixel_color != CARD_FRONT_COLOR) begin
                            pixel_color = {pixel_color[23:16] >> 1, 8'hFF, pixel_color[7:0] >> 1};
                        end else begin
                            pixel_color = MATCHED_COLOR;
                        end
                    end else if (card_face_up) begin
                        // Face up card - show symbol
                        pixel_color = get_symbol_color(card_id, symbol_rel_x, symbol_rel_y);
                    end else begin
                        // Face down card
                        pixel_color = CARD_BACK_COLOR;
                    end
                end
            end
        end
    end
    
    // Output register
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