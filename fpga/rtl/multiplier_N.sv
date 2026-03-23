

module multiplier_N #(
  parameter int N = 8
) (
  input  signed [N-1:0] a_i,     // Signed input operand a
  input  signed [N-1:0] b_i,     // Signed input operand b
  output signed [2*N-1:0] prod_o,  // 2*N-bit signed result
  output overflow_o              // Overflow flag
);

  logic signed [2*N-1:0] prod;
  logic signed [N-1:0] a, b;
  logic signed [N:0] carry;

  genvar i,j;

  assign a = a_i;
  assign b = b_i;

  assign prod = 0;

  generate
    for (i=0;i<N;i=i+1) begin: g_multiplier
        for (j=0; j<N;j=j+1) begin: g_prod
            assign prod[i+j] = a[i] & b[j];
        end
    end
  endgenerate

  assign overflow_o = (prod[2*N-1]+prod[2*N-2]);

  assign prod_o = prod;
endmodule
