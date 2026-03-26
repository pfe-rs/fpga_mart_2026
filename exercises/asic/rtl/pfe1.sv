module pfe1 #(
    parameter int N  = 8,
    parameter clock_rate = 50000000,
    parameter baud_rate  = 9600
)(
    input  logic             clk_i,
    input  logic             rst_ni,
    input  logic [N-1:0]     in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,
    output logic             tx
);

    localparam int BAUD_LIMIT = clock_rate / baud_rate;

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t state;
    logic [$clog2(BAUD_LIMIT)-1:0] baud_cnt;
    logic [$clog2(N)-1:0] bit_cnt;
    logic [N-1:0] data_reg;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state    <= IDLE;
            tx       <= 1'b1; 
            baud_cnt <= '0;
            bit_cnt  <= '0;
            data_reg <= '0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (in_valid_i) begin
                        data_reg <= in_data_i; 
                        state    <= START;
                        baud_cnt <= '0;
                    end
                end

                START: begin
                    tx <= 1'b0; 
                    if (baud_cnt == BAUD_LIMIT - 1) begin
                        baud_cnt <= '0;
                        state    <= DATA;
                        bit_cnt  <= '0;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end

                DATA: begin
                    tx <= data_reg[bit_cnt];
                    if (baud_cnt == BAUD_LIMIT - 1) begin
                        baud_cnt <= '0;
                        if (bit_cnt == N-1) begin
                            state <= STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end

                STOP: begin
                    tx <= 1'b1; 
                    if (baud_cnt == BAUD_LIMIT - 1) begin
                        baud_cnt <= '0;
                        state    <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
            endcase
        end
    end

endmodule
