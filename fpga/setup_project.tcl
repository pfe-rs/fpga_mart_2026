# setup_project.tcl
# Creates the Quartus project with only clock and reset pins.
# Run with: quartus_sh -t setup_project.tcl

package require ::quartus::project

set project_name "jtag_uart_project"

if { [project_exists $project_name] } {
    project_open $project_name
} else {
    project_new -revision $project_name $project_name
}

# --- Device ---
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA5F31C6
set_global_assignment -name TOP_LEVEL_ENTITY jtag_uart_top
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

# --- Source files ---
set_global_assignment -name VERILOG_FILE ./rtl/jtag_uart_top.v
set_global_assignment -name VERILOG_FILE ./rtl/jtag_uart_controller.v
set_global_assignment -name VERILOG_FILE ./rtl/fifo.v
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/pfe.sv
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/byte_deserializer.sv
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/byte_serializer.sv
set_global_assignment -name QIP_FILE jtag_uart_sys/synthesis/jtag_uart_sys.qip
set_global_assignment -name SDC_FILE timing.sdc

# --- CLOCK_50 ---
set_location_assignment PIN_AF14 -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50

# --- RESET_N ---
set_location_assignment PIN_AA14 -to RSTN
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to RSTN

# Push-button (KEY0)
set_location_assignment PIN_AA15 -to pw
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pw
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to pw

# LED outputs
set_location_assignment PIN_V16 -to nsg
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nsg

set_location_assignment PIN_W16 -to nsy
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nsy

set_location_assignment PIN_V17 -to ar
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ar

set_location_assignment PIN_V18 -to ewy
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ewy

set_location_assignment PIN_W17 -to ewg
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ewg

# HEX0 (7-segment display)
set_location_assignment PIN_AE26 -to HEX0[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[0]
set_location_assignment PIN_AE27 -to HEX0[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[1]
set_location_assignment PIN_AE28 -to HEX0[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[2]
set_location_assignment PIN_AG27 -to HEX0[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[3]
set_location_assignment PIN_AF28 -to HEX0[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[4]
set_location_assignment PIN_AG28 -to HEX0[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[5]
set_location_assignment PIN_AH28 -to HEX0[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[6]

export_assignments
project_close

puts ""
puts "Project setup complete: $project_name"
puts ""
