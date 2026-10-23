if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name MIN\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast.lib]
create_library_set -name MAX\
   -timing\
    [list ${::IMEX::libVar}/mmmc/slow.lib]
create_rc_corner -name RC\
   -cap_table ${::IMEX::libVar}/mmmc/gpdk090.lef.extended.CapTbl\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/RC/gpdk090_9l.tch
create_delay_corner -name MAX_DELAY\
   -library_set MAX\
   -rc_corner RC
create_delay_corner -name MIN_DELAY\
   -library_set MIN\
   -rc_corner RC
create_constraint_mode -name CONSTRAINTS\
   -sdc_files\
    [list /dev/null]
create_analysis_view -name WORST_CASE -constraint_mode CONSTRAINTS -delay_corner MAX_DELAY -latency_file ${::IMEX::libVar}/mmmc/latency.sdc
create_analysis_view -name BEST_CASE -constraint_mode CONSTRAINTS -delay_corner MIN_DELAY -latency_file ${::IMEX::libVar}/mmmc/latency.sdc
set_analysis_view -setup [list WORST_CASE] -hold [list BEST_CASE]
