`timescale 1ns/1ps

module tb_pfe;

  localparam int DSIZE = 8;
  localparam int OSIZE = 16;
  localparam int NUM_COEFFS  = 4;
  localparam int NUM_SAMPLES = 10; // Ukupno 14 linija u fajlu: 4 koef + 6 uzoraka

  logic clk_i, rst_ni;
  logic signed [DSIZE-1:0] in_data_i;
  logic in_valid_i, in_ready_o;
  logic signed [OSIZE-1:0] out_data_o;
  logic out_valid_o, out_ready_i;

  // Stimulus sadrži i koeficijente i podatke
  logic signed [DSIZE-1:0] stimulus [0:NUM_COEFFS+NUM_SAMPLES-1];
  
  // DUT Instanca
  pfe #(.DSIZE(DSIZE)) dut (.*);

  // Generisanje takta
  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
  end

  // Glavna test sekvenca
  initial begin
    // 1. Učitaj podatke iz hex fajla
    $readmemh("input_samples.hex", stimulus);

    // 2. Reset sistem
    rst_ni = 0;
    in_valid_i = 0;
    in_data_i = 0;
    out_ready_i = 1;
    #25 rst_ni = 1;
    @(posedge clk_i);

    // 3. SLANJE KOEFICIJENATA (Prva 4 podatka)
    $display("[%0t] --- POCETAK UCITAVANJA KOEFICIJENATA ---", $time);
    for (int i = 0; i < NUM_COEFFS; i++) begin
      in_valid_i = 1;
      in_data_i  = stimulus[i];
      
      do @(posedge clk_i);
      while (!in_ready_o); 
      
      $display("[%0t] Koeficijent %0d poslat: %h", $time, i, stimulus[i]);
    end

    // 4. SLANJE PODATAKA (Signal)
    $display("[%0t] --- POCETAK FILTRIRANJA ---", $time);
    for (int i = NUM_COEFFS; i < NUM_COEFFS + NUM_SAMPLES; i++) begin
      in_valid_i = 1;
      in_data_i  = stimulus[i];

      do @(posedge clk_i);
      while (!in_ready_o);
      
      // Provera izlaza se vrši u svakom ciklusu nakon što coeffs_done postane 1
      if (out_valid_o) begin
        $display("[%0t] Izlaz filtra: %d (hex: %h)", $time, out_data_o, out_data_o);
      end
    end

    in_valid_i = 0;
    
    // Sačekaj još par ciklusa da "iscuri" poslednji validan podatak ako postoji
    repeat(5) @(posedge clk_i);
    
    $display("[%0t] Test završen.", $time);
    $finish;
  end

  // Opcioni monitor za proveru validnosti
  always @(posedge clk_i) begin
    if (out_valid_o && out_ready_i) begin
       $display("  -> VALIDAN IZLAZ detektovan: %d", out_data_o);
    end
  end

endmodule
