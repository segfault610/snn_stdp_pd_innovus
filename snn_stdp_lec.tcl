# 1. Read Liberty Library
read_library /home/cadence/install/FOUNDRY/digital/90nm/dig/lib/slow.lib -liberty -both

# 2. Read Golden (RTL) Design
read_design snn_stdp.v -verilog -golden

# 3. Read Revised Design
read_design snn_stdp_netlist.v -verilog -revised

# 4. Explicitly Set Top/Root Module for both Golden and Revised
set_root_module snn_stdp -golden
set_root_module snn_stdp -revised

# 5. Switch to LEC mode 
set_system_mode lec

# 6. Map and Compare Points
add_compared_points -all
compare

# 7. Print Verification Report
report_verification

