module card_shuffler(
    input logic clk,
    input logic rst_n,
    input logic shuffle_enable,   // Pulse to start shuffling
    output logic shuffle_done,    // High when shuffling is complete
    output logic [3:0] card_grid[3:0][3:0] // Shuffled card arrangement
);

    // Random number generator
    logic [7:0] random_num;
    logic rng_enable;
    
    random_generator rng(
        .clk(clk),
        .rst_n(rst_n),
        .enable(rng_enable),
        .random_out(random_num)
    );
    
    // Temporary array with guaranteed pairs
    logic [3:0] temp_array [15:0];
    logic [3:0] shuffle_index;
    logic shuffling_active;
    
    assign rng_enable = 1'b1; // RNG always active
    
    // Shuffling process - simplified version
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shuffle_done <= 1'b0;
            shuffling_active <= 1'b0;
            shuffle_index <= 4'd0;
            
            // Guaranteed explicit initialization
            temp_array[0] <= 4'd0;  temp_array[1] <= 4'd1;
            temp_array[2] <= 4'd2;  temp_array[3] <= 4'd3;
            temp_array[4] <= 4'd4;  temp_array[5] <= 4'd5;
            temp_array[6] <= 4'd6;  temp_array[7] <= 4'd7;
            temp_array[8] <= 4'd0;  temp_array[9] <= 4'd1;
            temp_array[10] <= 4'd2; temp_array[11] <= 4'd3;
            temp_array[12] <= 4'd4; temp_array[13] <= 4'd5;
            temp_array[14] <= 4'd6; temp_array[15] <= 4'd7;
            
        end else begin
            if (shuffle_enable && !shuffling_active) begin
                // Start shuffling
                shuffling_active <= 1'b1;
                shuffle_index <= 4'd15;
                shuffle_done <= 1'b0;
            end
            
            if (shuffling_active) begin
                // Perform one swap per clock cycle
                if (shuffle_index > 0) begin
                    logic [3:0] swap_pos;
                    logic [3:0] temp_val;
                    
                    // Calculate random position to swap with
                    swap_pos = random_num[3:0] % (shuffle_index + 1);
                    
                    // Swap elements
                    temp_val = temp_array[shuffle_index];
                    temp_array[shuffle_index] <= temp_array[swap_pos];
                    temp_array[swap_pos] <= temp_val;
                    
                    shuffle_index <= shuffle_index - 1;
                end else begin
                    // Shuffling completed
                    shuffling_active <= 1'b0;
                    shuffle_done <= 1'b1;
                    
                    // Assign to 4x4 grid
                    card_grid[0][0] <= temp_array[0];
                    card_grid[0][1] <= temp_array[1];
                    card_grid[0][2] <= temp_array[2];
                    card_grid[0][3] <= temp_array[3];
                    card_grid[1][0] <= temp_array[4];
                    card_grid[1][1] <= temp_array[5];
                    card_grid[1][2] <= temp_array[6];
                    card_grid[1][3] <= temp_array[7];
                    card_grid[2][0] <= temp_array[8];
                    card_grid[2][1] <= temp_array[9];
                    card_grid[2][2] <= temp_array[10];
                    card_grid[2][3] <= temp_array[11];
                    card_grid[3][0] <= temp_array[12];
                    card_grid[3][1] <= temp_array[13];
                    card_grid[3][2] <= temp_array[14];
                    card_grid[3][3] <= temp_array[15];
                end
            end else begin
                shuffle_done <= 1'b0;
            end
        end
    end

endmodule