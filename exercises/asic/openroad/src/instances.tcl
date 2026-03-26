# pfe_chip-specific instance discovery (SRAM-optional version)

set macros [list]
set sram_cells [list]
set SRAM_MASTER ""

# Definišemo kandidate kao i pre
set SRAM_MASTER_CANDIDATES [list \
    "RM_IHPSG13_2P_256x8_c2_bm_bist" \
    "RM_IHPSG13_1P_256x8_c2_bm_bist" \
]

# Pokušaj pronalaženja mastera
set db [ord::get_db]
foreach master $SRAM_MASTER_CANDIDATES {
    set m [$db findMaster $master]
    if {$m != "NULL" && $m != ""} {
        set SRAM_MASTER $master
        break
    }
}

if {$SRAM_MASTER ne ""} {
    # Ako je master nađen, potraži instance
    set all_cells [get_cells -hierarchical -quiet *]
    foreach c $all_cells {
        if {[get_property $c ref_name] eq $SRAM_MASTER} {
            lappend sram_cells [get_name $c]
        }
    }
    set sram_cells [lsort $sram_cells]
}

# LOGIKA KOJA SPREČAVA GREŠKU:
if {[llength $sram_cells] > 0} {
    puts "INFO: Found [llength $sram_cells] SRAM instances ($SRAM_MASTER)."
    set bank0_sram0 [lindex $sram_cells 0]
    set bank1_sram0 [lindex $sram_cells 1]
    set macros $sram_cells
} else {
    puts "WARNING: No SRAM instances found. Proceeding with standard-cell FIFO (DFF)."
    set bank0_sram0 ""
    set bank1_sram0 ""
    set macros [list]
}

puts "Resolved SRAM macro master:   $SRAM_MASTER"
puts "Macro list:                  $macros"