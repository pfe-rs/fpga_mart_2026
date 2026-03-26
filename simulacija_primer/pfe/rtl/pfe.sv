module pfe #(
    parameter int DSIZE  = 8
)(
    input  logic             clk_i,
    input  logic             rst_ni,
    // Input
    input  logic [DSIZE-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,
    // Output
    output logic [DSIZE-1:0] out_data_o,
    output logic             out_valid_o,
    input  logic             out_ready_i,
    input logic rx,
    output logic tx
);

    pfe1 #(8,50000000 ,9600) dut_tx (
        .clk_i(clk_i), 
        .rst_ni(rst_ni),
        .in_data_i(in_data_i), 
        .in_valid_i(in_valid_i), 
        .in_ready_o(in_ready_o),
        .tx(tx)
    );
    pfe2 #(8, 5208, 13) dut_rx (
        .clk_i(clk_i), 
        .out_ready_i(out_ready_i), 
        .rx(rx),
        .out_data_o(out_data_o), 
        .out_valid_o(out_valid_o), 
        .busy()
    );

endmodule
