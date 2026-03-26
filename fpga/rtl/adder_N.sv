`timescale 1ns/1ps

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
