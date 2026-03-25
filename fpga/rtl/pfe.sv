module pfe_top #(
    parameter int DSIZE  = 16
)(
    input logic clk_i,
    input logic rst_ni,
    input logic [DSIZE-1:0] phase_increment,
    input logic [1:0] sel,
    output logic [DSIZE/2-1:0] out,
    output logic ready,
    output logic valid
);

    logic [DSIZE-1:0] acc;

    logic [DSIZE-1:0] sum;
    logic overflow_unused;
    logic [DSIZE-1:0] out_2;
    logic [DSIZE/2-1:0] out_3;

    logic signed [7:0] prav;
    logic signed [7:0] tes;
    logic signed [7:0] tres;
    logic signed [8:0] temp;

    adder_N #(
        .N(DSIZE)
    ) u_adder (
        .a_i(out_2),
        .b_i(phase_increment),
        .c_i(1'b0),
        .sum_o(sum),
        .overflow_o(overflow_unused)
    );

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            acc <= '0;
        else
            acc <= sum;
    end

    assign out_2 = acc;

    assign out_3 = out_2[7:0];

    logic signed [7:0] rom [256];
    initial begin
    $readmemh("lutSin.txt", rom);    end
    logic signed [DSIZE/2-1:0] sin;
    assign sin = $signed(rom[out_3]);

    assign prav = ((out_3) < 128) ? 127 : -128;

    assign tes = (out_3) - 128;

    assign temp = (out_3 < 128) ? (out_3 + out_3 - 128) : (382 - out_3 - out_3);

    assign tres = temp[7:0];

    mux #(
        .N(DSIZE/2)
    ) u_mux (
        .sinus(sin),
        .pravougaonik(prav),
        .testera(tes),
        .trougao(tres),
        .sel(sel),
        .izlaz(out)
    );

    reg ready_reg, valid_reg;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            ready_reg <= 1'b1;
            valid_reg <= 1'b0;
        end
        else begin
            valid_reg <= (sel != 2'b00);
            ready_reg <= !valid_reg;
        end
    end

    assign ready = ready_reg;
    assign valid = valid_reg;

endmodule

module adder_N #(
    parameter int N = 16
)(
    input  [N-1:0] a_i,
    input  [N-1:0] b_i,
    input           c_i,
    output [N-1:0] sum_o,
    output          overflow_o
);

    // Internal carry vector (N+1 bits)
    logic [N:0] c_o;
    assign c_o[0] = c_i;

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : g_ime
            // sum bit
            assign sum_o[i] = a_i[i] ^ b_i[i] ^ c_o[i];
            // carry out
            assign c_o[i+1] = (a_i[i] & b_i[i]) | (a_i[i] & c_o[i]) | (b_i[i] & c_o[i]);
        end
    endgenerate

    // Overflow detection (for signed numbers)
    assign overflow_o = c_o[N] ^ c_o[N-1];

endmodule


module mux #(
    parameter int N = 8
    ) (
    input signed [N-1:0] sinus,  // N-bitni ulazni signal "a"
    input signed [N-1:0] pravougaonik,  // N-bitni ulazni signal "b"
    input signed [N-1:0] testera,
    input signed [N-1:0] trougao,
    input [1:0] sel,        // Kontrolni signal "sel"
    output signed [N-1:0] izlaz  // N-bitni izlazni signal "y"
);

    assign izlaz = sel[0] ? (sel[1] ? sinus : pravougaonik) : (sel[1] ? testera : trougao);
endmodule


module pfe #(parameter int DSIZE = 16
)(
    input  logic clk_i,
    input  logic rst_ni,
    input  logic [23:0] config_data,
    input  logic       config_valid,
    output logic       config_ready,
    output logic [7:0] data_out,
    output logic       data_valid,
    input  logic       data_ready
);

    logic [1:0] sel_reg;
    logic [15:0] phase_inc_reg;

    typedef enum logic [2:0] {
        IDLE,
        GENERATE
    } state_t;

    state_t state;

    logic [9:0] sample_cnt;

    logic [7:0] out;
    logic       pfe_ready_unused;
    logic       pfe_valid_unused;

    pfe_top #(
        .DSIZE(DSIZE)
    ) dds_inst (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .phase_increment(phase_inc_reg),
        .sel(sel_reg),
        .out(out),
        .ready(pfe_ready_unused),
        .valid(pfe_valid_unused)
    );

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state <= IDLE;
            sample_cnt <= 0;
            sel_reg <= 2'b00;
            phase_inc_reg <= 16'b0;
        end else begin
            unique case (state)

                IDLE: begin
                    if (config_valid) begin
                        // Extract configuration from 32-bit word
                        // Byte 0: sel (bits 1:0)
                        // Byte 1: phase_increment[15:8]
                        // Byte 2: phase_increment[7:0]
                        sel_reg <= config_data[1:0];
                        phase_inc_reg[15:8] <= config_data[15:8];
                        phase_inc_reg[7:0] <= config_data[23:16];
                        sample_cnt <= 0;
                        state <= GENERATE;
                    end
                end

                GENERATE: begin
                    if (data_ready) begin
                        sample_cnt <= sample_cnt + 1;

                        if (sample_cnt == 10'd1023)
                            state <= IDLE;
                    end
                end

            endcase
        end
    end

    assign config_ready = (state == IDLE);

    assign data_valid = (state == GENERATE);

    assign data_out = out;

endmodule
