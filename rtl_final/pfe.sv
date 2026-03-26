
module pfe #(
    parameter int DSIZE =4 *    8,
    parameter Nb = 10,      //broj visokih H
    parameter Nhs = 7,      //broj niskih H
    parameter Nvs = 2,      //V broj - broj HSYNC fall
    parameter maxhb = 703,
    parameter maxhs = 95,
    parameter maxvb = 522,
    parameter maxvs = 1,
    parameter bit_color = 8 //velicina boja
)(

    input logic             clk_i,
    input logic             rst_ni,
    // Input
    input  logic [DSIZE-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,
    // Output
    output logic [DSIZE-1:0] out_data_o,
    output logic             out_valid_o,
    input  logic             out_ready_i,

    output logic h_sync,
    output logic v_sync,

    output logic display_active,

    output logic [bit_color - 1 : 0] R,
    output logic [bit_color - 1 : 0] G,
    output logic [bit_color - 1 : 0] B
);

logic [Nb  - 1 : 0]  h_countb;
logic [Nhs - 1 : 0]  h_counts;
logic [Nb  - 1 : 0]  v_countb;
logic [Nvs - 1 : 0]  v_counts;
logic [Nb - 1 : 0]   pixel_x;
logic [Nb - 1 : 0]   pixel_y;

assign in_ready_o  = out_ready_i;
assign out_valid_o = in_valid_i;
assign out_data_o  = in_data_i;

logic h_sync_prev;

always_ff @(posedge clk_i) begin
    if(!rst_ni) begin
        h_sync_prev <= 1'b1;
    end
    else begin
        h_sync_prev <= h_sync;
    end
end

always_ff @(posedge clk_i) begin //Namestanje H counterova i HSYNC
    if (!rst_ni)begin
        h_countb <= 10'b0;
        h_counts <= 7'b0;
        h_sync <= 1'b1;
    end else begin
        if (h_sync == 1) begin
            if (h_countb < maxhb) begin
                h_countb <= h_countb + 1;
            end
            else begin
                h_countb <= 0;
                h_sync <= 0;
            end
        end

        else begin
            if (h_counts < maxhs) begin
                h_counts <= h_counts + 1;
            end
            else begin
                h_counts <= 0;
                h_sync <= 1;
            end
        end
    end
end

always_ff @(posedge clk_i) begin //Namestanje V counterova i VSYNC
    if(!rst_ni)begin
        v_countb <= '0;
        v_counts <= '0;
        v_sync <= 1'b1;
    end else begin
        if (h_sync_prev == 1 && h_sync == 0) begin //Detekcija HSYNC fall

            if (v_sync == 1) begin

                if (v_countb < maxvb) begin
                    v_countb <= v_countb + 1;
                end

                else begin
                    v_countb <= 0;
                    v_sync <= 0;
                end
            end

            else begin
                if (v_counts < maxvs) begin
                    v_counts <= v_counts + 1;
                end

                else begin
                    v_counts <= 0;
                    v_sync <= 1;
                end
            end
        end
    end
end


assign display_active = (h_countb > 47 && h_countb < 688 && v_countb > 32 && v_countb < 513);
assign pixel_x = display_active ? h_countb - 48 : '0;
assign pixel_y = display_active ? v_countb - 33 : '0;


//Crveni pravougaonik
//always @(posedge clk_i) begin
//    if(10'(pixel_x) < 360 && 10'(pixel_x) > 240 && 10'(pixel_y) < 300 && 10'(pixel_y) > 180) begin
//        R <= 255;
//        B <= 0;
//        G <= 0;
//    end else begin
//        R <= 0;
//        G <= 153;
//        B <= 153;
//    end
//end

//Crveni H gradijent i zeleni V gradijent
//assign R = display_active ? pixel_x[9:2] : '0;  // 0–639 → 0–159
//assign G = display_active ? pixel_y[9:2] >> 2 : '0;  // 0–479 → 0–239
//assign B = display_active ? 0        : '0;  // constant blue plane

//Smile
//Eye Parameters 
localparam [9:0] EYE_Y      = 185;
localparam [9:0] EYE_L_X    = 260;
localparam [9:0] EYE_R_X    = 380;
localparam [9:0] EYE_R      = 15;
localparam [19:0] EYE_R_SQ  = EYE_R * EYE_R;

// --- Mouth Parameters ---
localparam [9:0] MOUTH_X      = 320;
localparam [9:0] MOUTH_Y      = 240; // Pivot point for the arc
localparam [9:0] MOUTH_OUT_R  = 80;
localparam [9:0] MOUTH_INN_R  = 70; 
localparam [19:0] MOUTH_OUT_SQ = MOUTH_OUT_R * MOUTH_OUT_R;
localparam [19:0] MOUTH_INN_SQ = MOUTH_INN_R * MOUTH_INN_R;
// --- Distance Calculations (Signed for precision) ---
logic signed [10:0] dx_l, dx_r, dx_m, dy_e, dy_m;
assign dx_l = pixel_x - EYE_L_X;
assign dx_r = pixel_x - EYE_R_X;
assign dx_m = pixel_x - MOUTH_X;
assign dy_e = pixel_y - EYE_Y;
assign dy_m = pixel_y - MOUTH_Y;
// Squared distances
logic [21:0] dist_l_sq, dist_r_sq, dist_m_sq;
assign dist_l_sq = (dx_l * dx_l) + (dy_e * dy_e);
assign dist_r_sq = (dx_r * dx_r) + (dy_e * dy_e);
assign dist_m_sq = (dx_m * dx_m) + (dy_m * dy_m);

always_comb begin
    // PFEboja background
    R = 0;
    G = 153;
    B = 153;
    // 1. Draw Left Eye
    if (dist_l_sq <= EYE_R_SQ) begin
        R = 0;
        G = 0;
        B = 0;
    end
    // 2. Draw Right Eye
    else if (dist_r_sq <= EYE_R_SQ) begin
        R = 0;
        G = 0;
        B = 0;
    end
    // 3. Draw Mouth (An arc is a ring cut in half)
    else if (dist_m_sq <= MOUTH_OUT_SQ && dist_m_sq >= MOUTH_INN_SQ) begin
        // Only draw the bottom half of the circle to make it a smile
        if (pixel_y > (MOUTH_Y + 10)) begin
            R = 255;
            G = 0;
            B = 0;
        end
    end
end

endmodule
