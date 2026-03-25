module tick #(
    parameter int DIV = 50_000_000 //25_000_000 i 50_000
)(
    input  logic clk,
    input  logic rst,
    input  logic[31:0] speedUp,
    output logic clkDiv
);

    logic [31:0] cnt;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt  <= 0;
            clkDiv <= 0;
        end else begin
            if (cnt >= DIV-speedUp) begin
                cnt  <= 0;
                clkDiv <= 1;
            end else begin
                cnt  <= cnt + 1;
                clkDiv <= 0;
            end
        end
    end

endmodule

