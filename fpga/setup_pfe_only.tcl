package require ::quartus::project
set project_name "pfe_test"
project_new -revision $project_name $project_name -overwrite

set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA5F31C6
set_global_assignment -name TOP_LEVEL_ENTITY pfe

# Samo tvoj fajl
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/pfe.sv

export_assignments
project_close