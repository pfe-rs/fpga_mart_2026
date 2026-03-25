module pfe #(parameter int N=3, parameter int M=2, parameter int DSIZE=2*8)
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

    // State encoding
    localparam int S_LOAD    = 0;
    localparam int S_COMPUTE = 1;
    localparam int S_STORE   = 2;  // one-cycle write to c[]
    localparam int S_OUTPUT  = 3;
    int state;

    logic [DSIZE-1:0] c [N][N];
    logic [7:0] a [N][M];
    logic [7:0] b [M][N];
    logic [15:0] sabirak;

    // Load phase indices
    int load_cnt;
    int a_row, a_col;
    int b_row, b_col;

    // Compute phase indices
    int c_row, c_col, k;

    // Staging register for the completed dot product
    logic [DSIZE-1:0] c_result;
    int               c_wr_row, c_wr_col;
    logic             last_element;

    // Output phase indices
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
        end
        else
        begin
            // Defaults
            out_valid_o <= 0;
            in_ready_o  <= 0;

            case (state)

                // ═══════════════════════════════════════
                //  LOAD: Read N*M beats, fill A and B
                // ═══════════════════════════════════════
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

                // ═══════════════════════════════════════
                //  COMPUTE: accumulate dot product
                //  When dot product is complete, go to
                //  S_STORE for a dedicated write cycle
                // ═══════════════════════════════════════
                S_COMPUTE:
                begin
                    sabirak <= sabirak + a[c_row][k] * b[k][c_col];

                    if (k == M - 1)
                    begin
                        // Dot product complete — capture result and target indices
                        c_result <= sabirak + a[c_row][k] * b[k][c_col];
                        c_wr_row <= c_row;
                        c_wr_col <= c_col;
                        sabirak  <= 0;
                        k        <= 0;

                        // Check if this was the last element
                        if (c_col == N - 1 && c_row == N - 1)
                            last_element <= 1;
                        else
                            last_element <= 0;

                        // Advance indices for the NEXT element
                        if (c_col == N - 1)
                        begin
                            c_col <= 0;
                            c_row <= c_row + 1;
                        end
                        else
                        begin
                            c_col <= c_col + 1;
                        end

                        state <= S_STORE;
                    end
                    else
                    begin
                        k <= k + 1;
                    end
                end

                // ═══════════════════════════════════════
                //  STORE: write result to c[] using
                //  captured (stable) indices
                // ═══════════════════════════════════════
                S_STORE:
                begin
                    c[c_wr_row][c_wr_col] <= c_result;

                    if (last_element)
                        state <= S_OUTPUT;
                    else
                        state <= S_COMPUTE;
                end

                // ═══════════════════════════════════════
                //  OUTPUT: Stream C elements with
                //  valid/ready handshake
                //
                //  out_valid_o is set via NBA, so it is
                //  only HIGH from the second cycle onward.
                //  We gate the index advance on the
                //  *current* (registered) out_valid_o so
                //  the pointer doesn't move before the
                //  first element is actually presented.
                // ═══════════════════════════════════════
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
                                // All elements sent — reset for next transaction
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
