`timescale 1ns/1ps
module tb_pfe;

    parameter N = 3;
    parameter M = 2;

    logic clk_i, rst_ni;
    logic [15:0] in_data_i;
    logic in_valid_i;
    
    logic in_ready_o;
    logic [15:0] out_data_o;
    logic out_valid_o;
    logic out_ready_i;
     
    logic [15:0] c [0:N-1][0:N-1];
    
    logic [15:0] A[0:N*M-1];

    int row, col;

    
    pfe #(.N(N), .M(M)) dut (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .in_data_i(in_data_i),
        .in_valid_i(in_valid_i),
        .in_ready_o(in_ready_o),
        .out_data_o(out_data_o),
        .out_valid_o(out_valid_o),
        .out_ready_i(out_ready_i),
        .c(c)
    );


    initial clk_i = 0;
    always #5 clk_i = ~clk_i; 
    

    initial begin
        $dumpfile("pfe_tb.vcd");    
        $dumpvars(0, pfe_tb);        
    end

    initial begin
        rst_ni = 0; in_valid_i = 0; out_ready_i = 0; in_data_i = 0;
        #12;
        rst_ni = 1;

        A[0]=257;
        A[1]=257;
        A[2]=270;
        A[3]=270;
        A[4]=270;
        A[5]=257;

        for (int i=0; i<N*M; i++) begin
            @(posedge clk_i);
            in_data_i = A[i];
            in_valid_i = 1;
            wait(in_ready_o);
        end

        

       
        @(posedge clk_i);
        in_valid_i = 0;

  
        out_ready_i = 1;

        for (row=0; row<N; row=row+1) begin
            for (col=0; col<N; col=col+1) begin
                wait(out_valid_o);
                @(posedge clk_i);
                $display("C[%0d][%0d] = %0d", row, col, out_data_o);
            end
        end

        $finish;
    end
endmodule
