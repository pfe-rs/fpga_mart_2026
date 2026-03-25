module pfe #(
    parameter int N = 3,
    parameter int M = 2,
    parameter int DSIZE = 2 * 8
) (
    input logic clk_i,
    input logic rst_ni,
    input logic [DSIZE-1:0] in_data_i,
    input logic in_valid_i,
    output logic in_ready_o,
    output logic [DSIZE-1:0] out_data_o,
    output logic out_valid_o,
    input logic out_ready_i
);


  logic [DSIZE-1:0] c[N][N];
  int red, kol, inc, br, red12, red22, kol12, kol22, br1, red2, kol2, br2;
  logic [7:0] a[N][M];
  logic [7:0] b[M][N];
  logic [15:0] sabirak;
  logic is_idle = 1;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      red <= 0;
      kol <= 0;
      inc <= 0;
      sabirak <= 0;
      red12 <= 0;
      kol22 <= 0;
      red22 <= 0;
      red2 <= 0;
      kol12 <= 0;
      kol2 <= 0;
      br <= 0;
      br1 <= 0;
      br2 <= 0;
      out_valid_o <= 0;
      in_ready_o <= 0;
      is_idle <= 1;
    end else if (is_idle) begin
      red <= 0;
      kol <= 0;
      inc <= 0;
      sabirak <= 0;
      red12 <= 0;
      kol22 <= 0;
      red22 <= 0;
      red2 <= 0;
      kol12 <= 0;
      kol2 <= 0;
      br <= 0;
      br1 <= 0;
      br2 <= 0;
      out_valid_o <= 0;
      in_ready_o <= 0;
      is_idle <= 0;
    end else begin
      if (br < N * M) begin
        in_ready_o <= 1;
        if (in_valid_i) begin
          a[red12][kol12] <= in_data_i[7:0];
          kol12 <= kol12 + 1;
          if (kol12 == M - 1) begin
            kol12 <= 0;
            red12 <= red12 + 1;
          end
          b[red22][kol22] <= in_data_i[15:8];
          kol22 <= kol22 + 1;
          if (kol22 == N - 1) begin
            kol22 <= 0;
            red22 <= red22 + 1;
          end
          br <= br + 1;
          if (br == N * M - 1) begin
            in_ready_o <= 0;
          end
        end
      end else if (br1 >= M * N * N) begin
        if (br2 < N * N && out_ready_i) begin
          out_valid_o <= 1;
          in_ready_o <= 1;
          kol2 <= kol2 + 1;
          if (kol2 == N - 1) begin
            kol2 <= 0;
            red2 <= red2 + 1;
          end
          br2 <= br2 + 1;
        end
      end else begin
        br1 <= br1 + 1;

        sabirak <= sabirak + a[red][inc] * b[inc][kol];
        inc <= inc + 1;
        if (inc == M - 1) begin
          inc <= 0;
          c[red][kol] <= sabirak + a[red][inc] * b[inc][kol];
          sabirak <= 0;
          kol <= kol + 1;
          if (kol == N - 1) begin
            kol <= 0;
            red <= red + 1;
            if (red == N - 1) begin
              red <= 0;
            end
          end
        end
      end
    end
  end
  assign out_data_o = c[red2][kol2];
endmodule
