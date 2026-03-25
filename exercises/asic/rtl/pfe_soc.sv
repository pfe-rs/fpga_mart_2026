

module pfe_soc #(
  
  parameter int unsigned ASIZE    = 8,
  parameter bit          USE_SRAM = 1'b0
) (
  input  logic             clk_i,
  input  logic             rst_ni,

  input  logic             in_valid_i,
  output logic             in_ready_o,
  input  logic [8 - 1:0] in_data_i,
  
  input logic btn,

  output logic             out_valid_o,
  input  logic             out_ready_i,
  output logic [10 - 1:0] out_data_o
);

    localparam int unsigned DSIZE_IN  = 24;
    localparam int unsigned DSIZE_OUT = 10;

    // ----------------------------------------------------------------
    // Internal wires
    // ----------------------------------------------------------------

    // deserializer → fifo_in
    logic              deser_fifo_valid_w;
    logic              deser_fifo_ready_w;
    logic [DSIZE_IN-1:0] deser_fifo_data_w;

    // fifo_in → alu_core
    logic              fifo_alu_valid_w;
    logic              fifo_alu_ready_w;
    logic [DSIZE_IN-1:0] fifo_alu_data_w;

    // alu_core → fifo_out
    logic              alu_fifo_valid_w;
    logic              alu_fifo_ready_w;
    logic [DSIZE_OUT-1:0] alu_fifo_data_w;
    byte_deserializer #(
        .NUM_BYTES (3)
    ) u_deserializer (
        .clk      (clk_i),
        .rst_n    (rst_ni),
        .in_data  (in_data_i),
        .in_valid (in_valid_i),
        .in_ready (in_ready_o),
        .out_data (deser_fifo_data_w),
        .out_valid(deser_fifo_valid_w),
        .out_ready(deser_fifo_ready_w)
    );

   
    fifo #(
        .DSIZE    (DSIZE_IN),
        .ASIZE    (ASIZE),
        .USE_SRAM (USE_SRAM)
    ) i_fifo_in (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .in_valid_i (deser_fifo_valid_w),
        .in_ready_o (deser_fifo_ready_w),
        .in_data_i  (deser_fifo_data_w),
        .out_valid_o(fifo_alu_valid_w),
        .out_ready_i(fifo_alu_ready_w),
        .out_data_o (fifo_alu_data_w)
    );

    
    pfe #(
        .DSIZE(8)
    ) u_pfe (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .in_valid_i(fifo_alu_valid_w),
        .in_ready_o(fifo_alu_ready_w),
        .in_data_i (fifo_alu_data_w),
        .out_valid_o(alu_fifo_valid_w),
        .out_ready_i(alu_fifo_ready_w),
        .out_data_o (alu_fifo_data_w),
        .btn(btn)
    );

    // ----------------------------------------------------------------
    // 4. Output FIFO: buffers 10-bit results
    // ----------------------------------------------------------------
    fifo #(
        .DSIZE    (DSIZE_OUT),
        .ASIZE    (ASIZE),
        .USE_SRAM (USE_SRAM)
    ) i_fifo_out (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .in_valid_i (alu_fifo_valid_w),
        .in_ready_o (alu_fifo_ready_w),
        .in_data_i  (alu_fifo_data_w),
        .out_valid_o(out_valid_o),
        .out_ready_i(out_ready_i),
        .out_data_o (out_data_o)
    );
  

  // Processing module
  

     

endmodule




// byte_serializer.v
// Takes a (NUM_BYTES*8)-bit word and sends it as bytes on an 8-bit
// streaming output (little-endian, LSB first) with valid/ready handshaking.
//
// Parameters:
//   NUM_BYTES - Number of bytes per input word (minimum 1)
//
// Interfaces:
//   Input:  (NUM_BYTES*8)-bit valid/ready
//   Output: 8-bit valid/ready 
//
// Byte order: bits [7:0] sent first, then [15:8], etc.
// When NUM_BYTES=1, acts as a simple valid/ready register stage.

/*
module byte_serializer #(
    parameter int unsigned NUM_BYTES = 4
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // Input word
    input  logic [NUM_BYTES*8-1:0] in_data,
    input  logic                   in_valid,
    output logic                   in_ready,

    // Output byte stream
    output logic [7:0]             out_data,
    output logic                   out_valid,
    input  logic                   out_ready
);

    localparam int unsigned WIDTH = NUM_BYTES * 8;

    generate
        if (NUM_BYTES == 1) begin : gen_single

            assign in_ready = out_ready;
            assign out_valid = in_valid;
            assign out_data = in_data;

        end else begin : gen_multi
          localparam int unsigned CNT_WIDTH = $clog2(NUM_BYTES);

          logic [WIDTH-1:0]      shreg;
          logic [CNT_WIDTH-1:0]  cnt;
          logic                  active;  // currently serializing

          wire last_byte = active && (cnt == CNT_WIDTH'(NUM_BYTES - 1));

          // Input accepted when idle or finishing last byte
          assign in_ready  = !active || (last_byte && out_ready);
          assign out_valid = active;
          assign out_data  = shreg[7:0];

          always_ff @(posedge clk or negedge rst_n) begin
              if (!rst_n) begin
                  active <= 1'b0;
                  cnt    <= '0;
                  shreg  <= '0;
              end else begin
                  if (!active) begin
                      // Idle — latch new word
                      if (in_valid) begin
                          shreg  <= in_data;
                          cnt    <= '0;
                          active <= 1'b1;
                      end
                  end else if (out_ready) begin
                      if (last_byte) begin
                          // Last byte consumed — try back-to-back load
                          if (in_valid) begin
                              shreg  <= in_data;
                              cnt    <= '0;
                          end else begin
                              active <= 1'b0;
                          end
                      end else begin
                          // Shift right by one byte
                          shreg <= {{8{1'b0}}, shreg[WIDTH-1:8]};
                          cnt   <= cnt + 1'b1;
                      end
                  end
              end
          end
      end
    endgenerate

endmodule
// byte_deserializer.v
// Collects bytes from an 8-bit streaming input (little-endian, LSB first)
// and outputs a (NUM_BYTES*8)-bit word once all bytes have arrived.
//
// Parameters:
//   NUM_BYTES - Number of bytes per output word (minimum 1)
//
// Interfaces:
//   Input:  8-bit valid/ready 
//   Output: (NUM_BYTES*8)-bit valid/ready
//
// Byte order: first byte received = bits [7:0], second = bits [15:8], etc.
// When NUM_BYTES=1, acts as a simple valid/ready register stage.

module byte_deserializer #(
    parameter int unsigned NUM_BYTES = 4
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // Input byte stream
    input  logic [7:0]             in_data,
    input  logic                   in_valid,
    output logic                   in_ready,

    // Output word
    output logic [NUM_BYTES*8-1:0] out_data,
    output logic                   out_valid,
    input  logic                   out_ready
);

    localparam int unsigned WIDTH = NUM_BYTES * 8;

    logic [WIDTH-1:0] shift_reg;
    assign out_data = shift_reg;

    generate
        if (NUM_BYTES == 1) begin : gen_single

            assign in_ready = out_ready;
            assign out_valid = in_valid;
            assign out_data = in_data;

        end else begin : gen_multi
          localparam int unsigned CNT_WIDTH = $clog2(NUM_BYTES);

          logic [CNT_WIDTH-1:0] cnt;
          logic                 full;  // all bytes collected

          wire last_byte = (cnt == CNT_WIDTH'(NUM_BYTES - 1));

          // Accept input when not full, or when full word is being consumed this cycle
          assign in_ready  = !full || out_ready;
          assign out_valid = full;

          always_ff @(posedge clk or negedge rst_n) begin
              if (!rst_n) begin
                  full      <= 1'b0;
                  cnt       <= '0;
                  shift_reg <= '0;
              end else begin
                  if (full && out_ready) begin
                      // Output word consumed
                      full <= 1'b0;
                  end

                  if (in_valid && in_ready) begin
                      // Shift new byte into MSB side, pushing earlier bytes down
                      shift_reg <= {in_data, shift_reg[WIDTH-1:8]};

                      if (last_byte) begin
                          cnt  <= '0;
                          full <= 1'b1;
                      end else begin
                          cnt <= cnt + 1'b1;
                      end
                  end
              end
          end
      end
    endgenerate

endmodule*/
