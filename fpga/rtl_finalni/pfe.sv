module pfe #(
    parameter DSIZE = 8
) (
    input  logic             clk_i,
    input  logic             rst_ni,
    input  logic [DSIZE-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,

    output logic [6:0]       HEX0_N, 
    output logic [6:0]       HEX4_N 
);

    logic [3:0] kredit_reg;
    logic [7:0] prodato_reg;
    logic       in_valid_prev; // Dodato za detekciju ivice

    // 1. ready mora biti assign van always bloka da ne bi kasnio
    assign in_ready_o = 1'b1;

    // 2. Uzmi 4 bita (in_data_i[3:0]) da bi pokrio ASCII cifre 0-9
    logic [4:0] suma;
    assign suma = in_data_i[3:0] + kredit_reg;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            kredit_reg    <= 4'd0;
            prodato_reg   <= 8'd0;
            in_valid_prev <= 1'b0;
        end 
        else begin
            // Pamćenje stanja za ivicu
            in_valid_prev <= in_valid_i;

            // 3. Reaguj samo na RISING EDGE (0 -> 1 prelaz)
            if (in_valid_i && !in_valid_prev) begin
                if (prodato_reg < 10) begin
                    if (suma >= 5) begin
                        kredit_reg  <= suma[3:0] - 4'd5;
                        prodato_reg <= prodato_reg + 1'b1;
                    end 
                    else begin
                        kredit_reg  <= suma[3:0];
                    end
                end
            end
        end
    end

    sevenseg displej_inst (
        .scoreL(prodato_reg[3:0]),
        .scoreR(kredit_reg),
        .HEX0_N(HEX0_N),
        .HEX4_N(HEX4_N)
    );

endmodule