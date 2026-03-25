package require ::quartus::project

set project_name "jtag_uart_project"

if { [project_exists $project_name] } {
    project_open $project_name
} else {
    project_new -revision $project_name $project_name
}

set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA5F31C6
set_global_assignment -name TOP_LEVEL_ENTITY jtag_uart_top
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files

# Fajlovi (Proveri da li su zaista u folderu rtl/)
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/jtag_uart_top.v
set_global_assignment -name VERILOG_FILE ./rtl/jtag_uart_controller.v
set_global_assignment -name VERILOG_FILE ./rtl/fifo.v
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/pfe.sv
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/sevenseg.sv
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/byte_deserializer.sv
set_global_assignment -name QIP_FILE jtag_uart_sys/synthesis/jtag_uart_sys.qip
set_global_assignment -name SDC_FILE timing.sdc

# Clock i Reset
set_location_assignment PIN_AF14 -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_location_assignment PIN_AA14 -to RSTN
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to RSTN

# HEX0_N (Kredit - desni displej)
set_location_assignment PIN_AE26 -to HEX0_N[0]
set_location_assignment PIN_AE27 -to HEX0_N[1]
set_location_assignment PIN_AE28 -to HEX0_N[2]
set_location_assignment PIN_AG27 -to HEX0_N[3]
set_location_assignment PIN_AF28 -to HEX0_N[4]
set_location_assignment PIN_AG28 -to HEX0_N[5]
set_location_assignment PIN_AH28 -to HEX0_N[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0_N[*]

# HEX4_N (Prodato - peti displej s desna)
set_location_assignment PIN_AA24 -to HEX4_N[0]
set_location_assignment PIN_Y23 -to HEX4_N[1]
set_location_assignment PIN_Y24 -to HEX4_N[2]
set_location_assignment PIN_W22 -to HEX4_N[3]
set_location_assignment PIN_W24 -to HEX4_N[4]
set_location_assignment PIN_V23 -to HEX4_N[5]
set_location_assignment PIN_W25 -to HEX4_N[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4_N[*]

export_assignments
project_close