module pfe #(
    parameter DSIZE = 8
) (
    input  logic             clk_i,
    input  logic             rst_ni,

    // Interface ka JTAG UART-u
    input  logic [DSIZE-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,

    output logic [DSIZE-1:0] out_data_o,
    output logic             out_valid_o,
    input  logic             out_ready_i,

    // Izlazi za 7-segmentne displeje
    output logic [6:0]       HEX0_N, // Kredit (jedinice)
    output logic [6:0]       HEX1_N, // Kredit (desetice - opciono)
    output logic [6:0]       HEX4_N, // Bananice (jedinice)
    output logic [6:0]       HEX5_N  // Bananice (desetice)
);

    // --- Registri ---
    logic [3:0] kredit_reg;    // Koliko je novca trenutno u mašini (0-15)
    logic [7:0] prodato_reg;   // Ukupan broj prodatih bananica (0-255)
    
    // --- Interna logika ---
    logic [4:0] suma;          // 5 bita da sprečimo overflow (max 15 + 7)
    assign suma = in_data_i[3:0] + kredit_reg;
    
    // Spremni smo za ulaz ako je izlazni FIFO spreman da prihvati potvrdu
    assign in_ready_o = out_ready_i;



    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            kredit_reg   <= 4'd0;
            prodato_reg  <= 8'd0;
            out_valid_o  <= 1'b0;
            out_data_o   <= 8'd0;
        end 
        else begin
            // Default stanje: nema nove poruke ka PC-u
            out_valid_o <= 1'b0;

            if (in_valid_i && in_ready_o) begin
                if (suma >= 5) begin
                    // KUPOVINA: Skini 5 dinara, dodaj jednu bananicu
                    kredit_reg  <= suma[3:0] - 4'd5;
                    prodato_reg <= prodato_reg + 1'b1;
                    
                    // Pošalji informaciju nazad (npr. bit 0 označava uspeh)
                    out_data_o  <= { (suma[3:0] - 4'd5), 3'b000, 1'b1 };
                    out_valid_o <= 1'b1;
                end 
                else begin
                    // DOPUNA: Samo dodaj novac u kredit
                    kredit_reg  <= suma[3:0];
                    // Javi PC-u novo stanje kredita
                    out_data_o  <= { suma[3:0], 4'b0000 };
                    out_valid_o <= 1'b1;
                end
            end
        end
    end


    sevenseg displej_inst (
        .scoreL(prodato_reg[3:0]),
        .scoreR(kredit_reg),
        .HEX0_N(HEX0_N),
        .HEX1_N(HEX1_N),
        .HEX4_N(HEX4_N),
        .HEX5_N(HEX5_N)
    );

endmodule
