module fifo #(
  parameter int unsigned DSIZE    = 8,
  parameter int unsigned ASIZE    = 10
) (
  input  logic             clk_i,
  input  logic             rst_ni,

  input  logic             in_valid_i,
  output logic             in_ready_o,
  input  logic [DSIZE-1:0] in_data_i,

  output logic             out_valid_o,
  input  logic             out_ready_i,
  output logic [DSIZE-1:0] out_data_o
);

  localparam int unsigned Depth = (1 << ASIZE);

  logic [ASIZE:0] wr_ptr_q, wr_ptr_d;
  logic [ASIZE:0] rd_ptr_q, rd_ptr_d;
  logic [ASIZE-1:0] wr_addr, rd_addr;
  logic full, empty;
  logic do_write, do_read;

  assign wr_addr = wr_ptr_q[ASIZE-1:0];
  assign rd_addr = rd_ptr_q[ASIZE-1:0];

  // full/empty and in_ready_o are driven inside the generate blocks
  // because the SRAM backend needs different logic.

  // --------------------------------------------------------------------------
  // DFF backend
  // --------------------------------------------------------------------------
  logic [DSIZE-1:0] mem [0:Depth-1];

  // Standard extra-MSB FIFO full/empty detection.
  assign empty = (wr_ptr_q == rd_ptr_q);
  assign full  = (wr_ptr_q[ASIZE] != rd_ptr_q[ASIZE]) &&
                  (wr_ptr_q[ASIZE-1:0] == rd_ptr_q[ASIZE-1:0]);

  // Allow a write when not full, or when a read also happens this cycle.
  assign in_ready_o = ~full | out_ready_i;

  assign out_valid_o = ~empty;
  assign out_data_o  = mem[rd_addr];

  assign do_read  = out_valid_o & out_ready_i;
  assign do_write = in_valid_i & in_ready_o;

  assign wr_ptr_d = do_write ? (wr_ptr_q + 1'b1) : wr_ptr_q;
  assign rd_ptr_d = do_read  ? (rd_ptr_q + 1'b1) : rd_ptr_q;

  always_ff @(posedge clk_i) begin
    if (do_write)
      mem[wr_addr] <= in_data_i;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      wr_ptr_q <= '0;
      rd_ptr_q <= '0;
    end else begin
      wr_ptr_q <= wr_ptr_d;
      rd_ptr_q <= rd_ptr_d;
    end
  end

endmodule