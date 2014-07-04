
source out/files.tcl

synth_design -top top -part $part xc7z010clg400-2 

write_checkpoint -force ./out/post-synth-checkpoint.dcp
report_utilization -file ./out/post-synth-utilization.txt
report_timing -sort_by group -max_paths 5 -path_type summary -file ./out/post-synth-timing.txt

opt_design
power_opt_design
place_design
write_checkpoint -force ./out/post-place-checkpoint.dcp

phys_opt_design
route_design
write_checkpoint -force ./out/post-route-checkpoint.dcp

report_utilization -file ./out/post-route-utilization.txt
report_timing_summary -file ./out/post-route-timing-summary.txt
report_timing -sort_by group -max_paths 100 -path_type summary -file ./out/post-route-timing.txt
report_drc -file ./out/post-route-drc.txt
write_verilog -force ./out/post-route-netlist.v
write_xdc -no_fixed_only -force ./out/post-route-constr.xdc

write_bitstream -force -file ./out/design.bit

