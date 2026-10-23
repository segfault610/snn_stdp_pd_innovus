set DESIGN       snn_stdp
set NETLIST      ./snn_stdp_netlist.v
set SDC_FILE     ./snn_stdp.sdc

set TECH_LEF     "/home/cadence/install/FOUNDRY/digital/90nm/dig/lef/gsclib090_translated.lef"
set MMMC_FILE    "./Default1.view"

set VDD_NET      VDD
set VSS_NET      VSS

set init_verilog              $NETLIST
set init_lef_file             $TECH_LEF
set init_mmmc_file            $MMMC_FILE
set init_design_netlisttype   Verilog

set init_pwr_net              $VDD_NET
set init_gnd_net              $VSS_NET

init_design

globalNetConnect $VDD_NET -type pgpin -pin VDD -inst *
globalNetConnect $VSS_NET -type pgpin -pin VSS -inst *

globalNetConnect $VDD_NET -type pgpin -pin VPWR -inst *
globalNetConnect $VSS_NET -type pgpin -pin VGND -inst *

floorPlan -r 1.0 0.60 10 10 10 10

checkDesign -floorplan

saveDesign ${DESIGN}_floorplan.enc

addRing \
    -nets "$VDD_NET $VSS_NET" \
    -type core_rings \
    -follow core \
    -layer {top M8 bottom M8 left M7 right M7} \
    -width 2 \
    -spacing 2 \
    -offset 2

addStripe \
    -nets "$VDD_NET $VSS_NET" \
    -direction vertical \
    -layer M7 \
    -width 1 \
    -spacing 1 \
    -set_to_set_distance 40 \
    -start_from left

addStripe \
    -nets "$VDD_NET $VSS_NET" \
    -direction horizontal \
    -layer M8 \
    -width 1 \
    -spacing 1 \
    -set_to_set_distance 40 \
    -start_from bottom

sroute \
    -nets "$VDD_NET $VSS_NET" \
    -connect {corePin blockPin padPin floatingStripe} \
    -layerChangeRange {M1 M8} \
    -allowJogging true \
    -allowLayerChange true

verifyConnectivity \
    -type special \
    -nets "$VDD_NET $VSS_NET"

checkDesign -all

saveDesign ${DESIGN}_powerplan.enc

defOut -floorplan ${DESIGN}_floorplan.def

report_area > ${DESIGN}_area.rpt

report_timing > ${DESIGN}_timing.rpt

report_power > ${DESIGN}_power.rpt

