## Copyright 2014 Brian Swetland <swetland@frotz.net>
##
## Licensed under the Apache License, Version 2.0 
## http://www.apache.org/licenses/LICENSE-2.0

# input $name 
#
# - expects HDL source in  ${name}/hdl
# - attempts to generate ${name}/component.xml and other goodies
# - will name module ${name} without any leading .../


set name [lindex $argv 0]

set basename [lindex [split $name "/"] end]

set core [ipx::infer_core $name]

set_property VENDOR example.com $core
set_property SUPPORTED_FAMILIES {{zynq} {Production}} $core
set_property NAME $basename $core
set_property DISPLAY_NAME $basename $core
set_property DESCRIPTION $basename $core

set g1 [ipx::get_file_groups xilinx_verilogsynthesis]
set g2 [ipx::get_file_groups xilinx_verilogbehavioralsimulation]

foreach src [glob $name/hdl/*.v $name/hdl/*.sv] {
	set base [lindex [split $src "/"] end]
	set item [ipx::add_file "hdl/$base" $g1]
	set_property LIBRARY_NAME xil_defaultlib $item
	set item [ipx::add_file "hdl/$base" $g2]
	set_property LIBRARY_NAME xil_defaultlib $item
}

ipx::save_core
exit
