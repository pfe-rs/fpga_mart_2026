`default_nettype none

module jtag_uart_top (
    input wire CLOCK_50,
    input wire RSTN
);

    // =====================================================
    // PFE parametri: DSIZE je 8 (ulaz), a izlaz je uvek 16
    // =====================================================
    localparam IN_DSIZE  = 8;   
    localparam OUT_DSIZE = 16;  
    // =====================================================

    wire rst_n = RSTN;

    // Avalon-MM bus
    wire        av_chipselect;
    wire        av_address;
    wire        av_read_n;
    wire [31:0] av_readdata;
    wire        av_write_n;
    wire [31:0] av_writedata;
    wire        av_waitrequest;

    // Stream veze
    wire [7:0]  ctrl_fifo_data;
    wire        ctrl_fifo_valid;
    wire        ctrl_fifo_ready;
    
    wire [7:0]  fifo_pfe_data;
    wire        fifo_pfe_valid;
    wire        fifo_pfe_ready;

    wire [15:0] pfe_fifo_data;
    wire        pfe_fifo_valid;
    wire        pfe_fifo_ready;

    wire [7:0]  fifo_ser_data;
    wire        fifo_ser_valid;
    wire        fifo_ser_ready;

    wire [7:0]  fifo_ctrl_data;
    wire        fifo_ctrl_valid;
    wire        fifo_ctrl_ready;

    // Platform Designer system (JTAG UART IP)
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

    // JTAG UART controller (Pretvara Avalon u Stream)
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
        .tx_data          (fifo_ctrl_data),
        .tx_valid         (fifo_ctrl_valid),
        .tx_ready         (fifo_ctrl_ready)
    );

    // FIFO ulazni bafer (8-bit)
    fifo #(
      .DSIZE (8),
      .ASIZE (8)
    ) u_fifo_rx (
      .clk_i        (CLOCK_50),     
      .rst_ni       (rst_n),
      .in_data_i    (ctrl_fifo_data),    
      .in_valid_i   (ctrl_fifo_valid),
      .in_ready_o   (ctrl_fifo_ready),
      .out_data_o   (fifo_pfe_data),
      .out_valid_o  (fifo_pfe_valid),
      .out_ready_i  (fifo_pfe_ready)
    );

    // PFE modul (Tvoj "bitwise" procesor)
    // Ulaz: 8 bita, Izlaz: 16 bita
    pfe #(
        .DSIZE (IN_DSIZE)
    ) u_pfe (
        .clk_i        (CLOCK_50),
        .rst_ni       (rst_n),
        .in_data_i    (fifo_pfe_data),
        .in_valid_i   (fifo_pfe_valid),
        .in_ready_o   (fifo_pfe_ready),
        .out_data_o   (pfe_fifo_data),
        .out_valid_o  (pfe_fifo_valid),
        .out_ready_i  (pfe_fifo_ready)
    );

    // Serializer (Pretvara 16-bitni rezultat iz PFE u dva 8-bitna bajta za JTAG)
    byte_serializer #(
        .NUM_BYTES (2) // Jer je izlaz iz PFE 16 bita (2 bajta)
    ) u_serializer (
        .clk      (CLOCK_50),
        .rst_n    (rst_n),
        .in_data  (pfe_fifo_data),
        .in_valid (pfe_fifo_valid),
        .in_ready (pfe_fifo_ready),
        .out_data (fifo_ser_data),
        .out_valid(fifo_ser_valid),
        .out_ready(fifo_ser_ready)
    );

    // FIFO izlazni bafer (8-bit)
    fifo #(
      .DSIZE (8), 
      .ASIZE (8)
    ) u_fifo_tx (
      .clk_i        (CLOCK_50),     
      .rst_ni       (rst_n),    
      .in_data_i    (fifo_ser_data),
      .in_valid_i   (fifo_ser_valid),
      .in_ready_o   (fifo_ser_ready),
      .out_data_o   (fifo_ctrl_data),
      .out_valid_o  (fifo_ctrl_valid),
      .out_ready_i  (fifo_ctrl_ready)
    );

endmodule

`default_nettype wire
