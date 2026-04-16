create_clock [get_ports clk] -name core_clock -period 10.0
set_input_delay  2.0 -clock core_clock [get_ports {rst_n in_valid in_data[*]}]
set_output_delay 2.0 -clock core_clock [all_outputs]
