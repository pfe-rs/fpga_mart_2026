//evo kod
module pfe_tb;

  localparam bit VERBOSE    = 1;
  localparam int DSIZE      = 24;
  localparam int NUM_INPUTS = 80;

  logic             clk_i, rst_ni;
  logic [DSIZE-1:0] in_data_i;
  logic             in_valid_i, in_ready_o;
  logic [DSIZE-1:0] out_data_o;
  logic             out_valid_o, out_ready_i;
  logic [DSIZE-1:0] sample_q[$];
  logic [9:0]       expected_word_q[$];
  int               sent_count, recv_count;
  pfe #(.DSIZE(DSIZE)) dut (
    .btn(btn),
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .in_data_i  (in_data_i),
    .in_valid_i (in_valid_i),
    .in_ready_o (in_ready_o),
    .out_data_o (out_data_o),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i)
  );
  initial begin
    clk_i = 1'b0;
    forever #5 clk_i = ~clk_i;
  end
  initial begin
    logic signed [7:0] a, b, result;
    logic [8:0] opcode;
    logic zero, overflow;

    rst_ni = 1'b0;
    in_data_i = '0;
    in_valid_i = 1'b0;
    out_ready_i = 1'b1;
    sent_count = 0;
    recv_count = 0;
    for (int i = 0; i < NUM_INPUTS; i++) begin
      opcode = $urandom();
      a = $urandom();
      b = $urandom();
      sample_q.push_back({opcode, a, b, 4'b0});
      case (opcode)
        4'd0: begin 
          result = a + b; zero = (result==0); overflow = (a[7]==b[7]) && (result[7]!=a[7]);end
        4'd1: begin 
          result = a - b; zero = (a==b);overflow=((b - a) > 8'd127 || (b - a) < -8'sd127);end
        4'd2: begin result = (a>b) ? a : b;   zero = (result==0); overflow = 0;end
        4'd3: begin result = (a>b) ? b : a;   zero = (result==0); overflow = 0;end
        4'd4: begin result = (a==b) ? 1 : 0;  zero = (result==0); overflow = 0;end
        4'd5: begin result = a << b;          zero = (result==0); overflow = (result < 0);end
        4'd6: begin result = a >> b;          zero = (result==0); overflow = 0; end
        4'd7: begin result = a & b;           zero = (result==0); overflow = 0; end
        4'd8: begin result = a | b;           zero = (result==0); overflow = 0; end
        4'd9: begin result = a ^ b;           zero = (result==0); overflow = 0; end
        default: begin result = 8'hFF;        zero = 1;           overflow = 0; end
      endcase

      expected_word_q.push_back({result, zero, overflow});

      if (VERBOSE)
        $display("Sample[%0d]: opcode=%0d A=%0d B=%0d -> result=%0d zero=%0d overflow=%0d",
                 i, opcode, a, b, result, zero, overflow);
    end
    repeat (5) @(posedge clk_i);
    rst_ni = 1'b1;
    @(posedge clk_i);
    for (int i = 0; i < NUM_INPUTS; i++) begin
      in_data_i  = sample_q[i];
      in_valid_i = 1'b1;
      if (VERBOSE)
        $display("[%0t] OFFER sample[%0d] = 0x%0h", $time, i, sample_q[i]);
      @(posedge clk_i);
      while (!in_ready_o) @(posedge clk_i);
      sent_count++;
    end
    in_valid_i = 1'b0;
    in_data_i  = '0;
  end
  logic signed [7:0] out_result, expected_result;
  logic out_zero, out_overflow;
  logic expected_zero, expected_overflow;
  logic [9:0] expected_word;

  always @(posedge clk_i) begin
    if (rst_ni && out_valid_o && out_ready_i) begin
      if (expected_word_q.size() == 0) begin
        $error("Unexpected output at word %0d: 0x%0h", recv_count, out_data_o);
        $finish;
      end
  
      out_result   = out_data_o[9:2];
      out_zero     = out_data_o[1];
      out_overflow = out_data_o[0];

      expected_word     = expected_word_q[0];
      expected_result   = expected_word[9:2];
      expected_zero     = expected_word[1];
      expected_overflow = expected_word[0];

      if (VERBOSE)
        $display("[%0t] CHECK word %0d: expected=%0d got=%0d (zero exp=%0d got=%0d, ov exp=%0d got=%0d)",
                 $time, recv_count,
                 expected_result, out_result,
                 expected_zero,   out_zero,
                 expected_overflow, out_overflow);

      if (out_result !== expected_result)
        $error("Result mismatch at word %0d: expected=%0d got=%0d",
               recv_count, expected_result, out_result);
      if (out_zero !== expected_zero)
        $error("Zero flag mismatch at word %0d: expected=%0d got=%0d",
               recv_count, expected_zero, out_zero);
      if (out_overflow !== expected_overflow)
        $error("Overflow flag mismatch at word %0d: expected=%0d got=%0d",
               recv_count, expected_overflow, out_overflow);

      void'(expected_word_q.pop_front());
      recv_count = recv_count + 1;

      if (expected_word_q.size() == 0) begin
        $display("PASS: all %0d output words matched", recv_count);
        $finish;
      end
    end
  end
  initial begin
    #200000;
    $error("Timeout — only %0d/%0d outputs received", recv_count, NUM_INPUTS);
    $finish;
  end

endmodule
