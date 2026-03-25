module pfe_chip (
    input  wire clk_i,
    input  wire rst_ni,

    // Input stream (10 pads)
    input  wire in_valid_i,
    output wire in_ready_o,
    input  wire in_data_0_i, in_data_1_i, in_data_2_i, in_data_3_i,
    input  wire in_data_4_i, in_data_5_i, in_data_6_i, in_data_7_i,

    // Output stream (6 pads)
    output wire out_valid_o,
    input  wire out_ready_i,
    output wire out_data_0_o, out_data_1_o, out_data_2_o, out_data_3_o,

    // User I/O (6 pads)
    input  wire btn1_i, btn2_i, btn3_i, btn4_i,
    output wire pwm_o,
    output wire status_o,

    // Power (4 pads)
    inout wire VDD, VSS, VDDIO, VSSIO
); 

    // Internal Signals
    logic soc_clk_i, soc_rst_ni;
    logic soc_in_valid, soc_in_ready;
    logic [7:0] soc_in_data;
    logic [3:0] soc_btns;
    logic soc_pwm_out;
    logic soc_out_valid, soc_out_ready;
    logic [7:0] soc_out_data;

    // --- PAD INSTANCES ---
    sg13g2_IOPadIn pad_clk (.pad(clk_i), .p2c(soc_clk_i));
    sg13g2_IOPadIn pad_rst (.pad(rst_ni), .p2c(soc_rst_ni));

    sg13g2_IOPadIn pad_in_valid (.pad(in_valid_i), .p2c(soc_in_valid));
    sg13g2_IOPadOut16mA pad_in_ready (.pad(in_ready_o), .c2p(soc_in_ready));

    sg13g2_IOPadIn pad_in_d0 (.pad(in_data_0_i), .p2c(soc_in_data[0]));
    sg13g2_IOPadIn pad_in_d1 (.pad(in_data_1_i), .p2c(soc_in_data[1]));
    sg13g2_IOPadIn pad_in_d2 (.pad(in_data_2_i), .p2c(soc_in_data[2]));
    sg13g2_IOPadIn pad_in_d3 (.pad(in_data_3_i), .p2c(soc_in_data[3]));
    sg13g2_IOPadIn pad_in_d4 (.pad(in_data_4_i), .p2c(soc_in_data[4]));
    sg13g2_IOPadIn pad_in_d5 (.pad(in_data_5_i), .p2c(soc_in_data[5]));
    sg13g2_IOPadIn pad_in_d6 (.pad(in_data_6_i), .p2c(soc_in_data[6]));
    sg13g2_IOPadIn pad_in_d7 (.pad(in_data_7_i), .p2c(soc_in_data[7]));

    sg13g2_IOPadIn pad_btn1 (.pad(btn1_i), .p2c(soc_btns[0]));
    sg13g2_IOPadIn pad_btn2 (.pad(btn2_i), .p2c(soc_btns[1]));
    sg13g2_IOPadIn pad_btn3 (.pad(btn3_i), .p2c(soc_btns[2]));
    sg13g2_IOPadIn pad_btn4 (.pad(btn4_i), .p2c(soc_btns[3]));

    sg13g2_IOPadOut16mA pad_pwm    (.pad(pwm_o),    .c2p(soc_pwm_out));
    sg13g2_IOPadOut16mA pad_status (.pad(status_o), .c2p(1'b1));

    sg13g2_IOPadOut16mA pad_out_valid (.pad(out_valid_o), .c2p(soc_out_valid));
    sg13g2_IOPadIn      pad_out_ready (.pad(out_ready_i), .p2c(soc_out_ready));
    sg13g2_IOPadOut16mA pad_out_d0 (.pad(out_data_0_o), .c2p(soc_out_data[0]));
    sg13g2_IOPadOut16mA pad_out_d1 (.pad(out_data_1_o), .c2p(soc_out_data[1]));
    sg13g2_IOPadOut16mA pad_out_d2 (.pad(out_data_2_o), .c2p(soc_out_data[2]));
    sg13g2_IOPadOut16mA pad_out_d3 (.pad(out_data_3_o), .c2p(soc_out_data[3]));

    (* dont_touch = "true" *) sg13g2_IOPadVdd   pad_vdd0();
    (* dont_touch = "true" *) sg13g2_IOPadVss   pad_vss0();
    (* dont_touch = "true" *) sg13g2_IOPadIOVdd pad_vddio0();
    (* dont_touch = "true" *) sg13g2_IOPadIOVss pad_vssio0();

    // --- Core Logic ---
    pfe #(.WIDTH(16)) i_core (
        .clk_i(soc_clk_i), .rst_ni(soc_rst_ni),
        .in_valid_i(soc_in_valid), .in_ready_o(soc_in_ready), .in_data_i(soc_in_data),
        .duty_cycle(16'd0), .but1(soc_btns[0]), .but2(soc_btns[1]), .but3(soc_btns[2]), .but4(soc_btns[3]),
        .pwm_out(soc_pwm_out), .out_valid_o(soc_out_valid), .out_ready_i(soc_out_ready), .out_data_o(soc_out_data)
    );
endmodule