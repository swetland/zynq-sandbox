# assorted useful things

proc refresh_ip_core { path } {
	puts "refesh: $path"
	set core [ipx::open_core -set_current false $path]
	list_property $core
	set newrev [expr [get_property core_revision $core] + 1]
	puts "newrev: $newrev"
	set_property core_revision $newrev $core
	ipx::update_checksums $core
	ipx::save_core $core
	ipx::unload_core $path
}

proc refresh_user_ip { } {
	set dir [get_property DIRECTORY [current_project]]
	set ip_list {}
	set cell_list {}

	# look for "user" library IP, note VLNV and cell
	foreach cell [get_bd_cells] {
		set vlnv [get_property VLNV $cell]
		if { [lindex [split $vlnv ":"] 1] == "user" } {
			set name [get_property NAME $cell]
			puts "cell: $name ip $vlnv"
			lappend ip_list $vlnv
			lappend cell_list $cell
		}
	}

	# remove duplicates
	set ip_list [lsort -unique $ip_list]

	# for each VLNV, refresh the IP
	foreach vlnv $ip_list {
		puts "refresh: $vlnv"
		set ip [ get_ipdef -vlnv $vlnv ]
		refresh_ip_core [ get_property XML_FILE_NAME $ip ]
	}

	# refresh catalog
	update_ip_catalog -rebuild

	# upgrade non-block-diagram IPs
	foreach vlnv $ip_list { 
		puts "upgrade: $vlnv"
		upgrade_ip -quiet [ get_ips -quiet -filter ipdef==$vlnv&&scope=="" ]
	}

	# upgrade block-diagram IPs
	upgrade_bd_cells -quiet -reset_cell $cell_list
}
