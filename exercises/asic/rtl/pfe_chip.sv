module pfe_chip (
  input  wire clk_i,
  input  wire rst_ni,
  input  wire rx_i,       // Glavni ulaz
  output wire tx_o,       // Glavni izlaz

  // Napajanja (ostaju ista za padring)
  inout wire VDD,
  inout wire VSS,
  inout wire VDDIO,
  inout wire VSSIO
); 

    logic soc_clk_i;
    logic soc_rst_ni;
    logic soc_rx_i;
    logic soc_tx_o;

    // Padovi za signale
    sg13g2_IOPadIn        pad_clk_i   (.pad(clk_i),  .p2c(soc_clk_i));
    sg13g2_IOPadIn        pad_rst_ni  (.pad(rst_ni), .p2c(soc_rst_ni));
    sg13g2_IOPadIn        pad_rx_i    (.pad(rx_i),   .p2c(soc_rx_i));
    sg13g2_IOPadOut16mA   pad_tx_o    (.pad(tx_o),   .c2p(soc_tx_o));

    // Power Padovi (Must have za OpenROAD)
    (* dont_touch = "true" *) sg13g2_IOPadVdd   pad_vdd0();   sg13g2_IOPadVdd   pad_vdd1();
    (* dont_touch = "true" *) sg13g2_IOPadVdd   pad_vdd2();   sg13g2_IOPadVdd   pad_vdd3();
    (* dont_touch = "true" *) sg13g2_IOPadVss   pad_vss0();   sg13g2_IOPadVss   pad_vss1();
    (* dont_touch = "true" *) sg13g2_IOPadVss   pad_vss2();   sg13g2_IOPadVss   pad_vss3();
    (* dont_touch = "true" *) sg13g2_IOPadIOVdd pad_vddio0(); sg13g2_IOPadIOVdd pad_vddio1();
    (* dont_touch = "true" *) sg13g2_IOPadIOVdd pad_vddio2(); sg13g2_IOPadIOVdd pad_vddio3();
    (* dont_touch = "true" *) sg13g2_IOPadIOVss pad_vssio0(); sg13g2_IOPadIOVss pad_vssio1();
    (* dont_touch = "true" *) sg13g2_IOPadIOVss pad_vssio2(); sg13g2_IOPadIOVss pad_vssio3();

    // Povezivanje na tvoj SOC - ovde rx_i simulira validan ulaz
    pfe_soc #(
        .DSIZE    ( 8 ),
        .ASIZE    ( 8 ),
        .USE_SRAM ( 1'b0 ) // Iskljucen SRAM kao sto si trazio
    ) i_fifo_soc (
        .clk_i       ( soc_clk_i ),
        .rst_ni      ( soc_rst_ni ),
        .in_valid_i  ( soc_rx_i ), 
        .in_ready_o  ( ),
        .in_data_i   ( {8'b0, soc_rx_i, 7'b0} ), // Mapiramo rx na jedan bit podataka
        .out_valid_o ( soc_tx_o ),
        .out_ready_i ( 1'b1 ),
        .out_data_o  ( )
    );

endmodule