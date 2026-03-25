# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter   <phsauter@iis.ee.ethz.ch>

# Power planning - Updated for SRAM-less (Register-based) Design

utl::report "Power Grid"
source scripts/floorplan_util.tcl

##########################################################################
# Reset
##########################################################################

if {[info exists power_grid_defined]} {
    pdngen -ripup
    pdngen -reset
} else {
    set power_grid_defined 1
}

##########################################################################
##  Power settings
##########################################################################
# Core Power Ring
## Space between pads and core -> used for power ring
set PowRingSpace  35
## Spacing must meet TM2 rules
set pgcrSpacing 4
## Width must meet TM2 rules
set pgcrWidth 8
## Offset from core to power ring
set pgcrOffset [expr ($PowRingSpace - $pgcrSpacing - 2 * $pgcrWidth) / 2]

# TopMetal1 Core Power Grid
set tpg1Width     3; # arbitrary number
set tpg1Pitch   228; # multiple of pad-pitch
set tpg1Spacing  60; # big enough to skip over a pad
set tpg1Offset   97; # offset from leftX of core

##########################################################################
##  Core Power Grid Generation
##########################################################################

# 1. Define the Core Power Ring (TopMetal1 and TopMetal2)
# This ring surrounds the standard cell area and connects to the IO pads.
add_pdn_ring -grid {core_grid} \
   -layer        {TopMetal1 TopMetal2} \
   -widths       "$pgcrWidth $pgcrWidth" \
   -spacings     "$pgcrSpacing $pgcrSpacing" \
   -core_offsets "$pgcrOffset $pgcrOffset" \
   -add_connect                        \
   -connect_to_pads                    \
   -connect_to_pad_layers TopMetal2

# 2. M1 Standardcell Rows (rails)
# These follow the cell rows to provide VDD/VSS to every logic gate.
add_pdn_stripe -grid {core_grid} -layer {Metal1} -width {0.32} -offset {0} \
               -followpins -extend_to_core_ring

# 3. TopMetal1 Vertical Stripes
# High-level distribution straps to reduce IR drop across the large core area.
add_pdn_stripe  -grid {core_grid} -layer {TopMetal1} -width $tpg1Width \
                -pitch $tpg1Pitch -spacing $tpg1Spacing -offset $tpg1Offset \
                -extend_to_core_ring -snap_to_grid -number_of_straps 7

##########################################################################
##  Layer Connectivity (Vias)
##########################################################################

# Connect vertical TopMetal1 straps to internal horizontal layers
add_pdn_connect -grid {core_grid} -layers {TopMetal1 Metal1}
add_pdn_connect -grid {core_grid} -layers {TopMetal1 Metal3}
add_pdn_connect -grid {core_grid} -layers {TopMetal1 Metal5}

# Connect the power ring and intermediate layers down to the standard cell rails
add_pdn_connect -grid {core_grid} -layers {Metal3 Metal2}
add_pdn_connect -grid {core_grid} -layers {Metal2 Metal1}

##########################################################################
##  Generate
##########################################################################
# Execute the PDN generation and report any failed via placements.
pdngen -failed_via_report ${report_dir}/01_${proj_name}_pdngen.rpt