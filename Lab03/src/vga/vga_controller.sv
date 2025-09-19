module vga_controller( 
    input logic clk,                    // 50MHz clock
    input logic [1:0] game_state,       // Game state (01=playing, 10=game_over)
    input logic [3:0] card_grid[3:0][3:0],        // Card IDs (0-7 for symbols)
    input logic [2:0] card_states[3:0][3:0],      // [2]=matched, [1]=face_up, [0]=selected
    input logic [3:0] turn_timer,       // Timer countdown
    input logic [1:0] current_player,   // Current player (1 or 2)
    input logic [1:0] selected_row,     // Currently selected row
    input logic [1:0] selected_col,     // Currently selected column
    input logic [1:0] winner,           // Winner (0=none, 1=P1, 2=P2, 3=tie)
    output logic SYNC_H,                // VGA HSYNC
    output logic SYNC_V,                // VGA VSYNC
    output logic SYNC_B,
    output logic SYNC_BLANK,
    output logic CLK_VGA,
    output logic [7:0] vga_red,         // VGA Red
    output logic [7:0] vga_green,       // VGA Green
    output logic [7:0] vga_blue         // VGA Blue
);

    logic[9:0] x,y;
    logic rst,locked;
    
    // PLL for VGA clock generation
    pll vgapll(.refclk(clk), .rst(rst), .locked(locked), .outclk_0(CLK_VGA));
     
    // VGA synchronizer
    vga_synchronizer#(.HACTIVE(640), .HFP(16), .HSYN(96), .HBP(48), .VACTIVE(480), .VFP(11), .VSYN(2), .VBP(32))
        vga_synchronizer(CLK_VGA, SYNC_H, SYNC_V, SYNC_B, SYNC_BLANK, x, y);
    
    // Memory game display module
    display_memory_board gui_board (
        .clk_vga(CLK_VGA),
        .x(x),
        .y(y),
        .game_state(game_state),
        .card_grid(card_grid),
        .card_states(card_states),
        .turn_timer(turn_timer),
        .current_player(current_player),
        .selected_row(selected_row),
        .selected_col(selected_col),
        .winner(winner),
        .sync_blank(SYNC_BLANK),
        .vga_r(vga_red),
        .vga_g(vga_green),
        .vga_b(vga_blue)
    );
     
endmodule