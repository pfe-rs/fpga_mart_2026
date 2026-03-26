module cas # ( parameter int N = 8
) (
    input logic [N-1:0] A_i,
    input logic [N-1:0] B_i,
    input logic S_i,

    output logic [N-1:0] S_A_o,
    output logic [N-1:0] S_B_o
);

    logic E[N+1];
    logic S_A[N+1];
    logic S_B[N+1];

    assign E[0] = 1;
    assign S_A[0] = 0;
    assign S_B[0] = 0;

    genvar i;

    generate
        for (i = 0; i < N; i++) begin : g_i_for
            assign E[i + 1] = E[i] && ~(A_i[N - 1 - i] ^ B_i[N - 1 - i]);
            assign S_A[i + 1] = S_A[i] || (E[i] && A_i[N - 1 - i] && ~B_i[N - 1 - i]);
            assign S_B[i + 1] = S_B[i] || (E[i] && ~A_i[N - 1 - i] && B_i[N - 1 - i]);
        end
    endgenerate

    logic t; assign t = ~S_A[N] && S_B[N];
    logic S; assign S = S_i ^ t;

    logic [N-1:0] out;
    logic [N-1:0] out_n;

    genvar j;

    generate
        for(j = 0; j < N; j++) begin : g_j_for
            assign out[j] = (A_i[j] && ~S) || (B_i[j] && S);
            assign out_n[j] = (A_i[j] && S) || (B_i[j] && ~S);
        end
    endgenerate

    assign S_A_o = out;
    assign S_B_o = out_n;

endmodule
