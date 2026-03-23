module adder_N # (
  parameter int N = 8
) (
  input  [N-1:0] a_i,
  input  [N-1:0] b_i,
  input          c_i,
  output [N-1:0] sum_o,
  output         overflow_o
);

  logic [N:0] carry;
  genvar i;

  assign carry[0] = c_i;

  generate
    for (i = 0; i < N; i = i + 1) begin : g_adder
      assign sum_o[i]   = a_i[i] ^ b_i[i] ^ carry[i];
      assign carry[i+1] = (a_i[i] & b_i[i]) | (carry[i] & (a_i[i] ^ b_i[i]));
    end
  endgenerate

  assign overflow_o = carry[N] ^ carry[N-1];

endmodule