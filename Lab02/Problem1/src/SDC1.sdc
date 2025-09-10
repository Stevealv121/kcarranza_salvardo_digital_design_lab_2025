create_clock -name clk -period 20 [get_ports clk]
set_input_delay -clock clk 2 [all_inputs]
set_output_delay -clock clk 2 [all_outputs]