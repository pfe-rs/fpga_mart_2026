module pfe #(parameter DSIZE = 8) (
    input  logic             clk_i,
    input  logic             rst_ni,
    // Input
    // 8-bit whole input
    input logic [DSIZE-1:0] in_data_i,
    // 8-bit whole output
    output logic [DSIZE-1:0] out_data_o,
    output logic [6:0] HEX0_N, //hex0
    output logic [6:0] HEX1_N, //hex1
    output logic [6:0] HEX4_N, //hex4
    output logic [6:0] HEX5_N, //hex5


    input  logic in_valid_i,
    output logic in_ready_o,

    // Output
    output logic             out_valid_o,
    input  logic             out_ready_i
);
    // ubacene pare
    logic [2:0] nove_pare;
    assign nove_pare = in_data_i[2:0];
    // registri
    logic [2:0] kusur_reg;
    logic [3:0] bananice_reg;

    // trenutno stanje novca nakon ubacivanja
    logic [3:0] novee;

    // da li izbAacuje bananicu
    logic banana;

    // logika
    assign novee = nove_pare + kusur_reg;
    assign in_ready_o = out_ready_i;

    logic [2:0] kusur_next;
    logic [3:0] bananice_next;

    always_comb begin
        // DEFAULT
        kusur_next = kusur_reg;
        bananice_next = bananice_reg;
        banana = 0;

        if (in_valid_i && out_ready_i) begin
            if (bananice_reg < 15 && novee >= 5) begin
                bananice_next = bananice_reg + 1;
                kusur_next = novee - 5;
                banana = 1;
            end
            else begin
                if (bananice_reg<15) begin
                    kusur_next = novee;
                end
                else
                    kusur_next = kusur_reg;
            end
        end
    end


    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            kusur_reg <= 0;
            bananice_reg <= 0;
            out_data_o <= 0;
            out_valid_o <= 0;
        end
        else begin
            kusur_reg <= kusur_next;
            bananice_reg <= bananice_next;
            out_data_o <= {bananice_next, banana , kusur_next};
            out_valid_o <= in_valid_i && out_ready_i;
        end
    end

    sevenseg seg(
        .scoreL(out_data_o[3:0]),
        .scoreR({1'b0, out_data_o[7:5]}), // Padded to 4 bits
        .HEX0_N(HEX0_N),
        .HEX1_N(HEX1_N),
        .HEX2_N(HEX4_N),
        .HEX3_N(HEX5_N)
    );
endmodule
