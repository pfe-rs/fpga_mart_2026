###############################################################################
# Zadatak 6: Postavljanje I/O pinova
###############################################################################

# TODO: Potrebno nam je 12 pad-ova po stranici (4 power, 8 signal)
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

# ------------------------------------------------------------
# Define the signal pads for each edge (8 signals per edge)
# ------------------------------------------------------------
set west_signal_pads [list \
    pad_in_data_0_i \
    pad_in_data_1_i \
    pad_in_data_2_i \
    pad_in_data_3_i \
    pad_in_data_4_i \
    pad_in_data_5_i \
    pad_out_data_8_o \
    pad_out_data_9_o \
]

set south_signal_pads [list \
    pad_in_data_6_i \
    pad_in_data_7_i \
    pad_in_valid_i \
    pad_in_ready_o \
    pad_clk_i \
    pad_rst_ni \
    pad_out_data_10_o \
    pad_out_data_11_o \
]

set east_signal_pads [list \
    pad_out_data_0_o \
    pad_out_data_1_o \
    pad_out_data_2_o \
    pad_out_data_3_o \
    pad_out_data_4_o \
    pad_out_data_5_o \
    pad_out_data_12_o \
    pad_out_data_13_o \
]

set north_signal_pads [list \
    pad_out_data_6_o \
    pad_out_data_7_o \
    pad_out_valid_o \
    pad_out_ready_i \
    pad_unused0_o \
    pad_unused1_o \
    pad_out_data_14_o \
    pad_out_data_15_o \
]

# ------------------------------------------------------------
# Compute geometry for each edge
# ------------------------------------------------------------
# West edge (top to bottom)
set westSpan  [expr {$chipH - 2*$cornerToPad - $padW}]
set westPitch [expr {floor($westSpan / double($numPadsPerEdge - 1))}]
set westStart [expr {$chipH - $cornerToPad - $padW}]

# South edge (left to right)
set southSpan  [expr {$chipW - 2*$cornerToPad - $padW}]
set southPitch [expr {floor($southSpan / double($numPadsPerEdge - 1))}]
set southStart $cornerToPad

# East edge (bottom to top)
set eastSpan  [expr {$chipH - 2*$cornerToPad - $padW}]
set eastPitch [expr {floor($eastSpan / double($numPadsPerEdge - 1))}]
set eastStart $cornerToPad

# North edge (right to left)
set northSpan  [expr {$chipW - 2*$cornerToPad - $padW}]
set northPitch [expr {floor($northSpan / double($numPadsPerEdge - 1))}]
set northStart [expr {$chipW - $cornerToPad - $padW}]

# ------------------------------------------------------------
# Build full pad lists (power pads at both ends)
# ------------------------------------------------------------
set west_pad_list [list pad_vssio0 pad_vddio0]
set west_pad_list [concat $west_pad_list $west_signal_pads pad_vss0 pad_vdd0]

set south_pad_list [list pad_vssio1 pad_vddio1]
set south_pad_list [concat $south_pad_list $south_signal_pads pad_vss1 pad_vdd1]

set east_pad_list [list pad_vssio2 pad_vddio2]
set east_pad_list [concat $east_pad_list $east_signal_pads pad_vss2 pad_vdd2]

set north_pad_list [list pad_vssio3 pad_vddio3]
set north_pad_list [concat $north_pad_list $north_signal_pads pad_vss3 pad_vdd3]

# ------------------------------------------------------------
# Place pads on each edge
# ------------------------------------------------------------
# West edge (descending y)
for {set i 0} {$i < $numPadsPerEdge} {incr i} {
    set pad_name [lindex $west_pad_list $i]
    set y_pos [expr {$westStart - $i * $westPitch}]
    place_pad -row IO_WEST -location $y_pos $pad_name
}

# South edge (ascending x)
for {set i 0} {$i < $numPadsPerEdge} {incr i} {
    set pad_name [lindex $south_pad_list $i]
    set x_pos [expr {$southStart + $i * $southPitch}]
    place_pad -row IO_SOUTH -location $x_pos $pad_name
}

# East edge (ascending y)
for {set i 0} {$i < $numPadsPerEdge} {incr i} {
    set pad_name [lindex $east_pad_list $i]
    set y_pos [expr {$eastStart + $i * $eastPitch}]
    place_pad -row IO_EAST -location $y_pos $pad_name
}

# North edge (descending x)
for {set i 0} {$i < $numPadsPerEdge} {incr i} {
    set pad_name [lindex $north_pad_list $i]
    set x_pos [expr {$northStart - $i * $northPitch}]
    place_pad -row IO_NORTH -location $x_pos $pad_name
}

# ------------------------------------------------------------
# Finish padring
# ------------------------------------------------------------
place_corners $iocorner

place_io_fill -row IO_NORTH {*}$iofill
place_io_fill -row IO_SOUTH {*}$iofill
place_io_fill -row IO_WEST  {*}$iofill
place_io_fill -row IO_EAST  {*}$iofill

connect_by_abutment

# Bondpad as separate cell placed in OpenROAD:
place_bondpad -bond $bondPadCell -offset {5.0 -70.0} pad_*

remove_io_rows
