module vga_synchronizer#(parameter
	HACTIVE 	= 10'd640,
	HFP 		= 10'd16,
	HSYN 		= 10'd96,
	HBP 		= 10'd48,
	HMAX 		= HACTIVE + HFP + HSYN + HBP,
	VBP 		= 10'd32,
	VACTIVE	= 10'd480,
	VFP 		= 10'd11,
	VSYN 		= 10'd2,
	VMAX 		= VACTIVE + VFP + VSYN + VBP)(
	input logic CLK_VGA,
	output logic SYNC_H, SYNC_V, SYNC_B, SYNC_BLANK,
	output logic [9:0] x, y);
	
	logic [9:0] h_count, v_count;
	
	always @(posedge CLK_VGA) begin
		if(h_count >= HMAX)begin
			h_count <= 0;
			x <= 0;
			if(v_count >= VMAX)begin
				v_count <= 0;
				y <= 0;
			end else begin
				v_count <= v_count + 1;
				y <= y + 1;
			end
		end else begin
			h_count <= h_count + 1;
			x <= x + 1;
		end
		
	end
	
	assign SYNC_H = ~(h_count >= HACTIVE + HFP & h_count < HACTIVE + HFP + HSYN);
	assign SYNC_V = ~(v_count >= VACTIVE + VFP & v_count < VACTIVE + VFP + VSYN);
	assign SYNC_B = SYNC_H & SYNC_V;
	assign SYNC_BLANK = (h_count < HACTIVE) & (v_count < VACTIVE);
	
endmodule