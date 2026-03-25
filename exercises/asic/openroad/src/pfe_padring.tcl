# TODO: Potrebno nam je 10 pad-ova po stranici, ukoliko vam je potrebno manje ili vise, promenite ovaj broj
set numPadsPerEdge 12

# corner width is equal to padD, bondpad outside
set cornerToPad [expr {$padBond + $padD}]

make_io_sites -horizontal_site sg13g2_ioSite \
    -vertical_site sg13g2_ioSite \
    -corner_site sg13g2_ioSite \
    -offset $padBond \
    -rotation_horizontal R0 \
    -rotation_vertical R0 \
    -rotation_corner R0

###############################################################################
# Zadatak 6: Postavljanje I/O pinova
###############################################################################

##########################################################################
# Edge: LEFT (top to bottom)                                             #
##########################################################################
set westSpan  [expr {$chipH - 2*$cornerToPad - $padW}]
set westPitch [expr {floor($westSpan / double($numPadsPerEdge - 1))}]
set westStart [expr {$chipH - $cornerToPad - $padW}]

place_pad -row IO_WEST -location [expr {$westStart -  0*$westPitch}] "vssio0"
place_pad -row IO_WEST -location [expr {$westStart -  1*$westPitch}] "vddio0"
place_pad -row IO_WEST -location [expr {$westStart -  2*$westPitch}] "in_data_0_i"
place_pad -row IO_WEST -location [expr {$westStart -  3*$westPitch}] "in_data_1_i"
place_pad -row IO_WEST -location [expr {$westStart -  4*$westPitch}] "in_data_2_i"
place_pad -row IO_WEST -location [expr {$westStart -  5*$westPitch}] "in_data_3_i"
place_pad -row IO_WEST -location [expr {$westStart -  6*$westPitch}] "in_data_4_i"
place_pad -row IO_WEST -location [expr {$westStart -  7*$westPitch}] "in_data_5_i"
place_pad -row IO_WEST -location [expr {$westStart -  8*$westPitch}] "vss0"
place_pad -row IO_WEST -location [expr {$westStart -  9*$westPitch}] "vdd0"
place_pad -row IO_WEST -location [expr {$westStart -  10*$westPitch}] "sw0_i"

##########################################################################
# Edge: BOTTOM (left to right)                                           #
##########################################################################
set southSpan  [expr {$chipW - 2*$cornerToPad - $padW}]
set southPitch [expr {floor($southSpan / double($numPadsPerEdge - 1))}]
set southStart $cornerToPad

place_pad -row IO_SOUTH -location [expr {$southStart +  0*$southPitch}] "vssio1"
place_pad -row IO_SOUTH -location [expr {$southStart +  1*$southPitch}] "vddio1"
place_pad -row IO_SOUTH -location [expr {$southStart +  2*$southPitch}] "in_data_6_i"
place_pad -row IO_SOUTH -location [expr {$southStart +  3*$southPitch}] "in_data_7_i"
place_pad -row IO_SOUTH -location [expr {$southStart +  4*$southPitch}] "in_valid_i"
place_pad -row IO_SOUTH -location [expr {$southStart +  5*$southPitch}] "in_ready_o"
place_pad -row IO_SOUTH -location [expr {$southStart +  6*$southPitch}] "clk_i"
place_pad -row IO_SOUTH -location [expr {$southStart +  7*$southPitch}] "rst_ni"
place_pad -row IO_SOUTH -location [expr {$southStart +  8*$southPitch}] "vss1"
place_pad -row IO_SOUTH -location [expr {$southStart +  9*$southPitch}] "vdd1"

##########################################################################
# Edge: RIGHT (bottom to top)                                            #
##########################################################################
set eastSpan  [expr {$chipH - 2*$cornerToPad - $padW}]
set eastPitch [expr {floor($eastSpan / double($numPadsPerEdge - 1))}]
set eastStart $cornerToPad

place_pad -row IO_EAST -location [expr {$eastStart +  0*$eastPitch}] "vssio2"
place_pad -row IO_EAST -location [expr {$eastStart +  1*$eastPitch}] "vddio2"
place_pad -row IO_EAST -location [expr {$eastStart +  2*$eastPitch}] "sedam_seg_0_o"
place_pad -row IO_EAST -location [expr {$eastStart +  3*$eastPitch}] "sedam_seg_1_o"
place_pad -row IO_EAST -location [expr {$eastStart +  4*$eastPitch}] "sedam_seg_2_o"
place_pad -row IO_EAST -location [expr {$eastStart +  5*$eastPitch}] "sedam_seg_3_o"
place_pad -row IO_EAST -location [expr {$eastStart +  6*$eastPitch}] "sedam_seg_4_o"
place_pad -row IO_EAST -location [expr {$eastStart +  7*$eastPitch}] "sedam_seg_5_o"
place_pad -row IO_EAST -location [expr {$eastStart +  8*$eastPitch}] "vss2"
place_pad -row IO_EAST -location [expr {$eastStart +  9*$eastPitch}] "vdd2"
place_pad -row IO_EAST -location [expr {$eastStart +  10*$eastPitch}] "sedam_seg_12_o"
place_pad -row IO_EAST -location [expr {$eastStart +  11*$eastPitch}] "sedam_seg_13_o"

##########################################################################
# Edge: TOP (right to left)                                              #
##########################################################################
set northSpan  [expr {$chipW - 2*$cornerToPad - $padW}]
set northPitch [expr {floor($northSpan / double($numPadsPerEdge - 1))}]
set northStart [expr {$chipW - $cornerToPad - $padW}]

place_pad -row IO_NORTH -location [expr {$northStart -  0*$northPitch}] "vssio3"
place_pad -row IO_NORTH -location [expr {$northStart -  1*$northPitch}] "vddio3"
place_pad -row IO_NORTH -location [expr {$northStart -  2*$northPitch}] "sedam_seg_6_o"
place_pad -row IO_NORTH -location [expr {$northStart -  3*$northPitch}] "sedam_seg_7_o"
place_pad -row IO_NORTH -location [expr {$northStart -  4*$northPitch}] "out_valid_o"
place_pad -row IO_NORTH -location [expr {$northStart -  5*$northPitch}] "out_ready_i"
place_pad -row IO_NORTH -location [expr {$northStart -  6*$northPitch}] "sedam_seg_8_o"
place_pad -row IO_NORTH -location [expr {$northStart -  7*$northPitch}] "sedam_seg_9_o"
place_pad -row IO_NORTH -location [expr {$northStart -  8*$northPitch}] "vss3"
place_pad -row IO_NORTH -location [expr {$northStart -  9*$northPitch}] "vdd3"
place_pad -row IO_NORTH -location [expr {$northStart -  10*$northPitch}] "sedam_seg_10_o"
place_pad -row IO_NORTH -location [expr {$northStart -  11*$northPitch}] "sedam_seg_11_o"

###############################################################################
# Kraj zadatka 6: Postavljanje I/O pinova
###############################################################################
# Fill in the rest of the padring
place_corners $iocorner

place_io_fill -row IO_NORTH {*}$iofill
place_io_fill -row IO_SOUTH {*}$iofill
place_io_fill -row IO_WEST  {*}$iofill
place_io_fill -row IO_EAST  {*}$iofill

# Connect built-in power rings
connect_by_abutment

# Bondpad as separate cell placed in OpenROAD:
# place the bonding pad relative to the IO cell
place_bondpad -bond $bondPadCell -offset {5.0 -70.0} *

# remove rows created by via make_io_sites as they are no longer needed
remove_io_rows
