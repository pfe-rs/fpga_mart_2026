
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
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256

set_global_assignment -name VERILOG_FILE ./rtl/jtag_uart_top.v
set_global_assignment -name VERILOG_FILE ./rtl/jtag_uart_controller.v
set_global_assignment -name VERILOG_FILE ./rtl/fifo.v
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/pfe.sv
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/sevenseg.sv
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/byte_deserializer.sv
set_global_assignment -name SYSTEMVERILOG_FILE ./rtl/byte_serializer.sv
set_global_assignment -name QIP_FILE jtag_uart_sys/synthesis/jtag_uart_sys.qip
set_global_assignment -name SDC_FILE timing.sdc

set_location_assignment PIN_AF14 -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50

set_location_assignment PIN_AA14 -to RSTN
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to RSTN

# set_location_assignment PIN_AA15 -to SW[0]   
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[0]

# set_location_assignment PIN_W15 -to SW[1]    
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[1]

# set_location_assignment PIN_Y16 -to SW[2]    
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[2]

# set_location_assignment PIN_AA17 -to KEY[0]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[0]

#============================================================
set_location_assignment PIN_AE26 -to HEX0_N[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0_N[0]
set_location_assignment PIN_AE27 -to HEX0_N[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0_N[1]
set_location_assignment PIN_AE28 -to HEX0_N[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0_N[2]
set_location_assignment PIN_AG27 -to HEX0_N[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0_N[3]
set_location_assignment PIN_AF28 -to HEX0_N[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0_N[4]
set_location_assignment PIN_AG28 -to HEX0_N[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0_N[5]
set_location_assignment PIN_AH28 -to HEX0_N[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0_N[6]
set_location_assignment PIN_AJ29 -to HEX1_N[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1_N[0]
set_location_assignment PIN_AH29 -to HEX1_N[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1_N[1]
set_location_assignment PIN_AH30 -to HEX1_N[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1_N[2]
set_location_assignment PIN_AG30 -to HEX1_N[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1_N[3]
set_location_assignment PIN_AF29 -to HEX1_N[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1_N[4]
set_location_assignment PIN_AF30 -to HEX1_N[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1_N[5]
set_location_assignment PIN_AD27 -to HEX1_N[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1_N[6]
# set_location_assignment PIN_AB23 -to HEX2_N[0]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2_N[0]
# set_location_assignment PIN_AE29 -to HEX2_N[1]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2_N[1]
# set_location_assignment PIN_AD29 -to HEX2_N[2]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2_N[2]
# set_location_assignment PIN_AC28 -to HEX2_N[3]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2_N[3]
# set_location_assignment PIN_AD30 -to HEX2_N[4]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2_N[4]
# set_location_assignment PIN_AC29 -to HEX2_N[5]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2_N[5]
# set_location_assignment PIN_AC30 -to HEX2_N[6]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2_N[6]
# set_location_assignment PIN_AD26 -to HEX3_N[0]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3_N[0]
# set_location_assignment PIN_AC27 -to HEX3_N[1]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3_N[1]
# set_location_assignment PIN_AD25 -to HEX3_N[2]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3_N[2]
# set_location_assignment PIN_AC25 -to HEX3_N[3]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3_N[3]
# set_location_assignment PIN_AB28 -to HEX3_N[4]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3_N[4]
# set_location_assignment PIN_AB25 -to HEX3_N[5]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3_N[5]
# set_location_assignment PIN_AB22 -to HEX3_N[6]
# set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3_N[6]
set_location_assignment PIN_AA24 -to HEX4_N[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4_N[0]
set_location_assignment PIN_Y23 -to HEX4_N[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4_N[1]
set_location_assignment PIN_Y24 -to HEX4_N[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4_N[2]
set_location_assignment PIN_W22 -to HEX4_N[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4_N[3]
set_location_assignment PIN_W24 -to HEX4_N[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4_N[4]
set_location_assignment PIN_V23 -to HEX4_N[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4_N[5]
set_location_assignment PIN_W25 -to HEX4_N[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4_N[6]
set_location_assignment PIN_V25 -to HEX5_N[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5_N[0]
set_location_assignment PIN_AA28 -to HEX5_N[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5_N[1]
set_location_assignment PIN_Y27 -to HEX5_N[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5_N[2]
set_location_assignment PIN_AB27 -to HEX5_N[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5_N[3]
set_location_assignment PIN_AB26 -to HEX5_N[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5_N[4]
set_location_assignment PIN_AA26 -to HEX5_N[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5_N[5]
set_location_assignment PIN_AA25 -to HEX5_N[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5_N[6]
#============================================================



# set_location_assignment PIN_V16 -to LEDR[0]

export_assignments
project_close

puts ""
puts "Project setup complete: $project_name"
puts ""
