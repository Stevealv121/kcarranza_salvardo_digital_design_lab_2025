module counter_top_fpga (
    input  logic        clk,           // 50MHz FPGA clock
    input  logic        async_reset_n, // Asynchronous reset (active low)
    input  logic        btn_increment, // Button to increment counter
    input  logic        btn_init_up,   // Button to increase initial value
    input  logic        btn_init_down, // Button to decrease initial value
    input  logic        btn_load_init, // Button to load initial value
    output logic [6:0]  hex0,          // 7-segment display 0 (units)
    output logic [6:0]  hex1,          // 7-segment display 1 (tens)
    output logic [6:0]  hex2           // 7-segment display 2 (show initial value)
);

    // Internal signals
    logic btn_inc_debounced, btn_up_debounced, btn_down_debounced, btn_load_debounced;
    logic btn_inc_edge, btn_up_edge, btn_down_edge, btn_load_edge;
    logic [5:0] counter_value;
    logic [5:0] initial_value;
    logic [3:0] units_digit, tens_digit, init_tens, init_units;
    
    // Button debouncers
    button_debouncer debouncer_inc (
        .clk(clk),
        .reset_n(async_reset_n),
        .button_in(btn_increment),
        .button_out(btn_inc_debounced)
    );
    
    button_debouncer debouncer_up (
        .clk(clk),
        .reset_n(async_reset_n),
        .button_in(btn_init_up),
        .button_out(btn_up_debounced)
    );
    
    button_debouncer debouncer_down (
        .clk(clk),
        .reset_n(async_reset_n),
        .button_in(btn_init_down),
        .button_out(btn_down_debounced)
    );
    
    button_debouncer debouncer_load (
        .clk(clk),
        .reset_n(async_reset_n),
        .button_in(btn_load_init),
        .button_out(btn_load_debounced)
    );
    
    // Edge detectors for buttons
    edge_detector edge_inc (
        .clk(clk),
        .reset_n(async_reset_n),
        .signal_in(btn_inc_debounced),
        .edge_out(btn_inc_edge)
    );
    
    edge_detector edge_up (
        .clk(clk),
        .reset_n(async_reset_n),
        .signal_in(btn_up_debounced),
        .edge_out(btn_up_edge)
    );
    
    edge_detector edge_down (
        .clk(clk),
        .reset_n(async_reset_n),
        .signal_in(btn_down_debounced),
        .edge_out(btn_down_edge)
    );
    
    edge_detector edge_load (
        .clk(clk),
        .reset_n(async_reset_n),
        .signal_in(btn_load_debounced),
        .edge_out(btn_load_edge)
    );
    
    // Initial value controller
    initial_value_controller init_ctrl (
        .clk(clk),
        .reset_n(async_reset_n),
        .btn_up(btn_up_edge),
        .btn_down(btn_down_edge),
        .initial_value(initial_value)
    );
    
    // Main parameterizable counter (6-bit instance)
    parameterizable_counter #(.N_BITS(6)) counter_6bit (
        .clk(clk),
        .async_reset_n(async_reset_n),
        .enable(btn_inc_edge),
        .load_enable(btn_load_edge),
        .load_value(initial_value),
        .counter_out(counter_value)
    );
    
    // Binary to decimal converter for counter value
    binary_to_decimal btd_counter (
        .binary_in(counter_value),
        .tens(tens_digit),
        .units(units_digit)
    );
    
    // Binary to decimal converter for initial value
    binary_to_decimal btd_initial (
        .binary_in(initial_value),
        .tens(init_tens),
        .units(init_units)
    );
    
    // 7-segment decoders
    seven_segment_decoder seg_units (
        .digit(units_digit),
        .segments(hex0)
    );
    
    seven_segment_decoder seg_tens (
        .digit(tens_digit),
        .segments(hex1)
    );
    
    seven_segment_decoder seg_init (
        .digit(init_units), // Show only units of initial value
        .segments(hex2)
    );

endmodule