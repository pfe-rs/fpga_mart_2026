# setup_project.tcl
# Creates the Quartus project with clock, reset and 3 seven-seg displays.
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

# --- Source files ---
set_global_assignment -name VERILOG_FILE ./rtl/jtag_uart_top.v
set_global_assignment -name VERILOG_FILE ./rtl/jtag_uart_controller.v
set_global_assignment -name VERILOG_FILE ./rtl/fifo.v
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/pfe.sv
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/byte_deserializer.sv
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/byte_serializer.sv
set_global_assignment -name QIP_FILE ./jtag_uart_sys/synthesis/jtag_uart_sys.qip
set_global_assignment -name SDC_FILE ./timing.sdc

# --- CLOCK_50 ---
set_location_assignment PIN_AF14 -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50

# --- RESET_N ---
set_location_assignment PIN_AA14 -to RSTN
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to RSTN

# =====================================================
# sedam_seg_o[20:0]
# [6:0]    -> HEX0
# [13:7]   -> HEX1
# [20:14]  -> HEX2
# =====================================================

# --- SW0 ---
set_location_assignment PIN_AB12 -to SW0
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW0

# --- HEX0 -> sedam_seg_o[6:0] ---
set_location_assignment PIN_AE26 -to sedam_seg_o[0]
set_location_assignment PIN_AE27 -to sedam_seg_o[1]
set_location_assignment PIN_AE28 -to sedam_seg_o[2]
set_location_assignment PIN_AG27 -to sedam_seg_o[3]
set_location_assignment PIN_AF28 -to sedam_seg_o[4]
set_location_assignment PIN_AG28 -to sedam_seg_o[5]
set_location_assignment PIN_AH28 -to sedam_seg_o[6]

# --- HEX1 -> sedam_seg_o[13:7] ---
set_location_assignment PIN_AJ29 -to sedam_seg_o[7]
set_location_assignment PIN_AH29 -to sedam_seg_o[8]
set_location_assignment PIN_AH30 -to sedam_seg_o[9]
set_location_assignment PIN_AG30 -to sedam_seg_o[10]
set_location_assignment PIN_AF29 -to sedam_seg_o[11]
set_location_assignment PIN_AF30 -to sedam_seg_o[12]
set_location_assignment PIN_AD27 -to sedam_seg_o[13]

# --- HEX2 -> sedam_seg_o[20:14] ---
set_location_assignment PIN_AB23 -to sedam_seg_o[14]
set_location_assignment PIN_AE29 -to sedam_seg_o[15]
set_location_assignment PIN_AD29 -to sedam_seg_o[16]
set_location_assignment PIN_AC28 -to sedam_seg_o[17]
set_location_assignment PIN_AD30 -to sedam_seg_o[18]
set_location_assignment PIN_AC29 -to sedam_seg_o[19]
set_location_assignment PIN_AC30 -to sedam_seg_o[20]

# --- IO standard for all 3 displays ---
for {set i 0} {$i < 21} {incr i} {
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sedam_seg_o\[$i\]
}

export_assignments
project_close

puts ""
puts "Project setup complete: $project_name"
puts ""