// pfe_chip.sv - Integrated Top Level with IO Pads
// Targets IHP SG13G2 Technology

module pfe_chip (
  input  wire clk_i,
  input  wire rst_ni,

  // Input stream
  input  wire in_valid_i,
  output wire in_ready_o,
  input  wire in_data_0_i,
  input  wire in_data_1_i,
  input  wire in_data_2_i,
  input  wire in_data_3_i,
  input  wire in_data_4_i,
  input  wire in_data_5_i,
  input  wire in_data_6_i,
  input  wire in_data_7_i,

  // Output stream
  output wire out_valid_o,
  input  wire out_ready_i,
  output wire out_data_0_o,
  output wire out_data_1_o,
  output wire out_data_2_o,
  output wire out_data_3_o,
  output wire out_data_4_o,
  output wire out_data_5_o,
  output wire out_data_6_o,
  output wire out_data_7_o,
  output wire out_data_8_o,
  output wire out_data_9_o,
  output wire out_data_10_o,
  output wire out_data_11_o,
  output wire out_data_12_o,
  output wire out_data_13_o,
  output wire out_data_14_o,
  output wire out_data_15_o,

  output wire unused0_o,
  output wire unused1_o,

  // Power Pins (Physical wires)
  inout wire VDD,
  inout wire VSS,
  inout wire VDDIO,
  inout wire VSSIO
); 

    // Internal Core Signals
    logic soc_clk_i;
    logic soc_rst_ni;
    logic soc_status_o;
    logic soc_in_valid_i;
    logic soc_in_ready_o;
    logic [7:0] soc_in_data_i; 
    logic soc_out_valid_o;
    logic soc_out_ready_i;            
    (* keep = "true" *) logic [15:0] soc_out_data_o; // Keep attribute prevents bit-pruning

    // --- Signal Inputs ---
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_clk_i    (.pad(clk_i),    .p2c(soc_clk_i));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_rst_ni   (.pad(rst_ni),   .p2c(soc_rst_ni));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_in_valid_i (.pad(in_valid_i), .p2c(soc_in_valid_i));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_out_ready_i(.pad(out_ready_i), .p2c(soc_out_ready_i));

    // --- Input Data Bus Mapping ---
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_in_data_0_i (.pad(in_data_0_i), .p2c(soc_in_data_i[0]));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_in_data_1_i (.pad(in_data_1_i), .p2c(soc_in_data_i[1]));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_in_data_2_i (.pad(in_data_2_i), .p2c(soc_in_data_i[2]));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_in_data_3_i (.pad(in_data_3_i), .p2c(soc_in_data_i[3]));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_in_data_4_i (.pad(in_data_4_i), .p2c(soc_in_data_i[4]));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_in_data_5_i (.pad(in_data_5_i), .p2c(soc_in_data_i[5]));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_in_data_6_i (.pad(in_data_6_i), .p2c(soc_in_data_i[6]));
    (* dont_touch = "true" *) sg13g2_IOPadIn pad_in_data_7_i (.pad(in_data_7_i), .p2c(soc_in_data_i[7]));

    // --- Signal Outputs ---
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_in_ready_o  (.pad(in_ready_o),  .c2p(soc_in_ready_o));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_valid_o (.pad(out_valid_o), .c2p(soc_out_valid_o));

    // --- Output Data Bus Mapping ---
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_0_o (.pad(out_data_0_o), .c2p(soc_out_data_o[0]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_1_o (.pad(out_data_1_o), .c2p(soc_out_data_o[1]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_2_o (.pad(out_data_2_o), .c2p(soc_out_data_o[2]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_3_o (.pad(out_data_3_o), .c2p(soc_out_data_o[3]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_4_o (.pad(out_data_4_o), .c2p(soc_out_data_o[4]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_5_o (.pad(out_data_5_o), .c2p(soc_out_data_o[5]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_6_o (.pad(out_data_6_o), .c2p(soc_out_data_o[6]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_7_o (.pad(out_data_7_o), .c2p(soc_out_data_o[7]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_8_o (.pad(out_data_8_o), .c2p(soc_out_data_o[8]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_9_o (.pad(out_data_9_o), .c2p(soc_out_data_o[9]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_10_o(.pad(out_data_10_o),.c2p(soc_out_data_o[10]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_11_o(.pad(out_data_11_o),.c2p(soc_out_data_o[11]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_12_o(.pad(out_data_12_o),.c2p(soc_out_data_o[12]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_13_o(.pad(out_data_13_o),.c2p(soc_out_data_o[13]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_14_o(.pad(out_data_14_o),.c2p(soc_out_data_o[14]));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_out_data_15_o(.pad(out_data_15_o),.c2p(soc_out_data_o[15]));

    // --- Status/Unused ---
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_unused0_o (.pad(unused0_o), .c2p(soc_status_o));
    (* dont_touch = "true" *) sg13g2_IOPadOut16mA pad_unused1_o (.pad(unused1_o), .c2p(soc_status_o));

    // --- Core VDD (1.2V) ---
    (* dont_touch = "true" *) sg13g2_IOPadVdd pad_vdd0();
    (* dont_touch = "true" *) sg13g2_IOPadVdd pad_vdd1();
    (* dont_touch = "true" *) sg13g2_IOPadVdd pad_vdd2();
    (* dont_touch = "true" *) sg13g2_IOPadVdd pad_vdd3();

    // --- Core VSS (0V) ---
    (* dont_touch = "true" *) sg13g2_IOPadVss pad_vss0();
    (* dont_touch = "true" *) sg13g2_IOPadVss pad_vss1();
    (* dont_touch = "true" *) sg13g2_IOPadVss pad_vss2();
    (* dont_touch = "true" *) sg13g2_IOPadVss pad_vss3();

    // --- IO VDD (3.3V) ---
    (* dont_touch = "true" *) sg13g2_IOPadIOVdd pad_vddio0();
    (* dont_touch = "true" *) sg13g2_IOPadIOVdd pad_vddio1();
    (* dont_touch = "true" *) sg13g2_IOPadIOVdd pad_vddio2();
    (* dont_touch = "true" *) sg13g2_IOPadIOVdd pad_vddio3();

    // --- IO VSS (0V) ---
    (* dont_touch = "true" *) sg13g2_IOPadIOVss pad_vssio0();
    (* dont_touch = "true" *) sg13g2_IOPadIOVss pad_vssio1();
    (* dont_touch = "true" *) sg13g2_IOPadIOVss pad_vssio2();
    (* dont_touch = "true" *) sg13g2_IOPadIOVss pad_vssio3();

  // Instantiate the Core Logic
  pfe #(
    .DSIZE    ( 8 ),
    .COEFF_W  ( 8 )
  ) i_fifo_soc (
    .clk_i          ( soc_clk_i       ),
    .rst_ni         ( soc_rst_ni      ),
    .in_valid_i     ( soc_in_valid_i  ),
    .in_ready_o     ( soc_in_ready_o  ),
    .in_data_i      ( soc_in_data_i   ),
    .out_valid_o    ( soc_out_valid_o ),
    .out_ready_i    ( soc_out_ready_i ),
    .out_data_o     ( soc_out_data_o  )
  );

  assign soc_status_o = 1'b1;

endmodule
