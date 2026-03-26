module sevenseg (
    input  logic [3:0] scoreL,
    input  logic [3:0] scoreR,
    output logic [6:0] HEX0_N,
    output logic [6:0] HEX4_N
);
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
        HEX0_N = seg7_decode(scoreR);
        HEX4_N = seg7_decode(scoreL);
    end

endmodule


