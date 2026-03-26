module pfe_chip (

  input  wire clk_i,
  input  wire rst_ni,

  output wire VGA_H,
  output wire VGA_V,

  // output wire VGA_R0,
  // output wire VGA_R1,
  // output wire VGA_R2,
  // output wire VGA_R3,
  output wire VGA_R4,
  output wire VGA_R5,
  output wire VGA_R6,
  output wire VGA_R7,

  // output wire VGA_G0,
  // output wire VGA_G1,
  // output wire VGA_G2,
  // output wire VGA_G3,
  output wire VGA_G4,
  output wire VGA_G5,
  output wire VGA_G6,
  output wire VGA_G7,

  // output wire VGA_B0,
  // output wire VGA_B1,
  // output wire VGA_B2,
  // output wire VGA_B3,
  output wire VGA_B4,
  output wire VGA_B5,
  output wire VGA_B6,
  output wire VGA_B7,

  inout wire VDD,
  inout wire VSS,
  inout wire VDDIO,
  inout wire VSSIO
); 
    logic soc_clk_i;
    logic soc_rst_ni;

    logic soc_h_sync;           //Ovih 5 je dodato
    logic soc_v_sync;
    logic [7:0] soc_R;
    logic [7:0] soc_G;
    logic [7:0] soc_B;

    logic soc_status_o;

    sg13g2_IOPadIn             pad_clk_i    (.pad(clk_i ),   .p2c(soc_clk_i));
    sg13g2_IOPadIn             pad_rst_ni   (.pad(rst_ni),   .p2c(soc_rst_ni));

    sg13g2_IOPadOut16mA        pad_VGA_H    (.pad(VGA_H),    .c2p(soc_h_sync));
    sg13g2_IOPadOut16mA        pad_VGA_V    (.pad(VGA_V),    .c2p(soc_v_sync));

    // sg13g2_IOPadOut16mA        pad_VGA_R0   (.pad(VGA_R0),   .c2p(soc_R[0]));
    // sg13g2_IOPadOut16mA        pad_VGA_R1   (.pad(VGA_R1),   .c2p(soc_R[1]));
    // sg13g2_IOPadOut16mA        pad_VGA_R2   (.pad(VGA_R2),   .c2p(soc_R[2]));
    // sg13g2_IOPadOut16mA        pad_VGA_R3   (.pad(VGA_R3),   .c2p(soc_R[3]));
    sg13g2_IOPadOut16mA        pad_VGA_R4   (.pad(VGA_R4),   .c2p(soc_R[4]));
    sg13g2_IOPadOut16mA        pad_VGA_R5   (.pad(VGA_R5),   .c2p(soc_R[5]));
    sg13g2_IOPadOut16mA        pad_VGA_R6   (.pad(VGA_R6),   .c2p(soc_R[6]));
    sg13g2_IOPadOut16mA        pad_VGA_R7   (.pad(VGA_R7),   .c2p(soc_R[7]));

    // sg13g2_IOPadOut16mA        pad_VGA_G0   (.pad(VGA_G0),   .c2p(soc_G[0]));
    // sg13g2_IOPadOut16mA        pad_VGA_G1   (.pad(VGA_G1),   .c2p(soc_G[1]));
    // sg13g2_IOPadOut16mA        pad_VGA_G2   (.pad(VGA_G2),   .c2p(soc_G[2]));
    // sg13g2_IOPadOut16mA        pad_VGA_G3   (.pad(VGA_G3),   .c2p(soc_G[3]));
    sg13g2_IOPadOut16mA        pad_VGA_G4   (.pad(VGA_G4),   .c2p(soc_G[4]));
    sg13g2_IOPadOut16mA        pad_VGA_G5   (.pad(VGA_G5),   .c2p(soc_G[5]));
    sg13g2_IOPadOut16mA        pad_VGA_G6   (.pad(VGA_G6),   .c2p(soc_G[6]));
    sg13g2_IOPadOut16mA        pad_VGA_G7   (.pad(VGA_G7),   .c2p(soc_G[7]));

    // sg13g2_IOPadOut16mA        pad_VGA_B0   (.pad(VGA_B0),   .c2p(soc_B[0]));
    // sg13g2_IOPadOut16mA        pad_VGA_B1   (.pad(VGA_B1),   .c2p(soc_B[1]));
    // sg13g2_IOPadOut16mA        pad_VGA_B2   (.pad(VGA_B2),   .c2p(soc_B[2]));
    // sg13g2_IOPadOut16mA        pad_VGA_B3   (.pad(VGA_B3),   .c2p(soc_B[3]));
    sg13g2_IOPadOut16mA        pad_VGA_B4   (.pad(VGA_B4),   .c2p(soc_B[4]));
    sg13g2_IOPadOut16mA        pad_VGA_B5   (.pad(VGA_B5),   .c2p(soc_B[5]));
    sg13g2_IOPadOut16mA        pad_VGA_B6   (.pad(VGA_B6),   .c2p(soc_B[6]));
    sg13g2_IOPadOut16mA        pad_VGA_B7   (.pad(VGA_B7),   .c2p(soc_B[7]));

    (* dont_touch = "true" *)sg13g2_IOPadVdd pad_vdd0();
    (* dont_touch = "true" *)sg13g2_IOPadVdd pad_vdd1();
    (* dont_touch = "true" *)sg13g2_IOPadVdd pad_vdd2();
    (* dont_touch = "true" *)sg13g2_IOPadVdd pad_vdd3();

    (* dont_touch = "true" *)sg13g2_IOPadVss pad_vss0();
    (* dont_touch = "true" *)sg13g2_IOPadVss pad_vss1();
    (* dont_touch = "true" *)sg13g2_IOPadVss pad_vss2();
    (* dont_touch = "true" *)sg13g2_IOPadVss pad_vss3();

    (* dont_touch = "true" *)sg13g2_IOPadIOVdd pad_vddio0();
    (* dont_touch = "true" *)sg13g2_IOPadIOVdd pad_vddio1();
    (* dont_touch = "true" *)sg13g2_IOPadIOVdd pad_vddio2();
    (* dont_touch = "true" *)sg13g2_IOPadIOVdd pad_vddio3();

    (* dont_touch = "true" *)sg13g2_IOPadIOVss pad_vssio0();
    (* dont_touch = "true" *)sg13g2_IOPadIOVss pad_vssio1();
    (* dont_touch = "true" *)sg13g2_IOPadIOVss pad_vssio2();
    (* dont_touch = "true" *)sg13g2_IOPadIOVss pad_vssio3();

  pfe_soc #()

  i_pfe_soc (
    .clk_i          ( soc_clk_i ),
    .rst_ni         ( soc_rst_ni),

    .h_sync         ( soc_h_sync),
    .v_sync         ( soc_v_sync),
    .R              ( soc_R     ),
    .G              ( soc_G     ),
    .B              ( soc_B     )
  );

  assign soc_status_o = 1'b1;

endmodule
