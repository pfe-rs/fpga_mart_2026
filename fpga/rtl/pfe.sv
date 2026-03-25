
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

    input logic clk_i,
    input  logic             rst_ni,
    // Input
    input  logic [DSIZE-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,
    // Output
    output logic [DSIZE-1:0] out_data_o,
    output logic             out_valid_o,
    input  logic             out_ready_i,
    
    output logic [Nb - 1 : 0] h_countb,
    output logic [Nhs - 1 : 0] h_counts,
    output logic [Nb - 1 : 0] v_countb,
    output logic [Nvs - 1 : 0] v_counts,

    output logic h_sync,
    output logic v_sync,

    output logic display_active,
    output logic [Nb - 1 : 0] pixel_x,
    output logic [Nb - 1 : 0] pixel_y,

    output logic [bit_color - 1 : 0] R,
    output logic [bit_color - 1 : 0] G,
    output logic [bit_color - 1 : 0] B
);

assign in_ready_o  = out_ready_i;
assign out_valid_o = in_valid_i;
assign out_data_o  = in_data_i;

initial h_sync = 1;
initial v_sync = 1;

logic h_sync_prev;

always_ff @(posedge clk_i) begin

    h_sync_prev <= h_sync;
end

always_ff @(posedge clk_i) begin //Namestanje H counterova i HSYNC

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

always_ff @(posedge clk_i) begin //Namestanje V counterova i VSYNC

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

assign display_active = (h_countb > 47 && h_countb < 688 && v_countb > 32 && v_countb < 513);
assign pixel_x = display_active ? h_countb - 48 : '0;
assign pixel_y = display_active ? v_countb - 33 : '0;

//assign R = display_active ? pixel_x[9:2] : '0;  // 0–639 → 0–159
//assign G = display_active ? pixel_y[9:2] >> 2 : '0;  // 0–479 → 0–239
//assign B = display_active ? 0        : '0;  // constant blue plane

assign R = 0;
assign G = 153;
assign B = 153;

endmodule
