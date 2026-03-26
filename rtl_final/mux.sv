module mux # (
    parameter int DSIZE = 8
) (
    input logic [DSIZE-1:0] input_option1,
    input logic [DSIZE-1:0] input_option2,
    input logic status, // 0 -> upis iz opcije 1, 1 -> upis iz opcije 2

    output logic [DSIZE-1:0] output_value
);

    genvar i;

    generate
        for (i = 0; i < DSIZE; i++) begin : g_for_i
            assign output_value[i] = (input_option1[i] && ~status) || (input_option2[i] && status);
        end
    endgenerate

endmodule
