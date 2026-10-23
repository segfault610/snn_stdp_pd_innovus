set design snn_stdp
set_db init_lib_search_path /home/cadence/install/FOUNDRY/digital/90nm/dig/lib/
read_libs slow.lib
#read_libs /home/cadence/install/FOUNDRY/digital/90nm/dig/lib/slow.lib

set_db init_hdl_search_path /home/userdata/mne13701/ASIC/xcelium
#read_hdl ${design}.v
#read_hdl -f files_${design}
read_hdl snn_stdp.v
elaborate

#read_sdc con.sdc
create_clock -name clk -period 4 [get_ports clk]
#create_clock -name clk -period 4  [get_ports clk]
set_clock_transition -rise 0.1 [get_clocks clk]
set_clock_transition -fall 0.1 [get_clocks clk]
set_clock_uncertainty 0.01 [get_ports clk]
#set_input_delay 0.01 [get_ports all_inputs] -clock [get_clocks clk]
set_input_delay -max 0.01 [get_ports reset] -clock [get_clocks clk]
set_output_delay 0.01 [all_outputs]
#set_output_delay -max 0.01 [get_ports count] -clock [get_clocks clk]

#set_db design:alu .clock_gating_hierarchical true
set_db syn_generic_effort low 
set_db syn_map_effort low
set_db syn_opt_effort low

syn_generic
write_hdl > ${design}_ti_netlist.vgenus

syn_map
write_hdl > ${design}_tm_netlist.v

syn_opt
write_hdl > ${design}_netlist.v

write_sdc > ${design}.sdc

report_area > ${design}_area.rpt
report_power > ${design}_power.rpt

set_db timing_report_unconstrained true
report_timing > ${design}_timing.rpt
#report_timing -unconstrained > ckt1_timing.rpt

report_qor > ${design}_qor.rpt

gui_show

