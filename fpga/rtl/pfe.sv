module pfe #(
    parameter int DSIZE = 8,
    parameter int COEFF_W = 8
)(
    input  logic               clk_i,
    input  logic               rst_ni,
    input  logic signed [DSIZE-1:0] in_data_i,
    input  logic                    in_valid_i,
    output logic                    in_ready_o,
    output logic signed [15:0]      out_data_o, 
    output logic                    out_valid_o,
    input  logic                    out_ready_i
);

    localparam signed [COEFF_W-1:0] COEFF = 8'sd32;
    logic signed [DSIZE-1:0] x [0:2];

    // --- FUNKCIJE ---
    
    // Množač vraća 16 bita
    function automatic logic signed [15:0] signed_multiply(
        input logic signed [7:0] a, 
        input logic signed [7:0] b
    );
        logic [15:0] p;
        logic signed [15:0] ext_a;
        p = 16'b0;
        ext_a = 16'(a);
        for (int i = 0; i < 7; i++) begin
            if (b[i]) p = p + (ext_a << i);
        end
        if (b[7]) p = p - (ext_a << 7);
        signed_multiply = p;
    endfunction

    // Sabirač mora biti 16-bitni da bi prihvatio rezultate množenja
    function automatic logic signed [15:0] signed_adder_16b (
        input logic signed [15:0] a,
        input logic signed [15:0] b
    );
        logic [16:0] carry;
        logic [15:0] sum;
        carry[0] = 1'b0;
        for (int i = 0; i < 16; i++) begin
            sum[i]   = a[i] ^ b[i] ^ carry[i];
            carry[i+1] = (a[i] & b[i]) | (carry[i] & (a[i] ^ b[i]));
        end
        signed_adder_16b = sum; // Za potrebe filtera, ovde ignorišemo overflow jer je izlaz 16-bitni
    endfunction

    // --- LOGIKA ---

    assign in_ready_o = out_ready_i;

    // Pomoćne varijable za rezultate množenja
    logic signed [15:0] prod [0:3];
    logic signed [15:0] prod0, prod1, prod2, prod3;
    logic signed [15:0] sum1, sum2, final_sum;
    // 1. Množenje
    always_comb begin
        prod0 = signed_multiply(in_data_i, COEFF);
        prod1 = signed_multiply(x[0],      COEFF);
        prod2 = signed_multiply(x[1],      COEFF);
        prod3 = signed_multiply(x[2],      COEFF);

        // 2. Kaskadno sabiranje koristeći tvoju ripple-carry logiku
        sum1 = signed_adder_16b(prod0, prod1);
        sum2 = signed_adder_16b(prod2, prod3);
        final_sum = signed_adder_16b(sum1, sum2);
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            x[0] <= 0;
            x[1] <= 0;
            x[2] <= 0;
            out_valid_o <= 1'b0;
            out_data_o  <= '0;
        end else if (in_valid_i && out_ready_i) begin
            // Delay line
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
