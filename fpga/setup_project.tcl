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

set_location_assignment PIN_AA14 -to RSTN
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to RSTN

set_location_assignment PIN_A11 -to VGA_CLK
set_location_assignment PIN_B11 -to VGA_HS
set_location_assignment PIN_D11 -to VGA_VS
set_location_assignment PIN_C10 -to VGA_SYNC_N
set_location_assignment PIN_F10 -to VGA_BLANK_N

# --- VGA_R ---
set_location_assignment PIN_A13 -to VGA_R[0]
set_location_assignment PIN_C13 -to VGA_R[1]
set_location_assignment PIN_E13 -to VGA_R[2]
set_location_assignment PIN_B12 -to VGA_R[3]
set_location_assignment PIN_C12 -to VGA_R[4]
set_location_assignment PIN_D12 -to VGA_R[5]
set_location_assignment PIN_E12 -to VGA_R[6]
set_location_assignment PIN_F13 -to VGA_R[7]

# --- VGA_G ---
set_location_assignment PIN_J9 -to VGA_G[0]
set_location_assignment PIN_J10 -to VGA_G[1]
set_location_assignment PIN_H12 -to VGA_G[2]
set_location_assignment PIN_G10 -to VGA_G[3]
set_location_assignment PIN_G11 -to VGA_G[4]
set_location_assignment PIN_G12 -to VGA_G[5]
set_location_assignment PIN_F11 -to VGA_G[6]
set_location_assignment PIN_E11 -to VGA_G[7]

# --- VGA_B ---
set_location_assignment PIN_B13 -to VGA_B[0]
set_location_assignment PIN_G13 -to VGA_B[1]
set_location_assignment PIN_H13 -to VGA_B[2]
set_location_assignment PIN_F14 -to VGA_B[3]
set_location_assignment PIN_H14 -to VGA_B[4]
set_location_assignment PIN_F15 -to VGA_B[5]
set_location_assignment PIN_G15 -to VGA_B[6]
set_location_assignment PIN_J14 -to VGA_B[7]

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_*

export_assignments
project_close

puts ""
puts "Project setup complete: $project_name"
puts ""
