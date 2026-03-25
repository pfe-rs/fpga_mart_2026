# Konfiguracija za 5 padova po ivici
set numPadsPerEdge 5
set cornerToPad [expr {$padBond + $padD}]

make_io_sites -horizontal_site sg13g2_ioSite \
    -vertical_site sg13g2_ioSite \
    -corner_site sg13g2_ioSite \
    -offset $padBond \
    -rotation_horizontal R0 -rotation_vertical R0 -rotation_corner R0

# Racunanje Pitch-a
set span  [expr {$chipW - 2*$cornerToPad - $padW}]
set pitch [expr {floor($span / double($numPadsPerEdge - 1))}]
set start $cornerToPad

##########################################################################
# LEFT: Napajanje + RX
place_pad -master sg13g2_IOPadIOVss -row IO_WEST -location [expr {$start + 4*$pitch}] "pad_vssio0"
place_pad -master sg13g2_IOPadIOVdd -row IO_WEST -location [expr {$start + 3*$pitch}] "pad_vddio0"
place_pad -master sg13g2_IOPadIn     -row IO_WEST -location [expr {$start + 2*$pitch}] "pad_rx_i"
place_pad -master sg13g2_IOPadVss   -row IO_WEST -location [expr {$start + 1*$pitch}] "pad_vss0"
place_pad -master sg13g2_IOPadVdd   -row IO_WEST -location [expr {$start + 0*$pitch}] "pad_vdd0"

##########################################################################
# BOTTOM: Napajanje + CLK
place_pad -master sg13g2_IOPadIOVss -row IO_SOUTH -location [expr {$start + 0*$pitch}] "pad_vssio1"
place_pad -master sg13g2_IOPadIOVdd -row IO_SOUTH -location [expr {$start + 1*$pitch}] "pad_vddio1"
place_pad -master sg13g2_IOPadIn     -row IO_SOUTH -location [expr {$start + 2*$pitch}] "pad_clk_i"
place_pad -master sg13g2_IOPadVss   -row IO_SOUTH -location [expr {$start + 3*$pitch}] "pad_vss1"
place_pad -master sg13g2_IOPadVdd   -row IO_SOUTH -location [expr {$start + 4*$pitch}] "pad_vdd1"

##########################################################################
# RIGHT: Napajanje + TX
place_pad -master sg13g2_IOPadIOVss -row IO_EAST -location [expr {$start + 0*$pitch}] "pad_vssio2"
place_pad -master sg13g2_IOPadIOVdd -row IO_EAST -location [expr {$start + 1*$pitch}] "pad_vddio2"
place_pad -master sg13g2_IOPadOut16mA -row IO_EAST -location [expr {$start + 2*$pitch}] "pad_tx_o"
place_pad -master sg13g2_IOPadVss   -row IO_EAST -location [expr {$start + 3*$pitch}] "pad_vss2"
place_pad -master sg13g2_IOPadVdd   -row IO_EAST -location [expr {$start + 4*$pitch}] "pad_vdd2"

##########################################################################
# TOP: Napajanje + RST
place_pad -master sg13g2_IOPadIOVss -row IO_NORTH -location [expr {$start + 4*$pitch}] "pad_vssio3"
place_pad -master sg13g2_IOPadIOVdd -row IO_NORTH -location [expr {$start + 3*$pitch}] "pad_vddio3"
place_pad -master sg13g2_IOPadIn     -row IO_NORTH -location [expr {$start + 2*$pitch}] "pad_rst_ni"
place_pad -master sg13g2_IOPadVss   -row IO_NORTH -location [expr {$start + 1*$pitch}] "pad_vss3"
place_pad -master sg13g2_IOPadVdd   -row IO_NORTH -location [expr {$start + 0*$pitch}] "pad_vdd3"

# Finalizacija
place_corners $iocorner
place_io_fill -row IO_NORTH {*}$iofill
place_io_fill -row IO_SOUTH {*}$iofill
place_io_fill -row IO_WEST  {*}$iofill
place_io_fill -row IO_EAST  {*}$iofill

connect_by_abutment
place_bondpad -bond $bondPadCell -offset {5.0 -70.0} pad_*
remove_io_rows