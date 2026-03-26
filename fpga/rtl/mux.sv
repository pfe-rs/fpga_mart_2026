`timescale 1ns/1ps

module mux #(
    parameter int N = 8
    ) (
    input signed [N-1:0] sinus,  // N-bitni ulazni signal "a"
    input signed [N-1:0] pravougaonik,  // N-bitni ulazni signal "b"
    input signed [N-1:0] testera,
    input signed [N-1:0] trougao,
    input [1:0] sel,        // Kontrolni signal "sel"
    output signed [N-1:0] izlaz  // N-bitni izlazni signal "y"
);

    assign izlaz = sel[0] ? (sel[1] ? sinus : pravougaonik) : (sel[1] ? testera : trougao);
endmodule
