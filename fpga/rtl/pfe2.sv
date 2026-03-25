module pfe2#(parameter N=8 ,parameter tpb=5208, parameter tpbs=13)(
    input clk_i,
    input out_ready_i,
    input rx,
    output [N-1:0] out_data_o,
    output reg out_valid_o,
    output reg busy
);

localparam ticks_to_bit = tpb - 1;
localparam ticks_to_middle = (tpb / 2) - 1;

reg [N-1:0] rxdata;
assign out_data_o = rxdata;

logic din;
wire din_signal = ~rx & din; 
reg [3:0] cnt;
reg [tpbs-1:0] ticks_cnt;
reg [tpbs-1:0] comp;
wire ticks_of_signal = (ticks_cnt >= comp); 

reg [2:0] state, next_state;
localparam idle_state  = 3'b000;
localparam start_state = 3'b001;
localparam data_state  = 3'b010;
localparam stop_state  = 3'b011;
localparam done_state  = 3'b100;

initial begin
    state = idle_state;
    ticks_cnt = 0;
    cnt = 0;
    din = 1;
    rxdata = 0;
end

always @(*) begin
    
    next_state = state;
    out_valid_o = 0;
    busy = 1;
    comp = ticks_to_bit;

    case (state)
        idle_state: begin
            busy = 0;
            comp = ticks_to_middle;
            if (out_ready_i && din_signal)
                next_state = start_state;
            else
                next_state = idle_state;
        end

        start_state: begin
            comp = ticks_to_middle;
            if (ticks_of_signal)
                next_state = data_state;
        end

        data_state: begin
            comp = ticks_to_bit;
        
            if (ticks_of_signal && (cnt == N-1))
                next_state = stop_state;
        end

        stop_state: begin
            comp = ticks_to_bit;
            if (ticks_of_signal)
                next_state = done_state;
        end

        done_state: begin
            out_valid_o = 1;
            next_state = idle_state;
        end
        
        default: next_state = idle_state;
    endcase
end

always @(posedge clk_i) begin
    state <= next_state;
    din <= rx; 

    if (state == idle_state) begin
        ticks_cnt <= 0;
        cnt <= 0;
    end else begin
        if (ticks_of_signal) begin
            ticks_cnt <= 0;
            if (state == data_state) begin
                rxdata <= {din, rxdata[N-1:1]};
                cnt <= cnt + 1;
            end
        end else begin
            ticks_cnt <= ticks_cnt + 1;
        end
    end
end

endmodule