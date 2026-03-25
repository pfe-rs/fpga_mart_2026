# pfe_chip-specific instance discovery
# Robust version: handles zero macros gracefully for USE_SRAM=0 designs.

set macros [list]
set sram_names [list]

# Initializing these as empty strings prevents SDC/PDN scripts from crashing
set bank0_sram0 ""
set bank1_sram0 ""

# Search for any cells that might be macros/blocks
# Using -quiet prevents the tool from halting if no matches are found
set sram_cells [get_cells -hierarchical -quiet -filter "is_macro == true"]

if {[llength $sram_cells] > 0} {
    foreach c $sram_cells {
        lappend sram_names [get_name $c]
    }
    set macros [lsort $sram_names]
    set bank0_sram0 [lindex $macros 0]
    set bank1_sram0 [lindex $macros 1]
    
    puts "Found [llength $macros] macros: $macros"
} else {
    # This is the expected path for your current design
    puts "No SRAM macros found in netlist. Proceeding with standard cell logic only."
}