        // pfe.v
        //
        // Processing module with parametrizable word width.
        // NUM_BYTES sets the data width: 1 = 8-bit, 2 = 16-bit, 4 = 32-bit, etc.
        //
        // Currently passes data through unchanged.
        // Modify the always block to add your processing.

        module axis_stream_receive(
            input logic clk,
            input logic rst_n,
            input logic [7:0] s_axis_tdata,
            input logic s_axis_tvalid,
            output logic s_axis_tready,
            output logic [7:0] out
        ); 
            assign s_axis_tready = 1'b1;
            always_ff @(posedge clk or negedge rst_n) begin
                if (~rst_n)
                    out<= 8'h00;
                else if (s_axis_tready && s_axis_tvalid)
                    out <= s_axis_tdata;
            end

        endmodule



        module dekoder(
            input [3:0] input_i,
            output logic [6:0] o
        );
        always_comb begin
            case (input_i)
                4'h0: o = 7'b1000000;
                4'h1: o = 7'b1111001;
                4'h2: o = 7'b0100100;
                4'h3: o = 7'b0110000;
                4'h4: o = 7'b0011001;
                4'h5: o = 7'b0010010;
                4'h6: o = 7'b0000010;
                4'h7: o = 7'b1111000;
                4'h8: o = 7'b0000000;
                4'h9: o = 7'b0010000;
                4'hA: o = 7'b0001000;
                4'hB: o = 7'b0000011;
                4'hC: o = 7'b1000110;
                4'hD: o = 7'b0100001;
                4'hE: o = 7'b0000110;
                4'hF: o = 7'b0001110;
                default: o = 7'b1111111;
            endcase
        end
        endmodule
module bin2bcd(
    input  logic [7:0] bin_i,
    output logic [19:0] shift
);
    integer i;

    always_comb begin
        shift = 20'd0;
        shift[7:0] = bin_i;

        for (i = 0; i < 8; i = i + 1) begin
            if (shift[11:8] >= 5)
                shift[11:8] = shift[11:8] + 4'd3;
            if (shift[15:12] >= 5)
                shift[15:12] = shift[15:12] + 4'd3;
            if (shift[19:16] >= 5)
                shift[19:16] = shift[19:16] + 4'd3;

            shift = shift << 1;
        end
    end
endmodule

        module pfe #(
            parameter int NUM_BYTES=1
        )(
            input  logic                      clk_i,
            input  logic                      rst_ni,

            // Input word (from deserializer)
            input  logic [7:0]    in_data_i,
            input  logic                      in_valid_i,
            output logic                      in_ready_o,

            // Output word (to serializer)
            output logic  [7:0]   out_data_o,
            output logic                       out_valid_o,
            input  logic                       out_ready_i,
            output logic [20:0]                sedam_seg_o,
            input logic                        sw0_i
        );
            
        //  assign out_data  = in_data;
            assign out_valid_o = in_valid_i;
        //  assign in_ready_o  = out_ready_i;
            logic [7:0] data_register;
            
            axis_stream_receive ulaz(
                .clk(clk_i),
                .rst_n(rst_ni),
                .s_axis_tdata(in_data_i),
                .s_axis_tvalid(in_valid_i),
                .s_axis_tready(in_ready_o),
                .out(data_register)
            );
        
            assign out_data_o = data_register;
            logic [3:0] gornji_nibl, donji_nibl, srednji_nibl;
            logic [19:0] bcd_data;
            bin2bcd bcd1(
                .bin_i(data_register),
                .shift(bcd_data)
            );
            logic [6:0] seg_donji, seg_gornji, seg_srednji, seg_gornji_dec;
            always_comb begin
                if (sw0_i) begin
                    // BCD mod
                    donji_nibl   = bcd_data[11:8];
                    srednji_nibl = bcd_data[15:12];
                    gornji_nibl  = bcd_data[19:16];
                end
                else begin
                    // HEX mod
                    donji_nibl   = data_register[3:0];
                    srednji_nibl = data_register[7:4];
                    gornji_nibl  = 4'h0; 
                
                end
            end
            dekoder d1(
                .input_i(gornji_nibl),
                .o(seg_gornji_dec)
            );
            dekoder d3(
                .input_i(donji_nibl),
                .o(seg_donji)
            );
            dekoder d2(
                .input_i(srednji_nibl),
                .o(seg_srednji)
            );
           // assign sedam_seg_o[6:0]   = 7'b1111001; // 1
            //assign sedam_seg_o[13:7]  = 7'b0100100; // 2
//            assign sedam_seg_o[20:14] = 7'b0110000; // 3
            assign seg_gornji = (sw0_i) ? seg_gornji_dec : 7'b1111111;
            assign sedam_seg_o = {seg_gornji, seg_srednji, seg_donji};

        endmodule
