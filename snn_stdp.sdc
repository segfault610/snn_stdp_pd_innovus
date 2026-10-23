# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.14-s082_1 on Wed Sep 23 10:01:12 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design snn_stdp

create_clock -name "clk" -period 4.0 -waveform {0.0 2.0} [get_ports clk]
set_clock_transition 0.1 [get_clocks clk]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 0.01 [get_ports reset]
set_output_delay -add_delay 0.01 [get_ports {out_spikes[7]}]
set_output_delay -add_delay 0.01 [get_ports {out_spikes[6]}]
set_output_delay -add_delay 0.01 [get_ports {out_spikes[5]}]
set_output_delay -add_delay 0.01 [get_ports {out_spikes[4]}]
set_output_delay -add_delay 0.01 [get_ports {out_spikes[3]}]
set_output_delay -add_delay 0.01 [get_ports {out_spikes[2]}]
set_output_delay -add_delay 0.01 [get_ports {out_spikes[1]}]
set_output_delay -add_delay 0.01 [get_ports {out_spikes[0]}]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.01 [get_ports clk]
set_clock_uncertainty -hold 0.01 [get_ports clk]
