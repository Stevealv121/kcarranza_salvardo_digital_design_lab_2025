module card_shuffler(
    input logic clk,
    input logic rst_n,
    input logic shuffle_enable,   // Pulse to start shuffling
    output logic shuffle_done,    // High when shuffling is complete
    output logic [3:0] card_grid[3:0][3:0] // Shuffled card arrangement
);

    // States for shuffling process
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        INIT_CARDS = 3'b001,
        CALC_INDEX = 3'b010,    // Calculate random index
        SHUFFLE = 3'b011,       // Perform swap
        DONE = 3'b100
    } shuffle_state_t;
    
    shuffle_state_t current_state, next_state;
    
    // Random number generator
    logic [7:0] random_num;
    logic rng_enable;
    
    random_generator rng(
        .clk(clk),
        .rst_n(rst_n),
        .enable(rng_enable),
        .random_out(random_num)
    );
    
    // Shuffling variables
    logic [3:0] temp_array [15:0];  // Temporary array for shuffling
    logic [3:0] shuffle_counter;
    logic [3:0] swap_index;
    logic [3:0] temp_value;
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Next state logic
    always_comb begin
        case (current_state)
            IDLE: begin
                next_state = shuffle_enable ? INIT_CARDS : IDLE;
            end
            INIT_CARDS: begin
                next_state = CALC_INDEX;
            end
            CALC_INDEX: begin
                next_state = SHUFFLE;
            end
            SHUFFLE: begin
                next_state = (shuffle_counter == 4'd0) ? DONE : CALC_INDEX;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
    
    // Shuffling logic (Fisher-Yates shuffle algorithm)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shuffle_counter <= 4'd0;
            shuffle_done <= 1'b0;
            rng_enable <= 1'b1; // Always keep RNG running
            swap_index <= 4'd0;
            temp_value <= 4'd0;
            
            // Initialize default card grid explicitly
            temp_array[0] <= 4'd0;   temp_array[1] <= 4'd0;   // Pair of 0s
            temp_array[2] <= 4'd1;   temp_array[3] <= 4'd1;   // Pair of 1s
            temp_array[4] <= 4'd2;   temp_array[5] <= 4'd2;   // Pair of 2s
            temp_array[6] <= 4'd3;   temp_array[7] <= 4'd3;   // Pair of 3s
            temp_array[8] <= 4'd4;   temp_array[9] <= 4'd4;   // Pair of 4s
            temp_array[10] <= 4'd5;  temp_array[11] <= 4'd5;  // Pair of 5s
            temp_array[12] <= 4'd6;  temp_array[13] <= 4'd6;  // Pair of 6s
            temp_array[14] <= 4'd7;  temp_array[15] <= 4'd7;  // Pair of 7s
        end else begin
            case (current_state)
                IDLE: begin
                    shuffle_done <= 1'b0;
                    if (shuffle_enable) begin
                        shuffle_counter <= 4'd15; // Start from 15 (last index)
                        // Re-initialize array with pairs of cards
                        temp_array[0] <= 4'd0; temp_array[1] <= 4'd0;
                        temp_array[2] <= 4'd1; temp_array[3] <= 4'd1;
                        temp_array[4] <= 4'd2; temp_array[5] <= 4'd2;
                        temp_array[6] <= 4'd3; temp_array[7] <= 4'd3;
                        temp_array[8] <= 4'd4; temp_array[9] <= 4'd4;
                        temp_array[10] <= 4'd5; temp_array[11] <= 4'd5;
                        temp_array[12] <= 4'd6; temp_array[13] <= 4'd6;
                        temp_array[14] <= 4'd7; temp_array[15] <= 4'd7;
                    end
                end
                
                INIT_CARDS: begin
                    // Nothing to do, just transition
                end
                
                CALC_INDEX: begin
                    // Calculate random index for current shuffle_counter
                    if (shuffle_counter > 0) begin
                        swap_index <= (random_num[3:0] % (shuffle_counter + 1));
                    end else begin
                        swap_index <= 4'd0;
                    end
                end
                
                SHUFFLE: begin
                    // Perform the swap using pre-calculated index
                    temp_value <= temp_array[shuffle_counter];
                    temp_array[shuffle_counter] <= temp_array[swap_index];
                    temp_array[swap_index] <= temp_value;
                    
                    // Decrement counter
                    shuffle_counter <= shuffle_counter - 1;
                end
                
                DONE: begin
                    shuffle_done <= 1'b1;
                    // Copy shuffled array to card grid
                    card_grid[0][0] <= temp_array[0];  card_grid[0][1] <= temp_array[1];
                    card_grid[0][2] <= temp_array[2];  card_grid[0][3] <= temp_array[3];
                    card_grid[1][0] <= temp_array[4];  card_grid[1][1] <= temp_array[5];
                    card_grid[1][2] <= temp_array[6];  card_grid[1][3] <= temp_array[7];
                    card_grid[2][0] <= temp_array[8];  card_grid[2][1] <= temp_array[9];
                    card_grid[2][2] <= temp_array[10]; card_grid[2][3] <= temp_array[11];
                    card_grid[3][0] <= temp_array[12]; card_grid[3][1] <= temp_array[13];
                    card_grid[3][2] <= temp_array[14]; card_grid[3][3] <= temp_array[15];
                end
            endcase
        end
    end

endmodule