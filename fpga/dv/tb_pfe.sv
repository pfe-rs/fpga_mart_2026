`timescale 1ns/1ps

module tb_pfe;

  localparam int DSIZE = 8;
  localparam int OSIZE = 16;
  localparam int NUM_SAMPLES = 10; // Tvoj sample_rate u Pythonu

  logic clk_i, rst_ni;
  logic signed [DSIZE-1:0] in_data_i;
  logic in_valid_i, in_ready_o;
  logic signed [OSIZE-1:0] out_data_o;
  logic out_valid_o, out_ready_i;

  // Nizovi za smeštanje testnih podataka
  logic [DSIZE-1:0] stimulus [0:NUM_SAMPLES-1];
  logic [OSIZE-1:0] golden_ref [0:NUM_SAMPLES-1];

  // Instanca filtera
  pfe #(.DSIZE(DSIZE)) dut (.*);

  // Clock
  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
  end

  // Glavna test sekvenc
  initial begin
    // 1. Učitaj fajlove
    $readmemh("input_samples.hex", stimulus);
    $readmemh("expected_results.hex", golden_ref);

    // 2. Reset (Koristi = u initial bloku)
    rst_ni = 0;
    in_valid_i = 0;
    in_data_i = 0;
    out_ready_i = 1;
    #20 rst_ni = 1;

    // 3. Slanje podataka i provera
    for (int i = 0; i < NUM_SAMPLES; i++) begin
      @(posedge clk_i);
      // Čekaj dok DUT ne kaže da je spreman
      while (!in_ready_o) @(posedge clk_i); 
      
      // Koristi blocking assignment (=) ovde
      in_valid_i = 1;
      in_data_i  = stimulus[i];
      
      // Mala zadrška da RTL stigne da izračuna (ako je kombinaciono)
      // ili proveri na sledećem posedge clk_i ako imaš registre
      #1; 
      if (out_valid_o) begin
        if (out_data_o !== $signed(golden_ref[i])) begin
          $display("[%0t] ERROR: Sample %0d | Got: %d, Expected: %d", 
                   $time, i, out_data_o, $signed(golden_ref[i]));
        end
        
        $display("[%0t] PASS: Sample %0d | Output: %d", $time, i, out_data_o);

     
        
      end
    end
    
    @(posedge clk_i);
    in_valid_i = 0;
    #100;
    $display("Test završen.");
    $finish;
  end


endmodule
