###############################################################################
# PFE Mart 2026 - Zadatak 7 & 8: CTS i Priprema
###############################################################################

# 1. Setup okruženja
source scripts/startup.tcl

# 2. Učitavanje prethodnog koraka (Placement)
# Napomena: Proveri da li ti se prethodni checkpoint zove baš ovako
load_checkpoint 02_pfe.placed

# 3. Podešavanje parazitnih efekata za procenu tajminga
set_wire_rc -clock -layer Metal3
set_wire_rc -signal -layer Metal3

# 4. Izuzimanje padova iz rutiranja (oni su već fiksirani)
set dont_use_pads [list sg13g2_IOPad*]
set_dont_use $dont_use_pads

# 5. Identifikacija clock mreže i uklanjanje "dont_touch" atributa 
# (sada dozvoljavamo alatu da menja clock mrežu ubacivanjem bafera)
set clock_nets [get_nets -of_objects [get_pins -of_objects "*_reg" -filter "name == CLK"]]
unset_dont_touch $clock_nets

# 6. Priprema invertora pre sinteze stabla
repair_clock_inverters

# 7. Definisanje bafera koji će graditi stablo takta (IHP 130nm biblioteka)
set ctsBuf [list sg13g2_buf_16 sg13g2_buf_8 sg13g2_buf_4 sg13g2_buf_2]
set ctsBufRoot "sg13g2_buf_8"

# 8. Pokretanje Clock Tree Synthesis (CTS)
# Alat će ovde pokušati da minimizuje Skew (razliku u kašnjenju)
clock_tree_synthesis -buf_list $ctsBuf \
                     -root_buf $ctsBufRoot \
                     -sink_clustering_enable \
                     -repair_clock_nets

# 9. Legalizacija nakon ubačenih bafera
detailed_placement

# 10. Propagacija takta (sada tajming računamo sa stvarnim kašnjenjima bafera)
set_propagated_clock [all_clocks]

# 11. Popravka tajminga (Setup/Hold) nakon CTS-a
estimate_parasitics -placement
repair_timing -setup -verbose

# 12. Finalna provera postavljanja
check_placement -verbose

# 13. Čuvanje progresa
report_metrics "03_pfe.cts"
save_checkpoint 03_pfe.cts

utl::report "CTS Done! Spremni ste za rutiranje."