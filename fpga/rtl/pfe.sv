module pfe #(
    parameter int DSIZE = 8,
    parameter int COEFF_W = 8
)(
    input  logic                clk_i,
    input  logic                rst_ni,
    input  logic signed [DSIZE-1:0] in_data_i,
    input  logic                    in_valid_i,
    output logic                    in_ready_o,
    output logic signed [15:0]      out_data_o, 
    output logic                    out_valid_o,
    input  logic                    out_ready_i
);

    // Unutrašnji registri za koeficijente i liniju kašnjenja (delay line)
    logic signed [COEFF_W-1:0] coeffs_q [0:3];
    logic signed [DSIZE-1:0]   x [0:2];
    
    // Kontrolna logika za učitavanje
    logic [2:0] coeff_cnt; // Brojač do 4
    logic       coeffs_done;

    assign coeffs_done = (coeff_cnt == 3'd4);
    // Spreman je za ulaz ako izlazni stepen to dozvoljava
    assign in_ready_o  = out_ready_i;

    // --- FUNKCIJE (Nepromenjene) ---
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
        return p;
    endfunction

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
        return sum;
    endfunction

    // --- LOGIKA FILTRIRANJA ---
    logic signed [15:0] prod0, prod1, prod2, prod3;
    logic signed [15:0] sum1, sum2, final_sum;

    always_comb begin
        // Množimo ulaz i delay line sa učitanim koeficijentima
        prod0 = signed_multiply(in_data_i, coeffs_q[0]);
        prod1 = signed_multiply(x[0],       coeffs_q[1]);
        prod2 = signed_multiply(x[1],       coeffs_q[2]);
        prod3 = signed_multiply(x[2],       coeffs_q[3]);

        sum1 = signed_adder_16b(prod0, prod1);
        sum2 = signed_adder_16b(prod2, prod3);
        final_sum = signed_adder_16b(sum1, sum2);
    end

    // --- SEKVENCIJALNA LOGIKA ---
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            coeff_cnt   <= '0;
            out_valid_o <= 1'b0;
            out_data_o  <= '0;
            for (int i=0; i<3; i++) x[i] <= '0;
            for (int i=0; i<4; i++) coeffs_q[i] <= '0;
        end 
        else if (in_valid_i && out_ready_i) begin
            if (!coeffs_done) begin
                // FAZA 1: Učitavanje koeficijenata (prva 4 validna podata)
                // Umesto coeffs_q[coeff_cnt], koristiš:
                coeffs_q[coeff_cnt[1:0]] <= in_data_i[COEFF_W-1:0];
                coeff_cnt           <= coeff_cnt + 1;
                out_valid_o         <= 1'b0; // Ne generiši izlaz dok puniš koeficijente
            end 
            else begin
                // FAZA 2: Normalan rad filtra
                x[0] <= in_data_i;
                x[1] <= x[0];
                x[2] <= x[1];

                out_data_o  <= final_sum;
                out_valid_o <= 1'b1;
            end
        end 
        else if (out_ready_i) begin
            out_valid_o <= 1'b0;
        end
    end

endmodule
