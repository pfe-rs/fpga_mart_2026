module pfe_soc #(
  parameter int unsigned DSIZE    = 16,
  localparam int NUM_BYTES = 2
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic       in_valid_i,
  output logic       in_ready_o,
  input  logic [7:0] in_data_i,

  output logic       out_valid_o,
  input  logic       out_ready_i,
  output logic [7:0] out_data_o
);

  // -------------------------
  // Internal wires
  // -------------------------
  wire [NUM_BYTES*8-1:0] deser_pfe_data;
  wire                   deser_pfe_valid;
  wire                   deser_pfe_ready;

  wire [DSIZE-1:0]       pfe_in_data;
  wire                   pfe_in_valid;
  wire                   pfe_in_ready;

  wire [DSIZE-1:0]       pfe_out_data;
  wire                   pfe_out_valid;
  wire                   pfe_out_ready;

  wire [NUM_BYTES*8-1:0] ser_in_data;
  wire                   ser_in_valid;
  wire                   ser_in_ready;

  wire [7:0]             ser_out_data;
  wire                   ser_out_valid;
  wire                   ser_out_ready;

  // -------------------------
  // Deserializer → PFE
  // -------------------------
  assign pfe_in_data  = deser_pfe_data;
  assign pfe_in_valid = deser_pfe_valid;
  assign deser_pfe_ready = pfe_in_ready;

  // -------------------------
  // PFE
  // -------------------------
  pfe #(
    .DSIZE(DSIZE)
  ) u_pfe (
    .clk_i       (clk_i),
    .rst_ni      (rst_ni),
    .in_valid_i  (pfe_in_valid),
    .in_ready_o  (pfe_in_ready),
    .in_data_i  (pfe_in_data),
    .out_valid_o (pfe_out_valid),
    .out_ready_i (pfe_out_ready),
    .out_data_o  (pfe_out_data)
  );

  // -------------------------
  // PFE → Serializer
  // -------------------------
  assign ser_in_data  = pfe_out_data;
  assign ser_in_valid = pfe_out_valid;
  assign pfe_out_ready = ser_in_ready;

  // -------------------------
  // Serializer → Output
  // -------------------------
  assign out_data_o  = ser_out_data;
  assign out_valid_o = ser_out_valid;
  assign ser_out_ready = out_ready_i;

  // -------------------------
  // Serializer
  // -------------------------
  byte_serializer #(
    .NUM_BYTES(NUM_BYTES)
  ) u_serializer (
    .clk      (clk_i),
    .rst_n    (rst_ni),
    .in_data  (ser_in_data),
    .in_valid (ser_in_valid),
    .in_ready (ser_in_ready),
    .out_data (ser_out_data),
    .out_valid(ser_out_valid),
    .out_ready(ser_out_ready)
  );

  // -------------------------
  // Deserializer
  // -------------------------
  byte_deserializer #(
    .NUM_BYTES(NUM_BYTES)
  ) u_deserializer (
    .clk      (clk_i),
    .rst_n    (rst_ni),
    .in_data  (in_data_i),
    .in_valid (in_valid_i),
    .in_ready (in_ready_o),          // directly drives top-level ready
    .out_data (deser_pfe_data),
    .out_valid(deser_pfe_valid),
    .out_ready(deser_pfe_ready)
  );

endmodule
