`timescale 1ns / 1ps

module ram #(
    parameter int DSIZE = 8,
    parameter int DIMENSION = 32
) (
    input  logic clk_i,
    input  logic rw,
    input  logic [$clog2(DIMENSION*DIMENSION)-1:0] read_address,
    input  logic [$clog2(DIMENSION*DIMENSION)-1:0] write_address,
    input  logic [DSIZE-1:0] data_i,
    output logic [DSIZE-1:0] data_o
);
    logic [DSIZE-1:0] mem[DIMENSION*DIMENSION];

    always_ff @(posedge clk_i) begin
        if (rw)
            mem[write_address] <= data_i;
        data_o <= mem[read_address];
    end
endmodule

module line_buffer #(
    parameter int DSIZE = 8,
    parameter int DIMENSION = 32
) (
    input  logic clk_i,
    input  logic rw,
    input  logic [$clog2(DIMENSION)-1:0] read_address,
    input  logic [$clog2(DIMENSION)-1:0] write_address,
    input  logic [DSIZE-1:0] data_i,
    output logic [DSIZE-1:0] data_o
);
    logic [DSIZE-1:0] mem[DIMENSION];

    always_ff @(posedge clk_i) begin
        if (rw)
            mem[write_address] <= data_i;
        data_o <= mem[read_address];
    end
endmodule


module image_buffer_fifo #(
    parameter int DSIZE     = 8,
    parameter int DIMENSION = 32
) (
    input  logic                                       clk_i,
    input  logic                                       rst_ni,
    input  logic [$clog2(DIMENSION * DIMENSION) - 1:0] read_address,
    input  logic [                          DSIZE-1:0] data_i,
    input  logic                                       in_valid_i,
    output logic                                       in_ready_o,
    output logic [                          DSIZE-1:0] data_o,
    output logic [$clog2(DIMENSION*DIMENSION)-1:0] write_address_o,
    input  logic                                       convolution_done_i
);
    logic [$clog2(DIMENSION*DIMENSION)-1:0] write_address;
    
    assign in_ready_o = (write_address < DIMENSION * DIMENSION);
    assign write_address_o = write_address;

    logic rw;
    assign rw = in_valid_i && in_ready_o;

    ram #(.DSIZE(DSIZE), .DIMENSION(DIMENSION)) ram_inst (
        .clk_i(clk_i),
        .rw(rw),
        .write_address(write_address),
        .read_address(read_address),
        .data_i(data_i),
        .data_o(data_o)
    );

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            write_address <= '0;
        end else begin
            if (convolution_done_i)
                write_address <= '0;
            else if (rw)
                write_address <= write_address + 1'b1;
        end
    end
endmodule

module convolution_3x3 #(
    parameter int DSIZE = 8,
    parameter int DIMENSION = 32
) (
    input  logic clk_i,
    input  logic rst_ni,
    input  logic start_i,
    input  logic [DSIZE-1:0] data_i,
    input  logic out_ready_i,
    input  logic [$clog2(DIMENSION*DIMENSION)-1:0] center_ptr,
    output logic [$clog2(DIMENSION*DIMENSION)-1:0] read_addr,
    output logic [DSIZE+7:0] acc_o,
    output logic out_valid_o
);
    int KERNEL[9] = '{0, 1, 0, 1, 2, 1, 0, 1, 0};

    shortint offsets[9] = '{ -shortint'(DIMENSION)-1, -shortint'(DIMENSION), -shortint'(DIMENSION)+1, 
                             -1,                      0,                     1, 
                              shortint'(DIMENSION)-1,  shortint'(DIMENSION),  shortint'(DIMENSION)+1 };

    typedef enum logic [1:0] { IDLE, WAIT_DATA, SUM, FINISH } state_t;
    state_t state;

    logic [3:0] idx;
    logic [DSIZE+7:0] acc;

    assign acc_o = acc;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state       <= IDLE;
            out_valid_o <= 1'b0;
            acc         <= '0;
            idx         <= '0;
            read_addr   <= '0;
        end else begin
            case (state)
                IDLE: begin
                    out_valid_o <= 1'b0;
                    if (start_i) begin
                        idx       <= 0;
                        acc       <= 0;
                        read_addr <= center_ptr + offsets[0];
                        state     <= WAIT_DATA;
                    end
                end

                WAIT_DATA: begin
                    state <= SUM;
                    read_addr <= center_ptr + offsets[1];
                end

                SUM: begin
                    acc <= acc + (KERNEL[idx] * data_i);
                    if (idx < 8) begin
                        if(idx < 7) read_addr <= center_ptr + offsets[idx + 2];
                        idx       <= idx + 1;
                    end else begin
                        state     <= FINISH;
                        out_valid_o <= 1'b1;
                    end
                end

                FINISH: begin
                    if (out_ready_i) begin
                        out_valid_o <= 1'b0;
                        state       <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

module convolution #(
    parameter int DSIZE = 8,
    parameter int DIMENSION = 32
) (
    input  logic                                   clk_i,
    input  logic                                   rst_ni,
    input  logic                                   start_convolution,
    input  logic [DSIZE-1:0]                       ram_data_i,
    input  logic                                   out_ready_i,
    output logic [$clog2(DIMENSION*DIMENSION)-1:0] read_addr_o,
    output logic [DSIZE+7:0]                       acc_o,
    output logic                                   out_valid_o,
    output logic                                   convolution_done_o
);
    logic [$clog2(DIMENSION*DIMENSION)-1:0] center_address;
    logic start_block, block_done;
    logic [$clog2(DIMENSION)-1:0] col_cnt, row_cnt;

    typedef enum logic [1:0] { IDLE, RUN_BLOCK, WAIT_BLOCK, DONE } state_t;
    state_t state;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state <= IDLE;
            center_address <= DIMENSION + 1;
            start_block <= 0;
            convolution_done_o <= 0;
            col_cnt <= 0; row_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    convolution_done_o <= 0;
                    if (start_convolution) begin
                        center_address <= DIMENSION + 1;
                        col_cnt <= 0; row_cnt <= 0;
                        start_block <= 1;
                        state <= RUN_BLOCK;
                    end
                end
                RUN_BLOCK: begin
                    start_block <= 0;
                    state <= WAIT_BLOCK;
                end
                WAIT_BLOCK: begin
                    if (block_done && out_ready_i) begin
                        if (col_cnt == DIMENSION - 3) begin
                            if (row_cnt == DIMENSION - 3) state <= DONE;
                            else begin
                                center_address <= center_address + 3;
                                row_cnt <= row_cnt + 1; col_cnt <= 0;
                                start_block <= 1; state <= RUN_BLOCK;
                            end
                        end else begin
                            center_address <= center_address + 1;
                            col_cnt <= col_cnt + 1;
                            start_block <= 1; state <= RUN_BLOCK;
                        end
                    end
                end
                DONE: begin
                    convolution_done_o <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

    convolution_3x3 #(.DSIZE(DSIZE), .DIMENSION(DIMENSION)) block_inst (
        .clk_i(clk_i), .rst_ni(rst_ni), .start_i(start_block),
        .data_i(ram_data_i), .center_ptr(center_address),
        .read_addr(read_addr_o), .acc_o(acc_o), .out_valid_o(block_done), .out_ready_i(out_ready_i)
    );
    assign out_valid_o = block_done;
endmodule

module pfe #(
    parameter int DSIZE = 8,
    parameter int DIMENSION = 32
) (
    input  logic             clk_i,
    input  logic             rst_ni,
    input  logic [DSIZE-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,
    output logic [DSIZE-1:0] out_data_o,
    output logic             out_valid_o,
    input  logic             out_ready_i
);
    logic [DSIZE-1:0] ram_data;
    logic [$clog2(DIMENSION*DIMENSION)-1:0] r_addr, w_addr;
    logic [DSIZE+7:0] full_res;
    logic conv_done, buf_full;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) buf_full <= 0;
        else if (w_addr == (DIMENSION*DIMENSION-1) && in_valid_i && in_ready_o)
            buf_full <= 1;
        else if (conv_done)
            buf_full <= 0;
    end

    image_buffer_fifo #(.DSIZE(DSIZE), .DIMENSION(DIMENSION)) memory (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .data_i(in_data_i),
        .data_o(ram_data),
        .in_valid_i(in_valid_i),
        .in_ready_o(in_ready_o),
        .read_address(r_addr),
        .write_address_o(w_addr),
        .convolution_done_i(conv_done)
    );

    convolution #(.DSIZE(DSIZE), .DIMENSION(DIMENSION)) logika (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .out_ready_i(out_ready_i),
        .start_convolution(buf_full),
        .ram_data_i(ram_data),
        .acc_o(full_res),
        .out_valid_o(out_valid_o),
        .read_addr_o(r_addr),
        .convolution_done_o(conv_done)
    );

    assign out_data_o = full_res[10:3];
endmodule