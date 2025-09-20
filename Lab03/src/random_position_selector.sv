module random_position_selector(
    input logic clk,
    input logic rst_n,
    input logic select_enable,     // Pulse to select random position
    input logic [2:0] card_states[3:0][3:0], // Current card states
    output logic [1:0] random_row, // Selected random row
    output logic [1:0] random_col, // Selected random column
    output logic selection_valid   // High if a valid position was found
);

    logic [7:0] random_num;
    logic [3:0] available_positions [15:0]; // List of available positions (row*4 + col)
    logic [3:0] available_count;
    logic [3:0] selected_index;
    logic [3:0] selected_position;
    
    // State machine for selection process
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        BUILD_LIST = 2'b01,
        SELECT = 2'b10
    } select_state_t;
    
    select_state_t current_state, next_state;
    logic [3:0] build_counter;
    
    // Random number generator
    random_generator pos_rng(
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1), // Always running
        .random_out(random_num)
    );
    
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
                next_state = select_enable ? BUILD_LIST : IDLE;
            end
            BUILD_LIST: begin
                next_state = (build_counter >= 4'd15) ? SELECT : BUILD_LIST;
            end
            SELECT: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
    
    // Selection logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            random_row <= 2'b00;
            random_col <= 2'b00;
            selection_valid <= 1'b0;
            available_count <= 4'd0;
            build_counter <= 4'd0;
            for (int i = 0; i < 16; i++) begin
                available_positions[i] <= 4'd0;
            end
        end else begin
            case (current_state)
                IDLE: begin
                    selection_valid <= 1'b0;
                    if (select_enable) begin
                        available_count <= 4'd0;
                        build_counter <= 4'd0;
                    end
                end
                
                BUILD_LIST: begin
                    // Build list of available positions one by one
                    logic [1:0] curr_row, curr_col;
                    curr_row = build_counter[3:2];
                    curr_col = build_counter[1:0];
                    
                    if (!card_states[curr_row][curr_col][2]) begin // If not matched
                        available_positions[available_count] <= build_counter;
                        available_count <= available_count + 1;
                    end
                    
                    build_counter <= build_counter + 1;
                end
                
                SELECT: begin
                    // Select random position from available ones
                    if (available_count > 0) begin
                        selected_index <= random_num[3:0] % available_count;
                        selected_position <= available_positions[random_num[3:0] % available_count];
                        random_row <= available_positions[random_num[3:0] % available_count][3:2];
                        random_col <= available_positions[random_num[3:0] % available_count][1:0];
                        selection_valid <= 1'b1;
                    end else begin
                        selection_valid <= 1'b0;
                    end
                end
            endcase
        end
    end

endmodule