
// module single_line_ram #(
//     parameter int DSIZE = 8,
//     parameter int DIMENSION
// ) (
//     input  logic clk_i,
//     input  logic rw,
//     input  logic [$clog2(DIMENSION)-1:0] read_addr,
//     input  logic [$clog2(DIMENSION)-1:0] write_addr,
//     input  logic [DSIZE-1:0] data_i,
//     output logic [DSIZE-1:0] data_o
// );
//     logic [DSIZE-1:0] mem[DIMENSION];

//     always_ff @(posedge clk_i) begin
//         if (rw) mem[write_addr] <= data_i;
//         data_o <= mem[read_addr];
//     end
// endmodule

// module image_buffer #(
//     parameter int DSIZE = 8,
//     parameter int DIMENSION
// ) (
//     input logic clk_i,
//     input logic rst_ni,
//     input logic wr_en,
//     input logic [DSIZE-1:0] data_i,
//     output logic valid_o,
//     output logic [$clog2(DIMENSION)-1:0] read_addr
// );
//     int KERNEL[9] = '{0, 1, 0, 1, 2, 1, 0, 1, 0};

//     typedef enum logic [1:0] {
//     IDLE,
//     FILLING,
//     PROCESS,
//     DONE
//     } state_t;

//     typedef enum logic [1:0] {
//     LINE_0,
//     LINE_1,
//     LINE_2
//     } active_line_t;

//     state_t state = IDLE;
//     active_line_t active_line = LINE_0;
//     logic [$clog2(DIMENSION)-1:0] write_addr = '0;
//     logic [$clog2(DIMENSION)-1:0] read_line_addr  = '0;
//     logic [DSIZE - 1:0] column_value[2];
//     logic [14:0] column_sum = 0;
//     logic [1:0] column_count = 0;

// genvar g_i;
// generate
//     for (g_i = 0; g_i < 2; g_i++) begin : g_line_buffer_gen
//         single_line_ram #(
//             .DSIZE(DSIZE),
//             .DIMENSION(DIMENSION)
//         ) line_inst (
//             .clk_i      (clk_i),
//             .rw         (wr_en && (active_line == g_i)),
//             .write_addr (write_addr),
//             .read_addr  (read_line_addr),
//             .data_i     (data_i),
//             .data_o     (column_value[g_i])
//         );
//     end
// endgenerate

//     integer i;
//     integer j;
//     always_ff @(posedge clk_i or negedge rst_ni) begin
//         if (!rst_ni) begin
//             state <= IDLE;
//             active_line <= LINE_0;
//             write_addr <= '0;
//             read_addr <= '0;
//         end else begin
//             unique case (state)
//                 IDLE: begin
//                     if(wr_en) begin
//                         state <= FILLING;
//                     end
//                 end

//                 FILLING: begin
//                    unique case(active_line)
//                    LINE_0: begin
//                     if (write_addr < DIMENSION) begin
//                         write_addr <= write_addr + 1;
//                     end else begin
//                         write_addr <= '0;
//                         active_line <= LINE_1;
//                     end
//                    end

//                    LINE_1: begin
//                     if (write_addr < DIMENSION) begin
//                         write_addr <= write_addr + 1;
//                     end else begin
//                         write_addr <= '0;
//                         active_line <= LINE_2;
//                     end
//                    end

//                    LINE_2: begin
//                     if (write_addr < DIMENSION) begin
//                         column_sum <= data_i * KERNEL[column_count]
//                         + column_value[0] * KERNEL[column_count + 3]
//                         + column_value[1] * KERNEL[column_count + 6];

//                         write_addr <= write_addr + 1;
//                         column_count <= column_count + 1;
//                     end else begin
//                         write_addr <= '0;
//                         active_line <= LINE_;
//                     end
//                    end
//                    endcase
//                 end
//             endcase
//         end
//     end
// endmodule

// module pfe #(
//     parameter int DSIZE = 8,
//     parameter int DIMENSION = 10
// ) (
//     input  logic             clk_i,
//     input  logic             rst_ni,
//     input  logic [DSIZE-1:0] in_data_i,
//     input  logic             in_valid_i,
//     output logic             in_ready_o,
//     output logic [DSIZE-1:0] out_data_o,
//     output logic             out_valid_o,
//     input  logic             out_ready_i
// );
// endmodule