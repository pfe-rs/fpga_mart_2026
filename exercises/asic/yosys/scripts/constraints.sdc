#############################
## Driving Cells and Loads ##
#############################
# External pads drive chip inputs (e.g. buttons)
# Outputs drive modest external loads (e.g. LEDs/matrix)
set_load 15.0 [all_outputs]
set_driving_cell -lib_cell sg13g2_IOPadOut16mA -pin pad [get_ports { \
  rst_ni \
  paddleLU paddleLD paddleRU paddleRD \
  unused0_i unused1_i \
}]

##################
## Input Clocks ##
##################
puts "Clocks..."

# 50 MHz system clock (period = 20ns)
set TCK_SYS 20.0
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

# Reasonable clock quality assumptions
set_clock_uncertainty 0.10 [get_clocks clk_sys]
set_clock_transition  0.20 [get_clocks clk_sys]

#############
## Reset   ##
#############
puts "Reset..."
# Treat reset as asynchronous for timing closure
set_false_path -from [get_ports rst_ni]
set_input_delay -clock clk_sys -max 1.0 [get_ports rst_ni]
set_input_delay -clock clk_sys -min 0.0 [get_ports rst_ni]

#############
## Inputs   ##
#############
puts "Inputs..."
# Paddles and unused inputs are synchronous to clk_sys (assuming buttons debounced externally)
set_input_delay  -clock clk_sys -min 1.0 [get_ports {paddleLU paddleLD paddleRU paddleRD unused0_i unused1_i}]
set_input_delay  -clock clk_sys -max 3.0 [get_ports {paddleLU paddleLD paddleRU paddleRD unused0_i unused1_i}]

#############
## Outputs  ##
#############
puts "Outputs..."
# Matrix scanning outputs driving external circuitry (LEDs, etc.)
set_output_delay -clock clk_sys -min 1.0 [get_ports {col[*] row[*]}]
set_output_delay -clock clk_sys -max 3.0 [get_ports {col[*] row[*]}]
