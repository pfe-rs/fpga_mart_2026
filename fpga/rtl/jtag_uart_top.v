`default_nettype none

module jtag_uart_top (
    input wire         CLOCK_50,
    input wire         RSTN,
    output wire [6:0]  HEX0_N,        
    output wire [6:0]  HEX4_N         
);

    localparam NUM_BYTES = 1; 
    wire rst_n = RSTN;

    // Avalon-MM bus
    wire        av_chipselect;
    wire        av_address;
    wire        av_read_n;
    wire [31:0] av_readdata;
    wire        av_write_n;
    wire [31:0] av_writedata;
    wire        av_waitrequest;

    wire [7:0]  ctrl_fifo_data;
    wire        ctrl_fifo_valid;
    wire        ctrl_fifo_ready;

    wire [7:0]  fifo_deser_data;
    wire        fifo_deser_valid;
    wire        fifo_deser_ready;

    wire [NUM_BYTES*8-1:0] deser_pfe_data;
    wire                   deser_pfe_valid;
    wire                   deser_pfe_ready;

    // 1. Platform Designer (JTAG IP)
    jtag_uart_sys u_sys (
        .clk_clk                              (CLOCK_50),
        .reset_reset_n                        (rst_n),
        .jtag_uart_avalon_chipselect          (av_chipselect),
        .jtag_uart_avalon_address             (av_address),
        .jtag_uart_avalon_read_n              (av_read_n),
        .jtag_uart_avalon_readdata            (av_readdata),
        .jtag_uart_avalon_write_n             (av_write_n),
        .jtag_uart_avalon_writedata           (av_writedata),
        .jtag_uart_avalon_waitrequest         (av_waitrequest)
    );

    // 2. JTAG UART Controller
    jtag_uart_controller u_ctrl (
        .clk              (CLOCK_50),
        .rst_n            (rst_n),
        .av_chipselect    (av_chipselect),
        .av_address       (av_address),
        .av_read_n        (av_read_n),
        .av_readdata      (av_readdata),
        .av_write_n       (av_write_n),
        .av_writedata     (av_writedata),
        .av_waitrequest   (av_waitrequest),
        .rx_data          (ctrl_fifo_data),
        .rx_valid         (ctrl_fifo_valid),
        .rx_ready         (ctrl_fifo_ready),
        .tx_data          (8'd0),
        .tx_valid         (1'b0),
        .tx_ready         ()
    );

    // 3. FIFO
    fifo #(.DSIZE(8), .ASIZE(8)) u_fifo_deser (
        .clk_i(CLOCK_50), .rst_ni(rst_n),
        .in_data_i(ctrl_fifo_data), .in_valid_i(ctrl_fifo_valid), .in_ready_o(ctrl_fifo_ready),
        .out_data_o(fifo_deser_data), .out_valid_o(fifo_deser_valid), .out_ready_i(fifo_deser_ready)
    );

    // 4. Deserializer
    byte_deserializer #(.NUM_BYTES(NUM_BYTES)) u_deserializer (
        .clk(CLOCK_50), .rst_n(rst_n),
        .in_data(fifo_deser_data), .in_valid(fifo_deser_valid), .in_ready(fifo_deser_ready),
        .out_data(deser_pfe_data), .out_valid(deser_pfe_valid), .out_ready(deser_pfe_ready)
    );

    // 5. PFE Logika
    pfe #(.DSIZE(NUM_BYTES*8)) u_pfe (
        .clk_i(CLOCK_50), .rst_ni(rst_n),
        .in_data_i(deser_pfe_data), .in_valid_i(deser_pfe_valid), .in_ready_o(deser_pfe_ready),
        .HEX0_N(HEX0_N), .HEX4_N(HEX4_N)
    );

endmodule