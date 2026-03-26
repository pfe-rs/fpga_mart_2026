module pfe #(parameter int N=2, parameter int M=2, parameter int DSIZE=2*8)
(
    input  logic clk_i,
    input  logic rst_ni,
    input  logic [DSIZE-1:0] in_data_i,
    input  logic in_valid_i,
    output  logic in_ready_o,
    output  logic [DSIZE-1:0] out_data_o,
    output  logic out_valid_o,
    input  logic out_ready_i
);
     logic [DSIZE-1:0] c [N][N];
    localparam int S_LOAD    = 0;
    localparam int S_COMPUTE = 1;
    localparam int S_STORE   = 2;
    localparam int S_OUTPUT  = 3;
    int state;


    logic [7:0] a [N][M];
    logic [7:0] b [M][N];
    logic [15:0] sabirak,sabirak2;


    int load_cnt;
    int a_row, a_col;
    int b_row, b_col;


    int c_row, c_col, k;
    logic [DSIZE-1:0] c_result,c_result2;
    int               c_wr_row, c_wr_col;
    logic             last_element;


    int o_row, o_col;

    always_ff @(posedge clk_i or negedge rst_ni)
    begin
        if (~rst_ni)
        begin
            state        <= S_LOAD;
            load_cnt     <= 0;
            a_row        <= 0;
            a_col        <= 0;
            b_row        <= 0;
            b_col        <= 0;
            c_row        <= 0;
            c_col        <= 0;
            k            <= 0;
            o_row        <= 0;
            o_col        <= 0;
            sabirak      <= 0;
            c_result     <= 0;
            c_wr_row     <= 0;
            c_wr_col     <= 0;
            last_element <= 0;
            out_valid_o  <= 0;
            in_ready_o   <= 0;
            sabirak2 <=0;
        end
        else
        begin
            out_valid_o <= 0;
            in_ready_o  <= 0;

            case (state)
                S_LOAD:
                begin
                    in_ready_o <= 1;
                    if (in_valid_i)
                    begin
                        a[a_row][a_col] <= in_data_i[7:0];
                        b[b_row][b_col] <= in_data_i[15:8];

                        if (a_col == M - 1)
                        begin
                            a_col <= 0;
                            a_row <= a_row + 1;
                        end
                        else
                        begin
                            a_col <= a_col + 1;
                        end

                        if (b_col == N - 1)
                        begin
                            b_col <= 0;
                            b_row <= b_row + 1;
                        end
                        else
                        begin
                            b_col <= b_col + 1;
                        end

                        if (load_cnt == N * M - 1)
                        begin
                            state      <= S_COMPUTE;
                            in_ready_o <= 0;
                        end
                        load_cnt <= load_cnt + 1;
                    end
                end


                S_COMPUTE:
                begin
                    sabirak <= sabirak + a[c_row][k] * b[k][c_col] + a[c_row][k+1] * b[k+1][c_col];
                    sabirak2 <= sabirak2 + a[c_row][k]*b[k][c_col+1] +a[c_row][k+1]*b[k+1][c_col+1];
                    if(k==M-2)
                    begin
                        c_col<=c_col+2;
                        state<=S_STORE;
                        sabirak<=0;
                        c_wr_row<=c_row;
                        c_wr_col<=c_col;
                        sabirak2<=0;
                        k<=0;
                        c_result <= sabirak + a[c_row][k] * b[k][c_col]+a[c_row][k+1]*b[k+1][c_col];
                        c_result2<=sabirak2+a[c_row][k]*b[k][c_col+1]+a[c_row][k+1]*b[k+1][c_col+1];
                        if(c_col == N-2 && c_row==N-1)
                            last_element<=1;
                        else
                            last_element<=0;
                        if(c_col==N-2)
                        begin
                            c_col<=0;
                            c_row<=c_row+1;
                        end
                        else
                            c_col<=c_col+2;
                    end
                    else
                        k<=k+2;
                end
                S_STORE:
                begin
                    c[c_wr_row][c_wr_col] <= c_result;
                    c[c_wr_row][c_wr_col+1] <= c_result2;
                    if (last_element)
                        state <= S_OUTPUT;
                    else
                        state <= S_COMPUTE;
                end
                S_OUTPUT:
                begin
                    out_valid_o <= 1;
                    if (out_valid_o && out_ready_i)
                    begin
                        if (o_col == N - 1)
                        begin
                            o_col <= 0;
                            if (o_row == N - 1)
                            begin
                                o_row        <= 0;
                                load_cnt     <= 0;
                                a_row        <= 0;
                                a_col        <= 0;
                                b_row        <= 0;
                                b_col        <= 0;
                                c_row        <= 0;
                                c_col        <= 0;
                                k            <= 0;
                                sabirak      <= 0;
                                last_element <= 0;
                                sabirak2 <=0;
                                state        <= S_LOAD;
                            end
                            else
                                o_row <= o_row + 1;
                        end
                        else
                        begin
                            o_col <= o_col + 1;
                        end
                    end
                end

                default: state <= S_LOAD;
            endcase
        end
    end
    assign out_data_o = c[o_row][o_col];

endmodule
