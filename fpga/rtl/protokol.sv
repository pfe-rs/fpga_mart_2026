`timescale 1ns/1ps

module pfe_top #(
    parameter int DSIZE = 16
)(
    input  logic clk_i,
    input  logic rst_ni,
    input  logic [7:0] data_in,
    input  logic       valid_in,
    output logic       ready_out,
    output logic [7:0] data_out,
    output logic       valid_out,
    input  logic       ready_in
);

    logic [1:0] sel_reg;
    logic [15:0] phase_inc_reg;

    typedef enum logic [2:0] {
        IDLE,
        READ_1,
        READ_2,
        GENERATE
    } state_t;

    state_t state;

    logic [9:0] sample_cnt;

    logic [7:0] out;

    pfe #(
        .DSIZE(DSIZE)
    ) dds_inst (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .phase_increment(phase_inc_reg),
        .sel(sel_reg),
        .out(out),
        .ready(),
        .valid()
    );

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state <= IDLE;
            sample_cnt <= 0;
        end else begin
            case (state)

                IDLE: begin
                    if (valid_in) begin
                        sel_reg <= data_in[1:0];
                        state <= READ_1;
                    end
                end

                READ_1: begin
                    if (valid_in) begin
                        phase_inc_reg[15:8] <= data_in;
                        state <= READ_2;
                    end
                end

                READ_2: begin
                    if (valid_in) begin
                        phase_inc_reg[7:0] <= data_in;
                        sample_cnt <= 0;
                        state <= GENERATE;
                    end
                end

                GENERATE: begin
                    if (ready_in) begin
                        sample_cnt <= sample_cnt + 1;

                        if (sample_cnt == 10'd1023)
                            state <= IDLE;
                    end
                end

            endcase
        end
    end

    assign ready_out = (state == IDLE || state == READ_1 || state == READ_2);

    assign valid_out = (state == GENERATE);

    assign data_out = out;

endmodule