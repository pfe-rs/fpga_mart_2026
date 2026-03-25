# FIFO chip backend constraints for Yosys/OpenROAD
# Single-clock top with one external stream input and one external stream output



#############################
## Driving Cells and Loads ##
#############################
# Reasonable default assumptions for pad-limited chip IO.
# External drivers are modeled as SG13 output pads driving this chip's inputs.
# External loads are modeled as modest off-chip load on this chip's outputs.
set_load 15.0 [all_outputs]
set_driving_cell -lib_cell sg13g2_IOPadOut16mA -pin pad [get_ports [list \
  rst_ni \
  VGA_H VGA_V \
  VGA_R0 VGA_R1 VGA_R2 VGA_R3 VGA_R4 VGA_R5 VGA_R6 VGA_R7 \
  VGA_G0 VGA_G1 VGA_G2 VGA_G3 VGA_G4 VGA_G5 VGA_G6 VGA_G7 \
  VGA_B0 VGA_B1 VGA_B2 VGA_B3 VGA_B4 VGA_B5 VGA_B6 VGA_B7 
]]

##################
## Input Clocks ##
##################
puts "Clocks..."

# 50 MHz system clock
set TCK_SYS 40.0
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

# Reasonable clock quality assumptions
set_clock_uncertainty 0.10 [get_clocks clk_sys]
set_clock_transition  0.20 [get_clocks clk_sys]

#############
## Resets   ##
#############
puts "Reset..."
# Treat reset as asynchronous for timing closure.
set_false_path -from [get_ports rst_ni]
set_input_delay -clock clk_sys -max 1.0 [get_ports rst_ni]
set_input_delay -clock clk_sys -min 0.0 [get_ports rst_ni]

#############
## Inputs   ##
#############
puts "Inputs..."
# Input stream arriving from external logic.
set_input_delay  -clock clk_sys -min 1.0 [get_ports {in_valid_i out_ready_i in_data_*_i}]
set_input_delay  -clock clk_sys -max 3.0 [get_ports {in_valid_i out_ready_i in_data_*_i}]

#############
## Outputs  ##
#############
puts "Outputs..."
# Output stream observed by external logic.
set_output_delay -clock clk_sys -min 1.0 [get_ports {in_ready_o out_valid_o out_data_*_o unused*_o}]
set_output_delay -clock clk_sys -max 3.0 [get_ports {in_ready_o out_valid_o out_data_*_o unused*_o}]

