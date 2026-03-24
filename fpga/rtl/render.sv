module render
(
    input logic clk,
    input logic rst,
    input logic[2:0] leftY,
    input logic[2:0] rightY,
    input logic[2:0] ballX,
    input logic[2:0] ballY,
    output logic[7:0] col,
    output logic[7:0] row
);
    logic[2:0] current_col;

    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            current_col <= 0;
        end else
            current_col <= current_col + 1;
    end

    logic [7:0] r;
    always_comb begin
        r = 0;
        col = 8'b00000001 << current_col;
        if(ballX == current_col)
            r |= 8'b00000001 << ballY;
        if(current_col == 0)
            r |= 8'b00000111 << leftY;
        if(current_col == 7)
            r |= 8'b00000111 << rightY;
        row = ~r;
    end

endmodule

