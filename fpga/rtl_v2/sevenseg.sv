module sevenseg (
    input  logic [3:0] scoreL,
    input  logic [3:0] scoreR,
    output logic [6:0] HEX0_N,
    output logic [6:0] HEX1_N,
    output logic [6:0] HEX4_N,
    output logic [6:0] HEX5_N
);

    logic [3:0] l_ones, l_tens;
    logic [3:0] r_ones, r_tens;

    always_comb begin
        l_tens = 4'd0;
        l_ones = 4'd0;
        r_tens = 4'd0;
        r_ones = 4'd0;

        if (scoreL >= 10) begin
            l_tens = 4'd1;
            l_ones = scoreL - 10;
        end else begin
            l_tens = 4'd0;
            l_ones = scoreL;
        end

        // if (scoreR >= 10) begin
        //     r_tens = 4'd1;
        //     r_ones = scoreR - 10;
        // end else begin
        //     r_tens = 4'd0;
        //     r_ones = scoreR;
        // end
        case(scoreR)
            4'd0: begin r_tens = 4'd0;r_ones = 4'd0;end
            4'd1: begin r_tens = 4'd0;r_ones = 4'd5;end
            4'd2: begin r_tens = 4'd1;r_ones = 4'd0;end
            4'd3: begin r_tens = 4'd1;r_ones = 4'd5;end
            4'd4: begin r_tens = 4'd2;r_ones = 4'd0;end
            default: begin r_tens = 4'd0;r_ones = 4'd0;end
        endcase
    end

    function automatic logic [6:0] seg7_decode(input logic [3:0] digit);
        begin
            case (digit)
                4'd0: seg7_decode = 7'b1000000;
                4'd1: seg7_decode = 7'b1111001;
                4'd2: seg7_decode = 7'b0100100;
                4'd3: seg7_decode = 7'b0110000;
                4'd4: seg7_decode = 7'b0011001;
                4'd5: seg7_decode = 7'b0010010;
                4'd6: seg7_decode = 7'b0000010;
                4'd7: seg7_decode = 7'b1111000;
                4'd8: seg7_decode = 7'b0000000;
                4'd9: seg7_decode = 7'b0010000;
                default: seg7_decode = 7'b1111111;
            endcase
        end
    endfunction
    

    

    always_comb begin
        HEX0_N = seg7_decode(r_ones);
        HEX1_N = seg7_decode(r_tens);
        HEX4_N = seg7_decode(l_ones);
        HEX5_N = seg7_decode(l_tens);
    end

endmodule


