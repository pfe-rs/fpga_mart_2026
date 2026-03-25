module fifo #(
  parameter int unsigned DSIZE    = 8,
  parameter int unsigned ASIZE    = 10,
  parameter bit          USE_SRAM = 1'b1,
  parameter int unsigned NUM_SRAMS = 4 // FIX
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

  if (USE_SRAM == 1'b0) begin : gen_dff
    logic [DSIZE-1:0] mem [0:Depth-1];

    assign empty = (wr_ptr_q == rd_ptr_q);
    assign full  = (wr_ptr_q[ASIZE] != rd_ptr_q[ASIZE]) &&
                   (wr_ptr_q[ASIZE-1:0] == rd_ptr_q[ASIZE-1:0]);

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

  end else begin : gen_sram

    localparam int unsigned BANK_BITS = $clog2(NUM_SRAMS); // FIX
    localparam int unsigned SRAM_AW   = ASIZE - BANK_BITS; // FIX

    logic [DSIZE-1:0] sram_b_dout [0:NUM_SRAMS-1]; // FIX
    logic [BANK_BITS-1:0] wr_bank_sel; // FIX
    logic [BANK_BITS-1:0] rd_bank_sel; // FIX

    logic [ASIZE:0] occ_count_q, occ_count_d; // FIX
    logic           occ_full, occ_empty;      // FIX

    logic           out_valid_q, out_valid_d;  // FIX
    logic [DSIZE-1:0] out_data_q, out_data_d;  // FIX

    logic           rd_pending_q, rd_pending_d; // FIX
    logic [BANK_BITS-1:0] rd_bank_q, rd_bank_d;  // FIX

    logic out_taken;      // FIX
    logic out_reg_free;   // FIX
    logic sram_has_data;  // FIX
    logic can_issue_read; // FIX

    assign wr_bank_sel = wr_addr[ASIZE-1:SRAM_AW]; // FIX
    assign rd_bank_sel = rd_addr[ASIZE-1:SRAM_AW]; // FIX

    assign occ_full  = (occ_count_q == Depth); // FIX
    assign occ_empty = (occ_count_q == '0);    // FIX

    assign full  = occ_full;  // FIX
    assign empty = occ_empty; // FIX

    assign in_ready_o = ~occ_full; // FIX

    assign out_taken    = out_valid_q & out_ready_i;        // FIX
    assign out_reg_free = ~out_valid_q | out_taken;         // FIX
    assign sram_has_data = (wr_ptr_q != rd_ptr_q);          // FIX
    assign can_issue_read = sram_has_data & out_reg_free & ~rd_pending_q; // FIX

    assign do_read  = can_issue_read;          // FIX
    assign do_write = in_valid_i & in_ready_o; // FIX

    assign wr_ptr_d = do_write ? (wr_ptr_q + 1'b1) : wr_ptr_q;
    assign rd_ptr_d = do_read  ? (rd_ptr_q + 1'b1) : rd_ptr_q;

    always_comb begin // FIX
      occ_count_d = occ_count_q; // FIX

      case ({do_write, out_taken}) // FIX
        2'b10:   occ_count_d = occ_count_q + 1'b1; // FIX
        2'b01:   occ_count_d = occ_count_q - 1'b1; // FIX
        default:  occ_count_d = occ_count_q;       // FIX
      endcase // FIX
    end // FIX

    genvar bank; // FIX
    for (bank = 0; bank < NUM_SRAMS; bank++) begin : gen_bank // FIX
      RM_IHPSG13_2P_256x8_c2_bm_bist i_sram ( // FIX
        .A_CLK       ( clk_i ), // FIX
        .A_MEN       ( do_write & (wr_bank_sel == bank[BANK_BITS-1:0]) ), // FIX
        .A_WEN       ( do_write & (wr_bank_sel == bank[BANK_BITS-1:0]) ), // FIX
        .A_REN       ( 1'b0 ), // FIX
        .A_ADDR      ( wr_addr[SRAM_AW-1:0] ), // FIX
        .A_DIN       ( in_data_i ), // FIX
        .A_BM        ( {DSIZE{1'b1}} ), // FIX
        .A_DOUT      ( ), // FIX
        .A_DLY       ( 1'b1 ), // FIX

        .A_BIST_EN   ( 1'b0 ), // FIX
        .A_BIST_MEN  ( 1'b0 ), // FIX
        .A_BIST_WEN  ( 1'b0 ), // FIX
        .A_BIST_REN  ( 1'b0 ), // FIX
        .A_BIST_CLK  ( 1'b0 ), // FIX
        .A_BIST_ADDR ( {SRAM_AW{1'b0}} ), // FIX
        .A_BIST_DIN  ( {DSIZE{1'b0}} ), // FIX
        .A_BIST_BM   ( {DSIZE{1'b0}} ), // FIX

        .B_CLK       ( clk_i ), // FIX
        .B_MEN       ( do_read & (rd_bank_sel == bank[BANK_BITS-1:0]) ), // FIX
        .B_WEN       ( 1'b0 ), // FIX
        .B_REN       ( do_read & (rd_bank_sel == bank[BANK_BITS-1:0]) ), // FIX
        .B_ADDR      ( rd_addr[SRAM_AW-1:0] ), // FIX
        .B_DIN       ( {DSIZE{1'b0}} ), // FIX
        .B_BM        ( {DSIZE{1'b0}} ), // FIX
        .B_DOUT      ( sram_b_dout[bank] ), // FIX
        .B_DLY       ( 1'b1 ), // FIX

        .B_BIST_EN   ( 1'b0 ), // FIX
        .B_BIST_MEN  ( 1'b0 ), // FIX
        .B_BIST_WEN  ( 1'b0 ), // FIX
        .B_BIST_REN  ( 1'b0 ), // FIX
        .B_BIST_CLK  ( 1'b0 ), // FIX
        .B_BIST_ADDR ( {SRAM_AW{1'b0}} ), // FIX
        .B_BIST_DIN  ( {DSIZE{1'b0}} ), // FIX
        .B_BIST_BM   ( {DSIZE{1'b0}} ) // FIX
      );
    end // FIX

    assign rd_pending_d = do_read; // FIX

    always_comb begin // FIX
      out_valid_d = out_valid_q; // FIX
      out_data_d  = out_data_q;  // FIX
      rd_bank_d   = rd_bank_q;   // FIX

      if (do_read)
        rd_bank_d = rd_bank_sel; // FIX

      if (rd_pending_q) begin
        out_valid_d = 1'b1; // FIX
        out_data_d  = sram_b_dout[rd_bank_q]; // FIX
      end else if (out_taken) begin
        out_valid_d = 1'b0; // FIX
      end
    end // FIX

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        wr_ptr_q     <= '0;
        rd_ptr_q     <= '0;
        rd_pending_q  <= 1'b0; // FIX
        out_valid_q   <= 1'b0; // FIX
        out_data_q    <= '0;   // FIX
        occ_count_q   <= '0;   // FIX
        rd_bank_q     <= '0;   // FIX
      end else begin
        wr_ptr_q     <= wr_ptr_d;
        rd_ptr_q     <= rd_ptr_d;
        rd_pending_q <= rd_pending_d; // FIX
        out_valid_q  <= out_valid_d;   // FIX
        out_data_q   <= out_data_d;    // FIX
        occ_count_q  <= occ_count_d;   // FIX
        rd_bank_q    <= rd_bank_d;     // FIX
      end
    end

    assign out_valid_o = out_valid_q; // FIX
    assign out_data_o  = out_data_q;  // FIX

  end

endmodule