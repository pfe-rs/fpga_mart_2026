# FIFO chip backend constraints
# Prilagodjeno za tvoj novi dizajn sa rx_i i tx_o

# 1. OBRISANO: source src/instances.tcl (Ovo je pravilo problem sa SRAM-om)

#############################
## Driving Cells and Loads ##
#############################
# Postavljamo opterecenje na jedini izlazni pin
set_load 15.0 [get_ports tx_o]

# Postavljamo snagu drajvera za ulazne pinove
set_driving_cell -lib_cell sg13g2_IOPadOut16mA -pin pad [get_ports [list \
  rst_ni \
  rx_i \
]]

##################
## Input Clocks ##
##################
puts "Clocks..."

# 50 MHz system clock (Period 20ns)
set TCK_SYS 20.0
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

# Clock uncertainty i transition
set_clock_uncertainty 0.10 [get_clocks clk_sys]
set_clock_transition  0.20 [get_clocks clk_sys]

#############
## Resets   ##
#############
puts "Reset..."
# Reset tretiramo kao asinhron put (false path) da ne bi opteretio tajming
set_false_path -from [get_ports rst_ni]
set_input_delay -clock clk_sys -max 1.0 [get_ports rst_ni]
set_input_delay -clock clk_sys -min 0.0 [get_ports rst_ni]

#############
## Inputs   ##
#############
puts "Inputs..."
# Tvoj novi rx_i ulaz
set_input_delay  -clock clk_sys -min 1.0 [get_ports rx_i]
set_input_delay  -clock clk_sys -max 3.0 [get_ports rx_i]

#############
## Outputs  ##
#############
puts "Outputs..."
# Tvoj novi tx_o izlaz
set_output_delay -clock clk_sys -min 1.0 [get_ports tx_o]
set_output_delay -clock clk_sys -max 3.0 [get_ports tx_o]
