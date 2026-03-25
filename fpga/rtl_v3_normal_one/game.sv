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

    input logic [3:0] seed, //seed
    input logic paddleLU, //key3
    input logic paddleLD, //key2
    input logic paddleRU, //key1
    input logic paddleRD, //key0
    output logic [7:0] col, //gpio pins
    output logic [7:0] row,
    output logic [6:0] HEX0, //hex0
    output logic [6:0] HEX1, //hex1
    output logic [6:0] HEX4, //hex4
    output logic [6:0] HEX5 //hex5

);
    logic [3:0] scoreL;
    logic [3:0] scoreR;

    logic[2:0] leftY;
    logic[2:0] rightY;
    logic[2:0] ballX;
    logic[2:0] ballY;

    logic[31:0] speedUp;
    logic clk_game;
    logic clk_led;
    tick #(.DIV(25_000_000)) t1(
        .clk(clk_i),
        .rst(rst_ni),
        .clkDiv(clk_game),
        .speedUp(speedUp)
    );
    tick #(.DIV(50_000)) t2(
        .clk(clk_i),
        .rst(rst_ni),
        .clkDiv(clk_led),
        .speedUp(0)
    );

    render rend(
        .clk(clk_led),
        .rst(rst_ni),
        .leftY(leftY),
        .rightY(rightY),
        .ballX(ballX),
        .ballY(ballY),
        .col(col),
        .row(row)
    );

    game g(
        .clk(clk_game),
        .rst(rst_ni),
        .seed(seed),
        .paddle1_up(!paddleLU),
        .paddle1_down(!paddleLD),
        .paddle2_up(!paddleRU),
        .paddle2_down(!paddleRD),
        .paddle1_y(leftY),
        .paddle2_y(rightY),
        .ball_x(ballX),
        .ball_y(ballY),
        .score1(scoreL),
        .score2(scoreR),
        .speed_up(speedUp)
    );

    sevenseg seg(
        .scoreL(scoreL),
        .scoreR(scoreR),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX4),
        .HEX3(HEX5)
    );

    assign in_ready_o = out_ready_i;
    assign out_valid_o = in_valid_i;
    assign out_data_o = in_data_i;

endmodule



