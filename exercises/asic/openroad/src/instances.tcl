# pfe_chip-specific instance discovery
# SRAM logic removed - design uses standard cell registers (FFs)

# Inicijalizacija prazne liste makroa
set macros [list]

# Pomoćna procedura za dobijanje imena ćelije (zadržana radi kompatibilnosti)
proc get_cell_name {cell} {
    if {[catch {set n [get_name $cell]}]} {
        set n $cell
    }
    return $n
}

# Pošto dizajn ne koristi eksterne SRAM makroe, lista ostaje prazna.
# OpenROAD će sada tretirati tvoj FIFO kao običnu logiku (standardne ćelije).
set sram_cells [list]

puts "Informacija: Dizajn je konfigurisan bez eksternih SRAM makroa."
puts "Sva memorija (FIFO) biće realizovana pomoću standardnih ćelija (Flip-Flopova)."
puts "Macro list: $macros"