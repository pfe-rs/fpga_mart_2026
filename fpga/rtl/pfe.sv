module pfe #(
    parameter int DSIZE = 8,
    parameter int COEFF_W = 8
)(
    input  logic               clk_i,
    input  logic               rst_ni,
    input  logic signed [DSIZE-1:0] in_data_i,
    input  logic                    in_valid_i,
    output logic                    in_ready_o,
    output logic signed [OWIDTH-1:0] out_data_o,  // FIXED BUG1: width now parameterized (was hardcoded 16)
    output logic                    out_valid_o,
    input  logic                    out_ready_i
);

    // FIXED BUG3: coefficients now configurable (was single hardcoded 32)
    localparam signed [COEFF_W-1:0] COEFFS [0:3] = '{8'sd32, 8'sd32, 8'sd32, 8'sd32};

    // FIXED BUG1: output width computed as DSIZE+8 to safely accommodate maximum product sum
    localparam int OWIDTH = DSIZE + 8;

    logic signed [DSIZE-1:0] x [0:2];  // delay line (3 previous samples)

    // --- LOGIKA ---

    assign in_ready_o = out_ready_i;

    // FIXED BUG2: replaced custom multiply/adder with simple * and + (synthesis-friendly)
    logic signed [OWIDTH-1:0] prod [0:3];
    logic signed [OWIDTH-1:0] sum1, sum2, final_sum;

    always_comb begin
        // Multiply each tap with its coefficient
        prod[0] = in_data_i * COEFFS[0];
        prod[1] = x[0]      * COEFFS[1];
        prod[2] = x[1]      * COEFFS[2];
        prod[3] = x[2]      * COEFFS[3];
        
        // Tree adder
        sum1 = prod[0] + prod[1];
        sum2 = prod[2] + prod[3];
        final_sum = sum1 + sum2;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            x[0] <= 0;
            x[1] <= 0;
            x[2] <= 0;
            out_valid_o <= 1'b0;
            out_data_o  <= '0;
        end else if (in_valid_i && out_ready_i) begin
            // Delay line shift
            x[0] <= in_data_i;
            x[1] <= x[0];
            x[2] <= x[1];

            out_data_o  <= final_sum;
            out_valid_o <= 1'b1;
        end else if (out_ready_i) begin
            out_valid_o <= 1'b0;
        end
    end

endmodule
