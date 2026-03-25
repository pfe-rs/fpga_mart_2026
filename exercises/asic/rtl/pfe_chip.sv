module pfe_chip (
    input  logic             clk_i,
    input  logic             rst_ni,

    input logic paddleLU, //key3
    input logic paddleLD, //key2
    input logic paddleRU, //key1
    input logic paddleRD, //key0
    output logic [7:0] col, //gpio pins
    output logic [7:0] row,

  input wire unused0_i,
  input wire unused1_i,

  inout wire VDD,
  inout wire VSS,
  inout wire VDDIO,
  inout wire VSSIO
);
    logic soc_clk_i;
    logic soc_rst_ni;
    logic soc_unused0_0,soc_unused1_0;

    logic soc_paddleLD, soc_paddleLU, soc_paddleRD, soc_paddleRU;
    logic[7:0] soc_row, soc_col;

    sg13g2_IOPadIn        pad_clk_i        (.pad(clk_i),        .p2c(soc_clk_i));
    sg13g2_IOPadIn        pad_rst_ni       (.pad(rst_ni),       .p2c(soc_rst_ni));

    sg13g2_IOPadIn pad_unused0_i      (.pad(unused0_i),    .p2c(soc_unused0_0));
    sg13g2_IOPadIn pad_unused1_i      (.pad(unused1_i),    .p2c(soc_unused1_0));

    sg13g2_IOPadIn        pad_paddleLD   (.pad(paddleLD),    .p2c(soc_paddleLD));
    sg13g2_IOPadIn        pad_paddleLU   (.pad(paddleLU),    .p2c(soc_paddleLU));
    sg13g2_IOPadIn        pad_paddleRD   (.pad(paddleRD),    .p2c(soc_paddleRD));
    sg13g2_IOPadIn        pad_paddleRU   (.pad(paddleRU),    .p2c(soc_paddleRU));

    sg13g2_IOPadOut16mA   pad_col0   (.pad(col[0]),    .c2p(soc_col[0]));
    sg13g2_IOPadOut16mA   pad_col1   (.pad(col[1]),    .c2p(soc_col[1]));
    sg13g2_IOPadOut16mA   pad_col2   (.pad(col[2]),    .c2p(soc_col[2]));
    sg13g2_IOPadOut16mA   pad_col3   (.pad(col[3]),    .c2p(soc_col[3]));
    sg13g2_IOPadOut16mA   pad_col4   (.pad(col[4]),    .c2p(soc_col[4]));
    sg13g2_IOPadOut16mA   pad_col5   (.pad(col[5]),    .c2p(soc_col[5]));
    sg13g2_IOPadOut16mA   pad_col6   (.pad(col[6]),    .c2p(soc_col[6]));
    sg13g2_IOPadOut16mA   pad_col7   (.pad(col[7]),    .c2p(soc_col[7]));

    sg13g2_IOPadOut16mA   pad_row0   (.pad(row[0]),    .c2p(soc_row[0]));
    sg13g2_IOPadOut16mA   pad_row1   (.pad(row[1]),    .c2p(soc_row[1]));
    sg13g2_IOPadOut16mA   pad_row2   (.pad(row[2]),    .c2p(soc_row[2]));
    sg13g2_IOPadOut16mA   pad_row3   (.pad(row[3]),    .c2p(soc_row[3]));
    sg13g2_IOPadOut16mA   pad_row4   (.pad(row[4]),    .c2p(soc_row[4]));
    sg13g2_IOPadOut16mA   pad_row5   (.pad(row[5]),    .c2p(soc_row[5]));
    sg13g2_IOPadOut16mA   pad_row6   (.pad(row[6]),    .c2p(soc_row[6]));
    sg13g2_IOPadOut16mA   pad_row7   (.pad(row[7]),    .c2p(soc_row[7]));

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

  pfe #(
    .DSIZE    (8)
  )
  i_pfe (
    .clk_i          ( soc_clk_i  ),
    .rst_ni         ( soc_rst_ni ),
    .paddleLD       (soc_paddleLD),
    .paddleLU       (soc_paddleLU),
    .paddleRD       (soc_paddleRD),
    .paddleRU       (soc_paddleRU),
    .col            (soc_col),
    .row            (soc_row)
  );

endmodule
