`timescale 1ns / 1ps

module pfe_tb;

    // ──────────────────────────────────────────────
    // Parameters
    // ──────────────────────────────────────────────
    parameter int DSIZE      = 8;
    parameter int DIMENSION  = 32; // Promenjeno na 32
    parameter int CLK_PERIOD = 10; // ns

    // Dinamički nizovi za podatke
    logic [DSIZE-1:0] input_data [];
    logic [DSIZE-1:0] expected_data [];

    // Kernel definisan u RTL-u: {0, 1, 0, 1, 2, 1, 0, 1, 0}
    int KERNEL[9] = '{0, 1, 0, 1, 2, 1, 0, 1, 0};

    // ──────────────────────────────────────────────
    // Automatsko generisanje matrica (32x32)
    // ──────────────────────────────────────────────
    initial begin
        // Rezerviši prostor: 32*32 = 1024 ulaza, 30*30 = 900 izlaza
        input_data    = new[DIMENSION * DIMENSION];
        expected_data = new[(DIMENSION-2) * (DIMENSION-2)];

        // 1. Generisanje ulazne slike (Ivice 0x01, unutrašnjost 0x05)
        for (int r = 0; r < DIMENSION; r++) begin
            for (int c = 0; c < DIMENSION; c++) begin
                if (r == 0 || r == DIMENSION-1 || c == 0 || c == DIMENSION-1)
                    input_data[r*DIMENSION + c] = 8'h01;
                else
                    input_data[r*DIMENSION + c] = 8'h10;
            end
        end

        // 2. Izračunavanje očekivanog rezultata (Golden Model)
        begin
            int k = 0;
            for (int r = 1; r < DIMENSION-1; r++) begin
                for (int c = 1; c < DIMENSION-1; c++) begin
                    longint acc = 0; // Koristimo longint da ne prelije pre saturacije
                    
                    acc = (input_data[(r-1)*DIMENSION + (c-1)] * KERNEL[0]) +
                          (input_data[(r-1)*DIMENSION + (c  )] * KERNEL[1]) +
                          (input_data[(r-1)*DIMENSION + (c+1)] * KERNEL[2]) +
                          (input_data[(r  )*DIMENSION + (c-1)] * KERNEL[3]) +
                          (input_data[(r  )*DIMENSION + (c  )] * KERNEL[4]) +
                          (input_data[(r  )*DIMENSION + (c+1)] * KERNEL[5]) +
                          (input_data[(r+1)*DIMENSION + (c-1)] * KERNEL[6]) +
                          (input_data[(r+1)*DIMENSION + (c  )] * KERNEL[7]) +
                          (input_data[(r+1)*DIMENSION + (c+1)] * KERNEL[8]);
                    
                    expected_data[k] = acc[10:3];
                    
                    k++;
                end
            end
        end
    end

    // ──────────────────────────────────────────────
    // DUT signals & Instantiation
    // ──────────────────────────────────────────────
    logic             clk;
    logic             rst_n;
    logic [DSIZE-1:0] in_data;
    logic             in_valid;
    logic             in_ready;
    logic [DSIZE-1:0] out_data;
    logic             out_valid;
    logic             out_ready;

    pfe #(
        .DSIZE(DSIZE),
        .DIMENSION(DIMENSION)
    ) dut (
        .clk_i       (clk),
        .rst_ni      (rst_n),
        .in_data_i   (in_data),
        .in_valid_i  (in_valid),
        .in_ready_o  (in_ready),
        .out_data_o  (out_data),
        .out_valid_o (out_valid),
        .out_ready_i (out_ready)
    );

    // ──────────────────────────────────────────────
    // Clock & Reset
    // ──────────────────────────────────────────────
    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    task automatic do_reset();
        rst_n     <= 1'b0;
        in_data   <= '0;
        in_valid  <= 1'b0;
        out_ready <= 1'b0;
        repeat (10) @(posedge clk);
        rst_n <= 1'b1;
        @(posedge clk);
    endtask

    // ──────────────────────────────────────────────
    // Sender process
    // ──────────────────────────────────────────────
    task automatic sender();
        $display("[SENDER] Starting - sending %0d pixels", input_data.size());
        for (int i = 0; i < input_data.size(); i++) begin
            in_data  <= input_data[i];
            in_valid <= 1'b1;
            do begin
                @(posedge clk);
            end while (!in_ready);
        end
        in_valid <= 1'b0;
        $display("[SENDER] All pixels sent.");
    endtask

    // ──────────────────────────────────────────────
    // Receiver process
    // ──────────────────────────────────────────────
    int recv_count  = 0;
    int error_count = 0;

    task automatic receiver();
    $display("[RECEIVER] Waiting for %0d output pixels", expected_data.size());
    out_ready <= 1'b1;
    for (int i = 0; i < expected_data.size(); i++) begin
        do begin
            @(posedge clk);
        end while (!out_valid);

        // Ispis svakog izlaza i očekivane vrednosti
        $display("[RECEIVER] Pixel %0d: Got 0x%h, Expected 0x%h", i, out_data, expected_data[i]);

        if (out_data !== expected_data[i]) begin
            $error("[ERROR] Pixel %0d mismatch!", i);
            error_count++;
        end
        recv_count++;
    end
    out_ready <= 1'b0;
endtask

    // ──────────────────────────────────────────────
    // Main Simulation
    // ──────────────────────────────────────────────
    initial begin
        $display("========================================");
        $display(" PFE 32x32 Testbench Start");
        $display("========================================");

        do_reset();

        fork
            sender();
            receiver();
        join

        repeat (20) @(posedge clk);
        $display("========================================");
        $display(" Received: %0d / %0d", recv_count, expected_data.size());
        if (error_count == 0 && recv_count == expected_data.size())
            $display(" STATUS: TEST PASSED");
        else
            $display(" STATUS: TEST FAILED (%0d errors)", error_count);
        $display("========================================");
        $finish;
    end

    // Timeout (povećan za 32x32)
    initial begin
        #(CLK_PERIOD * 50000);
        $error("TIMEOUT - Sim took too long!");
        $finish;
    end

endmodule