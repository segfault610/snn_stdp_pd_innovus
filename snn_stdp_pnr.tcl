set DESIGN       snn_stdp
set POWERPLAN_DB ./snn_stdp_powerplan.enc

set OUT_DIR      ./snn_stdp_pnr_reports

file mkdir $OUT_DIR

source $POWERPLAN_DB

verifyConnectivity \
    -type special \
    -nets {VDD VSS} \
    > $OUT_DIR/preplace_pg_connectivity.rpt

checkDesign -all \
    > $OUT_DIR/preplace_checkdesign.rpt

setPlaceMode -fp false

placeDesign -noPrePlaceOpt

checkPlace \
    > $OUT_DIR/placement_check.rpt

reportCongestion -overflow \
    > $OUT_DIR/placement_congestion.rpt

report_timing \
    > $OUT_DIR/prects_timing.rpt

report_area \
    > $OUT_DIR/placement_area.rpt

saveDesign ${DESIGN}_placement.enc

optDesign -preCTS

report_timing \
    > $OUT_DIR/prects_opt_timing.rpt

reportCongestion -overflow \
    > $OUT_DIR/prects_opt_congestion.rpt

saveDesign ${DESIGN}_prects.enc

create_ccopt_clock_tree_spec \
    -file ${DESIGN}_ccopt.spec

source ${DESIGN}_ccopt.spec

ccopt_design -cts

report_timing \
    > $OUT_DIR/postcts_timing.rpt

report_clock_timing \
    -type latency \
    > $OUT_DIR/postcts_clock_latency.rpt

report_ccopt_skew_groups \
    > $OUT_DIR/postcts_skew.rpt

reportCongestion -overflow \
    > $OUT_DIR/postcts_congestion.rpt

saveDesign ${DESIGN}_cts.enc

optDesign -postCTS

report_timing \
    > $OUT_DIR/postcts_opt_timing.rpt

saveDesign ${DESIGN}_postcts.enc

routeDesign -globalDetail

saveDesign ${DESIGN}_routed.enc

reportCongestion -overflow \
    > $OUT_DIR/postroute_congestion.rpt

report_timing \
    > $OUT_DIR/postroute_timing.rpt

report_timing \
    -early \
    > $OUT_DIR/postroute_hold_timing.rpt

report_clock_timing \
    -type latency \
    > $OUT_DIR/postroute_clock_latency.rpt

verify_drc \
    -report $OUT_DIR/postroute_drc.rpt

verifyConnectivity \
    -type all \
    -nets {VDD VSS} \
    > $OUT_DIR/postroute_pg_connectivity.rpt

checkPlace \
    > $OUT_DIR/postroute_checkplace.rpt

checkDesign -all \
    > $OUT_DIR/postroute_checkdesign.rpt

report_area \
    > $OUT_DIR/postroute_area.rpt

report_power \
    > $OUT_DIR/postroute_power.rpt

defOut -floorplan \
    ${DESIGN}_routed.def

saveDesign ${DESIGN}_final.enc

