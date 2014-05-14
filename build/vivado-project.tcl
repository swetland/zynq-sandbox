
source build/tools.tcl

open_bd_design [ get_files *.bd ]
refresh_user_ip

reset_run synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
