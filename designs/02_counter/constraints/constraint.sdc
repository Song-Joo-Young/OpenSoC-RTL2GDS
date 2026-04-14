create_clock [get_ports clk] -name core_clock -period 5.0
set_input_delay  1.0 -clock core_clock [all_inputs]
set_output_delay 1.0 -clock core_clock [all_outputs]
