module accumulator #(
    parameter int IN_BYTES = 1,
    parameter int NO2ACC   = 4
)(
    input  logic clk_i,
    input  logic rst_ni,

    input  logic signed [IN_BYTES*8-1:0] in_data_i,
    input  logic                         in_valid_i,
    output logic                         in_ready_o,

    output logic signed [((IN_BYTES*8 + $clog2((NO2ACC<1)?1:NO2ACC)+7)/8)*8-1:0] out_data_o,
    output logic                         out_valid_o,
    input  logic                         out_ready_i
);

    // ------------------------------------------------------------
    // Local params
    // ------------------------------------------------------------
    localparam int ISIZE    = IN_BYTES * 8;
    localparam int SAFE_M   = (NO2ACC < 1) ? 1 : NO2ACC;
    localparam int ACC_BITS = ISIZE + $clog2(SAFE_M);
    localparam int OSIZE    = ((ACC_BITS + 7) / 8) * 8;

    // ------------------------------------------------------------
    // Internal signals
    // ------------------------------------------------------------
    logic signed [OSIZE-1:0] acc_q, acc_d;
    logic [$clog2(SAFE_M):0] cnt_q, cnt_d;

    logic                    out_valid_q, out_valid_d;

    // ------------------------------------------------------------
    // Handshake logic
    // ------------------------------------------------------------
    assign in_ready_o = !out_valid_q;   // block input when output pending
    assign out_valid_o = out_valid_q;
    assign out_data_o  = acc_q;

    // ------------------------------------------------------------
    // Next-state logic
    // ------------------------------------------------------------
    always_comb begin
        acc_d       = acc_q;
        cnt_d       = cnt_q;
        out_valid_d = out_valid_q;

        // Output consumed
        if (out_valid_q && out_ready_i) begin
            out_valid_d = 1'b0;
            acc_d       = '0;
            cnt_d       = '0;
        end

        // Accept input
        if (in_valid_i && in_ready_o) begin
            acc_d = acc_q + OSIZE'($signed(in_data_i));
            cnt_d = cnt_q + 1;

            // Last sample → produce output
            if (cnt_q == SAFE_M-1) begin
                out_valid_d = 1'b1;
            end
        end
    end

    // ------------------------------------------------------------
    // Sequential logic
    // ------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            acc_q       <= '0;
            cnt_q       <= '0;
            out_valid_q <= 1'b0;
        end else begin
            acc_q       <= acc_d;
            cnt_q       <= cnt_d;
            out_valid_q <= out_valid_d;
        end
    end

endmodule
