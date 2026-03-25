module pfe #(
    parameter int WIDTH = 16
) (
    input  logic             clk_i,
    input  logic             rst_ni,
    // Input
    input  logic             in_valid_i,
    output logic             in_ready_o,
    // Output
    output logic [WIDTH-1:0] out_data_o,
    output logic             out_valid_o,
    input  logic             out_ready_i,

    input  logic [WIDTH-1:0] in_data_i,  //PERIOD
    input  logic [WIDTH-1:0] duty_cycle,  // DUTY CYCLE
    input  logic             but1,
    input  logic             but2,
    input  logic             but3,
    input  logic             but4,
    output logic             pwm_out
);

    assign in_ready_o = out_ready_i;
    assign out_valid_o = in_valid_i;
    assign out_data_o = '0;

    logic [WIDTH-1:0] w_data;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            w_data <= '0;
        else if (in_valid_i && in_ready_o)
            w_data <= in_data_i;
    end

  logic [WIDTH-1:0] w_count;
  logic [WIDTH-1:0] w_duty;

  counter #(
      .WIDTH(WIDTH)
  ) u_cnt (
      .clk_i    (clk_i),
      .period   (w_data), // w_data stavio bio Nikola
      .counter_o(w_count)
  );

  buttons #(
      .WIDTH(WIDTH)
  ) u_btn (
      .clk_i         (clk_i),
      .period        (w_data), // w_data stavio bio Nikola
        .duty_cycle    (duty_cycle),
      .but1          (but1),
      .but2          (but2),
      .but3          (but3),
      .but4          (but4),
      .duty_cycle_out(w_duty)
  );

  pwm #(
      .WIDTH(WIDTH)
  ) u_pwm (
      .clk_i     (clk_i),
      .counter_i (w_count),
      .duty_cycle(w_duty),
      .value     (pwm_out)
  );

endmodule


module counter #(
    parameter int WIDTH = 16
) (
    input logic clk_i,

    input logic [WIDTH-1:0] period,


    output logic [WIDTH-1:0] counter_o
);

    initial counter_o = 0;
  always_ff @(posedge clk_i) begin
    if (counter_o >= period) counter_o <= 0;
    else counter_o <= counter_o + 1;
  end

endmodule

// Modified Buttons Module
module buttons #(
    parameter WIDTH = 16,
    parameter DEBOUNCE_CNT_MAX = 20000  // Adjust as needed for debounce timing
) (
    input  logic             clk_i,
    input  logic [WIDTH-1:0] period,
    input  logic [WIDTH-1:0] duty_cycle,
    input  logic             but1,
    input  logic             but2,
    input  logic             but3,
    input  logic             but4,
    output logic [WIDTH-1:0] duty_cycle_out
);

  logic b1_db, b2_db, b3_db, b4_db;
  logic [31:0] cnt1, cnt2, cnt3, cnt4;

  logic b1_r, b2_r, b3_r, b4_r;

  initial begin
    b1_db = 0; b2_db = 0; b3_db = 0; b4_db = 0;
    b1_r  = 0; b2_r  = 0; b3_r  = 0; b4_r  = 0;
    cnt1 = 0; cnt2 = 0; cnt3 = 0; cnt4 = 0;
    duty_cycle_out = duty_cycle;
  end

  always_ff @(posedge clk_i) begin

    // debounce
    if (but1 == b1_db) cnt1 <= 0;
    else begin
      cnt1 <= cnt1 + 1;
      if (cnt1 >= DEBOUNCE_CNT_MAX) begin
        b1_db <= but1;
        cnt1 <= 0;
      end
    end

    if (but2 == b2_db) cnt2 <= 0;
    else begin
      cnt2 <= cnt2 + 1;
      if (cnt2 >= DEBOUNCE_CNT_MAX) begin
        b2_db <= but2;
        cnt2 <= 0;
      end
    end

    if (but3 == b3_db) cnt3 <= 0;
    else begin
      cnt3 <= cnt3 + 1;
      if (cnt3 >= DEBOUNCE_CNT_MAX) begin
        b3_db <= but3;
        cnt3 <= 0;
      end
    end

    if (but4 == b4_db) cnt4 <= 0;
    else begin
      cnt4 <= cnt4 + 1;
      if (cnt4 >= DEBOUNCE_CNT_MAX) begin
        b4_db <= but4;
        cnt4 <= 0;
      end
    end

    // edge detect
    b1_r <= b1_db;
    b2_r <= b2_db;
    b3_r <= b3_db;
    b4_r <= b4_db;

    if (b1_db && !b1_r)
      duty_cycle_out <= 0;
    else if (b2_db && !b2_r)
      duty_cycle_out <= duty_cycle_out + 1;
    else if (b3_db && !b3_r)
      duty_cycle_out <= duty_cycle_out + (period / 16);
    else if (b4_db && !b4_r)
      duty_cycle_out <= duty_cycle_out + (period / 4);

    if (duty_cycle_out > period)
      duty_cycle_out <= period;

  end

endmodule

// pwm.sv (updated version)
module pwm #(
    parameter WIDTH = 16
) (
    input logic clk_i,
    input logic [WIDTH-1:0] counter_i,
    input logic [WIDTH-1:0] duty_cycle,
    output logic value
);

    always_ff @(posedge clk_i) begin
        // For 0% duty cycle, PWM should always be 0
        if (duty_cycle == 0)
            value <= 0;
        // For 100% duty cycle, PWM should always be 1
        else if (duty_cycle == 16'hFFFF)  // assuming max value for WIDTH = 16
            value <= 1;
        // For other duty cycles, toggle based on counter value
        else if (counter_i <= duty_cycle)
            value <= 1;
        else
            value <= 0;
    end

endmodule
/*
module pfe #(
    parameter int WIDTH = 16
)(
    input  logic             clk_i,
    input  logic             rst_ni,
    // Input
    input  logic [WIDTH-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,
    // Output
    output logic [WIDTH-1:0] counter_o,
    output logic             out_valid_o,
    input  logic             out_ready_i
);



    assign in_ready_o = out_ready_i;
    assign out_valid_o = in_valid_i;
    assign counter_o = in_data_i;

endmodule
*/


/*module pfe #(
    parameter int DSIZE  = 8
)(
    input  logic             clk_i,
    input  logic             rst_ni,
    // Input
    input  logic [DSIZE-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,
    // Output
    output logic [DSIZE-1:0] out_data_o,
    output logic             out_valid_o,
    input  logic             out_ready_i
);

    localparam int NO2ACC = 8;
    localparam int IN_BYTES  = DSIZE / 8;
    localparam int SAFE_M    = (NO2ACC < 1) ? 1 : NO2ACC;
    localparam int ACC_BITS  = DSIZE + $clog2(SAFE_M);
    localparam int ACC_BYTES = (ACC_BITS + 7) / 8;
    localparam int ACC_WIDTH = ACC_BYTES * 8;

    // Optional guard: serializer output is 8-bit, so this module
    // is intended for DSIZE == 8.
    generate
        if (DSIZE != 8) begin : g_bad_dsize
            DSIZE_MUST_BE_8_FOR_THIS_PFE invalid_inst();
        end
    endgenerate

    logic signed [ACC_WIDTH-1:0] acc_data;
    logic                        acc_valid;
    logic                        acc_ready;

    accumulator #(
        .IN_BYTES (IN_BYTES),
        .NO2ACC   (NO2ACC)
    ) u_accumulator (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .in_data_i  (in_data_i),
        .in_valid_i (in_valid_i),
        .in_ready_o (in_ready_o),
        .out_data_o (acc_data),
        .out_valid_o(acc_valid),
        .out_ready_i(acc_ready)
    );

    byte_serializer #(
        .NUM_BYTES (ACC_BYTES)
    ) u_serializer (
        .clk      (clk_i),
        .rst_n    (rst_ni),
        .in_data  (acc_data),
        .in_valid (acc_valid),
        .in_ready (acc_ready),
        .out_data (out_data_o),
        .out_valid(out_valid_o),
        .out_ready(out_ready_i)
    );

endmodule
*/