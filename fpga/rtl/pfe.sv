module pfe #(
    parameter int DSIZE  = 24
)(
    input logic clk_i,
    input logic rst_ni,
     input logic btn,
    input logic [DSIZE-1:0] in_data_i,
    input  logic in_valid_i,
    output logic in_ready_o,
    output logic [9:0] out_data_o,
    output logic out_valid_o,
    input  logic out_ready_i
);
    assign in_ready_o = out_ready_i;
    assign out_valid_o = in_valid_i;
    logic btn_rising;
    logic btn_pret;
    always_ff @(posedge clk_i or negedge rst_ni)begin
     if(!rst_ni)btn_pret <= 0;
     else btn_pret <= btn;
    end
    assign btn_rising = btn && (!btn_pret);
    logic ans_;
    always_ff @(posedge clk_i or negedge rst_ni)begin
          if(!rst_ni)ans_ <= 0;
          else if(btn_rising) ans_ <= 1;
          else if(in_valid_i)ans_ <= 0;
    end
    logic [7:0]opcode;
    logic signed [7:0]a;
    logic signed [7:0]b;
    logic signed [7:0] rezultat;
    logic signed [7:0] ans;
    logic zero, overflow;
    always_ff @(posedge clk_i or negedge rst_ni)begin
          if(!rst_ni)ans <= 0;
          else if(in_valid_i)ans <= rezultat;
    end
    always_comb begin

     opcode = in_data_i[23:16];
     a = (ans_) ? ans:in_data_i[15:8];
     b = in_data_i[7:0];

    if(opcode == 4'd0)
        begin
             rezultat = a + b;
             zero = rezultat == 0;
             overflow = (a[7] && b[7]);
        end
    else if(opcode == 4'd1)
        begin
             rezultat = a - b;
             zero = (a == b);
             overflow = ((b - a) > 8'd127 || (b - a) < -8'sd127);

        end
    else if(opcode == 4'd2)
        begin
             rezultat = (a > b)?a : b;
             zero = (rezultat == 0);
             overflow = 0;
        end
    else if(opcode == 4'd3)
        begin
             rezultat = (a > b)?b : a;
             zero = (rezultat == 0);
             overflow = 0;
        end
   else if(opcode == 4'd4)
   begin
     rezultat = (a == b);
     zero = rezultat == 0;
     overflow = 0;
   end
    else if(opcode == 4'd5)
    begin
         rezultat = a << b;
         zero = rezultat == 0;
         overflow = (rezultat < 0);
    end
    else if(opcode == 4'd6)
    begin
         rezultat = a >> b;
         zero = rezultat == 0;
         overflow = 0;
    end
    else if(opcode == 4'd7)
    begin
         rezultat = (a & b);
         zero = rezultat == 0;
         overflow = 0;
    end
    else if(opcode == 4'd8)
    begin
         rezultat = (a | b);
         zero = rezultat == 0;
         overflow = 0;
    end
    else if(opcode == 4'd9)
    begin
         rezultat = (a ^ b);
         zero = rezultat == 0;
         overflow = 0;
    end
    else
    begin
            rezultat = -1;
            zero = 1;
            overflow = 0;
    end
    out_data_o = {rezultat, zero, overflow};
    end
endmodule
