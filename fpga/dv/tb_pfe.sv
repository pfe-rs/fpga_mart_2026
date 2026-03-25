`timescale 1ns/1ps

// =============================================================================
//  tb_pfe.sv — Comprehensive Testbench for pfe.sv (VGA + RGB gradient)
// =============================================================================

module tb_pfe;

    // -------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------
    parameter int Nb        = 10;
    parameter int Nhs       = 7;
    parameter int Nvs       = 2;
    parameter int MAXHB     = 703;
    parameter int MAXHS     = 95;
    parameter int MAXVB     = 522;
    parameter int MAXVS     = 1;
    parameter int BIT_COLOR = 8;

    parameter int H_ACTIVE  = 640;
    parameter int H_SYNC_W  = 96;
    parameter int H_BACK    = 48;
    parameter int H_TOTAL   = 800;

    parameter int V_ACTIVE  = 480;
    parameter int V_SYNC_W  = 2;
    parameter int V_TOTAL   = 525;

    parameter int FRAME_CLKS = H_TOTAL * V_TOTAL;
    parameter int SIM_FRAMES = 3;
    parameter real CLK_PERIOD = 40.0;

    // -------------------------------------------------------------------------
    // Width-correct local constants (silence Verilator WIDTHEXPAND)
    // -------------------------------------------------------------------------
    localparam logic [Nb-1:0]        H_ACTIVE_W  = Nb'(H_ACTIVE);
    localparam logic [Nb-1:0]        V_ACTIVE_W  = Nb'(V_ACTIVE);
    localparam logic [Nb-1:0]        H_ACTIVE_M1 = Nb'(H_ACTIVE - 1);
    localparam logic [Nb-1:0]        V_ACTIVE_M1 = Nb'(V_ACTIVE - 1);
    localparam logic [Nb-1:0]        MAXHB_W     = Nb'(MAXHB);
    localparam logic [Nb-1:0]        MAXVB_W     = Nb'(MAXVB);
    localparam logic [Nhs-1:0]       MAXHS_W     = Nhs'(MAXHS);
    localparam logic [Nvs-1:0]       MAXVS_W     = Nvs'(MAXVS);
    localparam logic [BIT_COLOR-1:0] COLOR_ZERO  = '0;

    // -------------------------------------------------------------------------
    // DUT interface
    // -------------------------------------------------------------------------
    logic clk_i;
    logic [Nb-1:0]        h_countb, v_countb;
    logic [Nhs-1:0]       h_counts;
    logic [Nvs-1:0]       v_counts;
    logic                 h_sync, v_sync, display_active;
    logic [Nb-1:0]        pixel_x, pixel_y;
    logic [BIT_COLOR-1:0] R, G, B;

    // -------------------------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------------------------
    pfe #(
        .Nb       (Nb),       .Nhs      (Nhs),
        .Nvs      (Nvs),      .maxhb    (MAXHB),
        .maxhs    (MAXHS),    .maxvb    (MAXVB),
        .maxvs    (MAXVS),    .bit_color(BIT_COLOR)
    ) dut (
        .clk_i         (clk_i),
        .h_countb      (h_countb),  .h_counts(h_counts),
        .v_countb      (v_countb),  .v_counts(v_counts),
        .h_sync        (h_sync),    .v_sync  (v_sync),
        .display_active(display_active),
        .pixel_x       (pixel_x),   .pixel_y (pixel_y),
        .R(R), .G(G), .B(B)
    );

    // -------------------------------------------------------------------------
    // Clock
    // -------------------------------------------------------------------------
    initial clk_i = 0;
    always #(CLK_PERIOD / 2.0) clk_i = ~clk_i;

    // -------------------------------------------------------------------------
    // Scoreboard
    // -------------------------------------------------------------------------
    int pass_count = 0;
    int fail_count = 0;

    // Delayed copies
    logic                 h_sync_d         = 1;
    logic                 v_sync_d         = 1;
    logic                 display_active_d = 0;
    logic [Nb-1:0]        pixel_x_d        = '0;
    logic [Nb-1:0]        pixel_y_d        = '0;
    logic [BIT_COLOR-1:0] R_d = '0, G_d = '0, B_d = '0;

    // Accumulators
    int active_px_this_line         = 0;
    int active_lines_this_frame     = 0;
    int total_active_px_this_frame  = 0;
    int line_num                    = 0;
    int frame_num                   = 0;

    // Timing measurement
    longint hsync_fall_clk      = 0;
    longint hsync_rise_clk      = 0;
    longint vsync_fall_clk      = 0;
    longint vsync_rise_clk      = 0;
    longint vsync_fall_clk_prev = 0;
    longint vsync_fall_clk_cur  = 0;
    longint hsync_fall_clk_prev = 0;
    longint hsync_fall_clk_cur  = 0;

    // pixel_y tracking
    logic [Nb-1:0] last_line_py      = '1;
    logic          first_active_seen = 0;

    // Back-porch counter
    int   back_porch_cnt = 0;
    logic counting_bp    = 0;

    // Global clock counter
    longint clk_cnt = 0;
    always @(posedge clk_i) clk_cnt++;

    // -------------------------------------------------------------------------
    // Utility tasks
    // -------------------------------------------------------------------------
    task automatic pass_msg(input string msg);
        pass_count++;
`ifdef TB_VERBOSE
        $display("  [PASS]  %s", msg);
`endif
    endtask

    task automatic fail_msg(input string msg);
        fail_count++;
        $display("  [FAIL]  %s", msg);
    endtask

    // =========================================================================
    // Main clocked monitor
    // =========================================================================
    always @(posedge clk_i) begin

        // =====================================================================
        // 1. HSYNC FALLING EDGE
        // =====================================================================
        if (h_sync_d && !h_sync) begin
            line_num++;
            hsync_fall_clk = clk_cnt;

            // Only fail if we got a non-zero, wrong count (0 = blanking line, correct)
            if (line_num > 1 && active_px_this_line !== 0 &&
                active_px_this_line !== H_ACTIVE)
                fail_msg($sformatf("Line %0d: active pixels=%0d (exp %0d or 0 for blanking)",
                                   line_num-1, active_px_this_line, H_ACTIVE));
            active_px_this_line = 0;

            if (display_active)
                fail_msg($sformatf("Line %0d: display_active HIGH at hsync fall", line_num));
        end

        // =====================================================================
        // 2. HSYNC RISING EDGE — pulse width
        // =====================================================================
        if (!h_sync_d && h_sync) begin
            hsync_rise_clk = clk_cnt;
            begin : hsync_pw
                longint pw;
                pw = hsync_rise_clk - hsync_fall_clk;
                if (pw !== longint'(H_SYNC_W))
                    fail_msg($sformatf("HSYNC pulse width=%0d clocks (exp %0d)", pw, H_SYNC_W));
                else
                    pass_msg($sformatf("HSYNC pulse width=%0d clocks correct", pw));
            end
            if (display_active)
                fail_msg("display_active HIGH immediately after hsync rise");
        end

        // =====================================================================
        // 3. VSYNC FALLING EDGE
        // =====================================================================
        if (v_sync_d && !v_sync) begin
            frame_num++;
            vsync_fall_clk = clk_cnt;
            $display("\n[INFO]  === VSYNC fall — frame %0d at t=%0t ===", frame_num, $time);

            if (frame_num > 1) begin
                if (active_lines_this_frame !== V_ACTIVE)
                    fail_msg($sformatf("Frame %0d: active lines=%0d (exp %0d)",
                                       frame_num-1, active_lines_this_frame, V_ACTIVE));
                else
                    pass_msg($sformatf("Frame %0d: %0d active lines correct",
                                       frame_num-1, active_lines_this_frame));

                if (total_active_px_this_frame !== H_ACTIVE * V_ACTIVE)
                    fail_msg($sformatf("Frame %0d: total active px=%0d (exp %0d)",
                                       frame_num-1, total_active_px_this_frame,
                                       H_ACTIVE * V_ACTIVE));
                else
                    pass_msg($sformatf("Frame %0d: total active pixels correct", frame_num-1));
            end
            active_lines_this_frame    = 0;
            total_active_px_this_frame = 0;

            if (display_active)
                fail_msg("display_active HIGH at vsync fall");
        end

        // =====================================================================
        // 4. VSYNC RISING EDGE — pulse width
        // =====================================================================
        if (!v_sync_d && v_sync) begin
            vsync_rise_clk = clk_cnt;
            begin : vsync_pw
                longint pw_clks, pw_lines;
                pw_clks  = vsync_rise_clk - vsync_fall_clk;
                pw_lines = pw_clks / longint'(H_TOTAL);
                if (pw_lines !== longint'(V_SYNC_W))
                    fail_msg($sformatf("VSYNC pulse width=%0d lines (exp %0d)",
                                       pw_lines, V_SYNC_W));
                else
                    pass_msg($sformatf("VSYNC pulse width=%0d lines correct", pw_lines));
            end
            if (display_active)
                fail_msg("display_active HIGH immediately after vsync rise");
        end

        // =====================================================================
        // 5. VSYNC PERIOD
        // =====================================================================
        if (v_sync_d && !v_sync) begin
            vsync_fall_clk_cur = clk_cnt;
            if (vsync_fall_clk_prev !== 0) begin : vsync_period
                longint period;
                period = vsync_fall_clk_cur - vsync_fall_clk_prev;
                if (period !== longint'(FRAME_CLKS))
                    fail_msg($sformatf("Frame period=%0d clocks (exp %0d)",
                                       period, FRAME_CLKS));
                else
                    pass_msg($sformatf("Frame period=%0d clocks correct", period));
            end
            vsync_fall_clk_prev = vsync_fall_clk_cur;
        end

        // =====================================================================
        // 6. HSYNC PERIOD
        // =====================================================================
        if (h_sync_d && !h_sync) begin
            hsync_fall_clk_cur = clk_cnt;
            if (hsync_fall_clk_prev !== 0) begin : hsync_period
                longint period;
                period = hsync_fall_clk_cur - hsync_fall_clk_prev;
                if (period !== longint'(H_TOTAL))
                    fail_msg($sformatf("HSYNC period=%0d clocks (exp %0d) at line %0d",
                                       period, H_TOTAL, line_num));
            end
            hsync_fall_clk_prev = hsync_fall_clk_cur;
        end

        // =====================================================================
        // 7. EVERY-CYCLE — timing / pixel / counter checks
        // =====================================================================

        // 7a. display_active never overlaps sync lows
        if (display_active && !h_sync)
            fail_msg($sformatf("display_active HIGH during h_sync LOW at t=%0t", $time));
        if (display_active && !v_sync)
            fail_msg($sformatf("display_active HIGH during v_sync LOW at t=%0t", $time));

        // 7b. pixel_x/y = 0 when inactive
        if (!display_active && pixel_x !== '0)
            fail_msg($sformatf("pixel_x=%0d (exp 0) while inactive at t=%0t",
                               pixel_x, $time));
        if (!display_active && pixel_y !== '0)
            fail_msg($sformatf("pixel_y=%0d (exp 0) while inactive at t=%0t",
                               pixel_y, $time));

        // 7c. pixel_x/y in range while active
        if (display_active) begin
            if (pixel_x >= H_ACTIVE_W)
                fail_msg($sformatf("pixel_x=%0d out of range at t=%0t", pixel_x, $time));
            if (pixel_y >= V_ACTIVE_W)
                fail_msg($sformatf("pixel_y=%0d out of range at t=%0t", pixel_y, $time));
        end

        // 7d. pixel_x increments by 1; pixel_y holds steady within a line
        if (display_active && display_active_d) begin
            if (pixel_x !== pixel_x_d + Nb'(1))
                fail_msg($sformatf("pixel_x not incrementing: %0d->%0d at t=%0t",
                                   pixel_x_d, pixel_x, $time));
            if (pixel_y !== pixel_y_d)
                fail_msg($sformatf("pixel_y changed mid-line: %0d->%0d at t=%0t",
                                   pixel_y_d, pixel_y, $time));
        end

        // 7e. pixel_x = 0 at start of active region
        if (display_active && !display_active_d) begin
            if (pixel_x !== '0)
                fail_msg($sformatf("pixel_x=%0d at active start (exp 0) at t=%0t",
                                   pixel_x, $time));
            active_lines_this_frame++;
        end

        // 7f. Counter overflow guards
        if ( h_sync && h_countb > MAXHB_W) fail_msg($sformatf("h_countb=%0d > MAXHB", h_countb));
        if (!h_sync && h_counts > MAXHS_W) fail_msg($sformatf("h_counts=%0d > MAXHS", h_counts));
        if ( v_sync && v_countb > MAXVB_W) fail_msg($sformatf("v_countb=%0d > MAXVB", v_countb));
        if (!v_sync && v_counts > MAXVS_W) fail_msg($sformatf("v_counts=%0d > MAXVS", v_counts));

        // 7g. X/Z checks
        if ($isunknown(h_sync))          fail_msg("h_sync is X/Z");
        if ($isunknown(v_sync))          fail_msg("v_sync is X/Z");
        if ($isunknown(display_active))  fail_msg("display_active is X/Z");
        if (display_active) begin
            if ($isunknown(pixel_x)) fail_msg("pixel_x is X/Z while active");
            if ($isunknown(pixel_y)) fail_msg("pixel_y is X/Z while active");
            if ($isunknown(R))       fail_msg("R is X/Z while active");
            if ($isunknown(G))       fail_msg("G is X/Z while active");
            if ($isunknown(B))       fail_msg("B is X/Z while active");
        end

        // 7h. Active pixel accumulator
        if (display_active) begin
            active_px_this_line++;
            total_active_px_this_frame++;
        end

        // =====================================================================
        // 8. RGB CHECKS — every active pixel
        // =====================================================================
        if (display_active) begin

            // 8a. R = pixel_x >> 2  (no overflow, safe scaling)
            begin : r_check
                logic [BIT_COLOR-1:0] exp_R;
                exp_R = BIT_COLOR'(pixel_x >> 2);
                if (R !== exp_R)
                    fail_msg($sformatf("R=%0d (exp %0d) at px(%0d,%0d) t=%0t",
                                       R, exp_R, pixel_x, pixel_y, $time));
            end

            // 8b. G = pixel_y >> 1  (no overflow, safe scaling)
            begin : g_check
                logic [BIT_COLOR-1:0] exp_G;
                exp_G = BIT_COLOR'(pixel_y >> 1);
                if (G !== exp_G)
                    fail_msg($sformatf("G=%0d (exp %0d) at px(%0d,%0d) t=%0t",
                                       G, exp_G, pixel_x, pixel_y, $time));
            end

            // 8c. B = 8'hFF constant
            begin : b_check
                logic [BIT_COLOR-1:0] exp_B;
                exp_B = {BIT_COLOR{1'b1}};
                if (B !== exp_B)
                    fail_msg($sformatf("B=%0d (exp 255) at px(%0d,%0d) t=%0t",
                                       B, pixel_x, pixel_y, $time));
            end

            // 8d. R holds steady for 4 consecutive pixels, then steps by 1
            if (display_active_d && pixel_y == pixel_y_d) begin
                if (pixel_x[1:0] == 2'b00 && pixel_x != '0) begin
                    // Boundary: R must have incremented
                    if (R !== R_d + BIT_COLOR'(1))
                        fail_msg($sformatf(
                            "R should increment at px_x=%0d: %0d->%0d",
                            pixel_x, R_d, R));
                end else begin
                    // Mid-group: R must hold
                    if (R !== R_d)
                        fail_msg($sformatf(
                            "R should hold at px_x=%0d: %0d->%0d",
                            pixel_x, R_d, R));
                end
            end

            // 8e. G constant across an entire line
            if (display_active_d && pixel_y == pixel_y_d) begin
                if (G !== G_d)
                    fail_msg($sformatf("G changed mid-line: %0d->%0d at px(%0d,%0d)",
                                       G_d, G, pixel_x, pixel_y));
            end

            // 8f. G steps by 1 every two lines (on even pixel_y)
            if (!display_active_d && first_active_seen && pixel_y != '0) begin
                logic [BIT_COLOR-1:0] exp_G_line;
                exp_G_line = BIT_COLOR'(pixel_y >> 1);
                if (G !== exp_G_line)
                    fail_msg($sformatf(
                        "G at line start=%0d (exp %0d) for pixel_y=%0d",
                        G, exp_G_line, pixel_y));
            end

        end // display_active RGB checks

        // =====================================================================
        // 9. RGB must be 0 when display_active is LOW
        // =====================================================================
        if (!display_active) begin
            if (R !== COLOR_ZERO)
                fail_msg($sformatf("R=%0d (exp 0) while inactive at t=%0t", R, $time));
            if (G !== COLOR_ZERO)
                fail_msg($sformatf("G=%0d (exp 0) while inactive at t=%0t", G, $time));
            if (B !== COLOR_ZERO)
                fail_msg($sformatf("B=%0d (exp 0) while inactive at t=%0t", B, $time));
        end

        // ---- update delayed signals -----------------------------------------
        h_sync_d         <= h_sync;
        v_sync_d         <= v_sync;
        display_active_d <= display_active;
        pixel_x_d        <= pixel_x;
        pixel_y_d        <= pixel_y;
        R_d              <= R;
        G_d              <= G;
        B_d              <= B;

    end // always @(posedge clk_i)

    // =========================================================================
    // pixel_y line-to-line increment check
    // =========================================================================
    always @(posedge clk_i) begin
        if (display_active && !display_active_d) begin
            if (!first_active_seen) begin
                first_active_seen <= 1;
                last_line_py      <= pixel_y;
            end else begin
                if (pixel_y == '0 && last_line_py == V_ACTIVE_M1)
                    pass_msg("pixel_y wrapped 479->0 at frame boundary correctly");
                else if (pixel_y !== last_line_py + Nb'(1))
                    fail_msg($sformatf(
                        "pixel_y not incrementing: prev=%0d now=%0d at t=%0t",
                        last_line_py, pixel_y, $time));
                last_line_py <= pixel_y;
            end
        end
    end

    // =========================================================================
    // pixel_x end-of-line must be H_ACTIVE-1
    // =========================================================================
    always @(posedge clk_i) begin
        if (!display_active && display_active_d)
            if (pixel_x_d !== H_ACTIVE_M1)
                fail_msg($sformatf("Last pixel_x=%0d (exp %0d) at t=%0t",
                                   pixel_x_d, H_ACTIVE-1, $time));
    end

    // =========================================================================
    // pixel_y end-of-frame must be V_ACTIVE-1
    // =========================================================================
    always @(posedge clk_i) begin
        if (v_sync_d && !v_sync && first_active_seen) begin
            if (last_line_py !== V_ACTIVE_M1)
                fail_msg($sformatf("Last pixel_y=%0d (exp %0d) at frame end",
                                   last_line_py, V_ACTIVE-1));
            else
                pass_msg($sformatf("Last pixel_y=%0d correct at frame end", last_line_py));
        end
    end

    // =========================================================================
    // Back-porch check: display_active must not rise until H_BACK clocks
    // after hsync rising edge
    // =========================================================================
    always @(posedge clk_i) begin
        if (!h_sync_d && h_sync) begin
            counting_bp    <= 1;
            back_porch_cnt <= 0;
        end else if (counting_bp) begin
            if (display_active && !display_active_d) begin
                if ((back_porch_cnt + 1) !== H_BACK)
                    fail_msg($sformatf("H back porch=%0d clocks (exp %0d)",
                                       back_porch_cnt+1, H_BACK));
                else
                    pass_msg($sformatf("H back porch=%0d clocks correct",
                                       back_porch_cnt+1));
                counting_bp <= 0;
            end else begin
                back_porch_cnt <= back_porch_cnt + 1;
                if (back_porch_cnt >= H_BACK + H_ACTIVE)
                    counting_bp <= 0;
            end
        end
    end

    // =========================================================================
    // Main sequence
    // =========================================================================
    initial begin
        $display("====================================================");
        $display("  tb_pfe — VGA + RGB Gradient Comprehensive TB");
        $display("  Target: 640x480 @ ~60 Hz  |  Frames: %0d", SIM_FRAMES);
        $display("====================================================\n");

        $dumpfile("tb_pfe.vcd");
        $dumpvars(0, tb_pfe);

        repeat (SIM_FRAMES * FRAME_CLKS + 200) @(posedge clk_i);

        $display("\n====================================================");
        $display("  FINAL SUMMARY");
        $display("====================================================");
        $display("  VSYNC pulses  : %0d  (exp %0d) %s",
                 frame_num, SIM_FRAMES,
                 (frame_num == SIM_FRAMES) ? "[PASS]" : "[FAIL]");
        $display("  HSYNC pulses  : %0d  (exp ~%0d) %s",
                 line_num, SIM_FRAMES * V_TOTAL,
                 (line_num >= SIM_FRAMES*V_TOTAL &&
                  line_num <= SIM_FRAMES*V_TOTAL+1) ? "[PASS]" : "[FAIL]");
        $display("  PASS checks   : %0d", pass_count);
        $display("  FAIL checks   : %0d", fail_count);
        $display("  RESULT        : %s",
                 (fail_count == 0) ? "*** ALL PASS ***" : "*** FAILURES DETECTED ***");
        $display("====================================================\n");

        $finish;
    end

endmodule
