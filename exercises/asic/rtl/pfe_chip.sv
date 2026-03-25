
//definisu se nasi signali 
module pfe_chip (
  input  wire clk_i,
  input  wire rst_ni,

    // Input stream (producer -> FIFO)
  input  wire in_valid_i,
  output wire in_ready_o,
  // input  wire in_data_0_i,
  // input  wire in_data_1_i,
  // input  wire in_data_2_i,
  // input  wire in_data_3_i,
  // input  wire in_data_4_i,
  // input  wire in_data_5_i,
  // input  wire in_data_6_i,
  // input  wire in_data_7_i,
    
  input wire  pw,


  // Output stream (FIFO -> consumer)
  output wire out_valid_o,
  input  wire out_ready_i,
  // output wire out_data_0_o,
  // output wire out_data_1_o,
  // output wire out_data_2_o,
  // output wire out_data_3_o,
  // output wire out_data_4_o,
  // output wire out_data_5_o,
  // output wire out_data_6_o,
  // output wire out_data_7_o,

  output wire   HEX0 [6:0],
  output wire  ar,
  output wire  nsy,
  output wire  nsg,
  output wire  ewy,
  output wire ewg,

  output wire unused0_o,
  output wire unused1_o,

  inout wire VDD,
  inout wire VSS,
  inout wire VDDIO,
  inout wire VSSIO
); 
    logic soc_clk_i;
    logic soc_rst_ni;
    logic soc_ref_clk_i;
    logic soc_testmode_i;

    logic soc_jtag_tck_i;
    logic soc_jtag_trst_ni;
    logic soc_jtag_tms_i;
    logic soc_jtag_tdi_i;
    logic soc_jtag_tdo_o;

    logic soc_status_o;
 
    logic soc_HEX0[6:0];
    logic soc_ar;
    logic soc_nsy;
    logic  soc_nsg;
    logic  soc_ewy;
    logic soc_ewg;
    logic soc_pw;
    localparam int unsigned DataCount = 16;

    logic                 soc_in_valid_i;
    logic                 soc_in_ready_o;
    logic [DataCount-1:0] soc_in_data_i; 
    logic                 soc_out_valid_o;
    logic                 soc_out_ready_i;            
    logic [DataCount-1:0] soc_out_data_o;


    

    sg13g2_IOPadIn        pad_clk_i        (.pad(clk_i),        .p2c(soc_clk_i));
    sg13g2_IOPadIn        pad_rst_ni       (.pad(rst_ni),       .p2c(soc_rst_ni));


    // in_data
    sg13g2_IOPadIn        pad_in_valid_i    (.pad(in_valid_i),    .p2c(soc_in_valid_i));
    sg13g2_IOPadOut16mA   pad_in_ready_o    (.pad(in_ready_o),    .c2p(soc_in_ready_o));

    sg13g2_IOPadIn       pad_pw    (.pad(pw),    .p2c(soc_pw));
    // sg13g2_IOPadIn        pad_in_data_6_i   (.pad(in_data_6_i),   .p2c(soc_in_data_i[6]));
    // sg13g2_IOPadIn        pad_in_data_7_i   (.pad(in_data_7_i),   .p2c(soc_in_data_i[7]));

    // out_data
    sg13g2_IOPadOut16mA   pad_out_valid_o   (.pad(out_valid_o),   .c2p(soc_out_valid_o));
    sg13g2_IOPadIn        pad_out_ready_i   (.pad(out_ready_i),   .p2c(soc_out_ready_i));
    // sg13g2_IOPadOut16mA   pad_out_data_0_o  (.pad(out_data_0_o),  .c2p(soc_out_data_o[0]));
    // sg13g2_IOPadOut16mA   pad_out_data_1_o  (.pad(out_data_1_o),  .c2p(soc_out_data_o[1]));
    // sg13g2_IOPadOut16mA   pad_out_data_2_o  (.pad(out_data_2_o),  .c2p(soc_out_data_o[2]));
    // sg13g2_IOPadOut16mA   pad_out_data_3_o  (.pad(out_data_3_o),  .c2p(soc_out_data_o[3]));
    // sg13g2_IOPadOut16mA   pad_out_data_4_o  (.pad(out_data_4_o),  .c2p(soc_out_data_o[4]));
    // sg13g2_IOPadOut16mA   pad_out_data_5_o  (.pad(out_data_5_o),  .c2p(soc_out_data_o[5]));
    // sg13g2_IOPadOut16mA   pad_out_data_6_o  (.pad(out_data_6_o),  .c2p(soc_out_data_o[6]));
    // sg13g2_IOPadOut16mA   pad_out_data_7_o  (.pad(out_data_7_o),  .c2p(soc_out_data_o[7]));


    sg13g2_IOPadOut16mA pad_HEX0_0 (.pad(HEX0[0]), .c2p(soc_HEX0[0]));
    sg13g2_IOPadOut16mA pad_HEX0_1 (.pad(HEX0[1]), .c2p(soc_HEX0[1]));
    sg13g2_IOPadOut16mA pad_HEX0_2 (.pad(HEX0[2]), .c2p(soc_HEX0[2]));
    sg13g2_IOPadOut16mA pad_HEX0_3 (.pad(HEX0[3]), .c2p(soc_HEX0[3]));
    sg13g2_IOPadOut16mA pad_HEX0_4 (.pad(HEX0[4]), .c2p(soc_HEX0[4]));
    sg13g2_IOPadOut16mA pad_HEX0_5 (.pad(HEX0[5]), .c2p(soc_HEX0[5]));
    sg13g2_IOPadOut16mA pad_HEX0_6 (.pad(HEX0[6]), .c2p(soc_HEX0[6]));

    sg13g2_IOPadOut16mA pad_ar (.pad(ar), .c2p(soc_ar));
    sg13g2_IOPadOut16mA pad_nsg (.pad(nsg), .c2p(soc_nsg));
    sg13g2_IOPadOut16mA pad_nsy (.pad(nsy), .c2p(soc_nsy));
    sg13g2_IOPadOut16mA pad_ewg (.pad(ewg), .c2p(soc_ewg));
    sg13g2_IOPadOut16mA pad_ewy (.pad(ewy), .c2p(soc_ewy));


    sg13g2_IOPadOut16mA pad_unused0_o      (.pad(unused0_o),    .c2p(soc_status_o));



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



    pfe_soc #(
    .DSIZE(8),
    .ASIZE(8)
  ) i_pfe_soc (
    .clk_i      (soc_clk_i),
    .rst_ni     (soc_rst_ni),
    .pw         (soc_pw),
    .in_valid_i (soc_in_valid_i),
    .in_ready_o (soc_in_ready_o),
    .out_valid_o(soc_out_valid_o),
    .out_ready_i(soc_out_ready_i),
    .ar         (soc_ar),
    .nsg        (soc_nsg),
    .nsy        (soc_nsy),
    .ewg        (soc_ewg),
    .ewy        (soc_ewy),
    .HEX0       (soc_HEX0)
  );
 
  //ovde mozda nesto

  assign soc_status_o = 1'b1;

endmodule
