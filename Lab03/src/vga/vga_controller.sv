module vga_controller( 
    input logic clk,         // 50MHz clock
    input logic [1:0] game_state,
    input logic [1:0] board[5:0][6:0],
    input logic [3:0] turn_timer,
    input logic [1:0] current_player,
    input logic [2:0] column_selected,
    input logic [2:0] win_positions_row[0:3],
    input logic [2:0] win_positions_col[0:3],
    input logic [1:0] win_type,
    output logic SYNC_H,  // VGA HSYNC
    output logic SYNC_V,  // VGA VSYNC
    output logic SYNC_B,
    output logic SYNC_BLANK,
    output logic CLK_VGA,
    output logic [7:0] vga_red, // VGA Red
    output logic [7:0] vga_green, // VGA Green
    output logic [7:0] vga_blue  // VGA Blue
);

    logic[9:0] x,y;
    logic rst,locked;
    pll vgapll(.refclk(clk), .rst(rst), .locked(locked), .outclk_0(CLK_VGA));
     
    vga_synchronizer#(.HACTIVE(640), .HFP(16), .HSYN(96), .HBP(48), .VACTIVE(480), .VFP(11), .VSYN(2), .VBP(32))
        vga_synchronizer(CLK_VGA, SYNC_H, SYNC_V, SYNC_B, SYNC_BLANK, x, y);
		  

    //render the game board
    display_board gui_board (
        .clk_vga(CLK_VGA),
        .x(x),
        .y(y),
        .game_state(game_state),
        .board(board),
        .turn_timer(turn_timer),
        .current_player(current_player),
        .column_selected(column_selected),
        .win_positions_row(win_positions_row),
        .win_positions_col(win_positions_col),
        .win_type(win_type),
        .sync_blank(SYNC_BLANK),
        .vga_r(vga_red),
        .vga_g(vga_green),
        .vga_b(vga_blue)
    );
     
endmodule