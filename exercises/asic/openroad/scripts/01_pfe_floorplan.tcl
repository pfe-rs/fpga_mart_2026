###############################################################################
# Zadatak 2: Setup
###############################################################################
source scripts/startup.tcl

read_verilog ../yosys/out/pfe_yosys.v
link_design pfe_chip

read_sdc src/constraints.sdc

check_setup -verbose > reports/01-01_pfe_checks.rpt

report_checks -unconstrained -format end \
    -no_line_splits >> reports/01-01_pfe_checks.rpt
report_checks -path_delay max -format end \
    -no_line_splits >> reports/01-01_pfe_checks.rpt
report_checks -path_delay min -format end \
    -no_line_splits >> reports/01-01_pfe_checks.rpt

source scripts/power_connect.tcl

###############################################################################
# Zadatak 3: Inicijalizacija floorplan-a
###############################################################################

set chipH    2000; # OR die height (top to bottom)
set chipW    2000; # OR die width (left to right)
set padD      180; # pad depth (edge to core)
set padW       80; # pad width (beachfront)
set padBond    70; # bonding pad size
set powerRing  80; # reserved space for power ring

# starting from the outside and working towards the core area on each side
set coreMargin [expr {$padD + $padBond + $powerRing}];

utl::report "Initialize Chip"
# coordinates are lower-left x and y, upper-right x and y
initialize_floorplan -die_area "0 0 $chipW $chipH" \
                     -core_area "$coreMargin $coreMargin [expr $chipW-$coreMargin] [expr $chipH-$coreMargin]" \
                     -site "CoreSite"


###############################################################################
# Zadatak 6: Postavljanje I/O pinova, prvo modifikujte src/pfe_padring.tcl
###############################################################################
source src/pfe_padring.tcl

make_tracks

set siteHeight [ord::dbu_to_microns [[dpl::get_row_site] getHeight]]


###############################################################################
# Zadatak 7: Postavljanje SRAM makro celija (ISKLJUČENO)
###############################################################################
# SRAM placement is disabled because the design was synthesized with USE_SRAM=0.
# No SRAM macros exist  in the netlist, so no placement is needed.


###############################################################################
# Zadatak 8: Napajanje
###############################################################################
source scripts/power_grid.tcl

###############################################################################
# Zadatak 9: Checkpoint
###############################################################################
save_checkpoint 01_pfe.floorplan
report_image "01_pfe.floorplan" true