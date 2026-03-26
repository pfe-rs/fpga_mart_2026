// pfe.v
//
// Processing module with parametrizable word width.
// NUM_BYTES sets the data width: 1 = 8-bit, 2 = 16-bit, 4 = 32-bit, etc.
//
// Currently passes data through unchanged.
// Modify the always block to add your processing.

module pfe (
    input  wire                      clk,
    input  wire                      rst_n,



    //output logic [3:0] timer_down_d,  //OUTPUT TIMER_DOWN_D
    output logic [6:0] HEX0  ,
    
    input logic pw,
    
    output logic ar,
    output logic nsy,
    output logic nsg,
    output logic ewy,
    output logic ewg
    
);
    typedef enum logic [2:0] {  // logika za stanja semafora
    s_ar_nsew = 3'b000,
    s_ar_ewns = 3'b001,
    s_nsy=3'b010,
    s_nsg=3'b011,
    s_ewy=3'b100,
    s_ewg=3'b101
    } stanje;

    stanje state, next_state;  // promenjive za trenutno i sledece stanje 
    logic pw_req;  //

    logic [3:0] timer_down; //PROMENJIVA BEZ D

    localparam int MAX_TICKS   = 7;
    localparam int GREEN_TICKS = 5;
    localparam int AMBER_TICKS = 3;
    localparam int RED_TICKS   = 7;

    logic [$clog2(MAX_TICKS+1)-1:0] timer; // logika
    logic timer_done;

    logic [25:0] clk_div;
    logic sec_tick;

    always_ff @(posedge clk or negedge rst_n) begin // logika za tikove u sekundama preko clock dividera
        if (!rst_n) begin
            clk_div  <= 26'd0;
            sec_tick <= 1'b0;
        end
        else if (clk_div == 50_000_000 - 1) begin
            clk_div  <= 26'd0;
            sec_tick <= 1'b1;
        end
        else begin
            clk_div  <= clk_div + 1'b1;
            sec_tick <= 1'b0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin // resetuje tajmere i sec tick?
        if (!rst_n)
            timer <= '0;
        else if (timer_done)
            timer <= '0;
        else if (sec_tick)
            timer <= timer + 1'b1;
    end
    
    always_ff @(posedge clk or negedge rst_n) begin // pw req pamti zahtev za pw
        if (!rst_n)
            pw_req <= 1'b0;
        else if (state == s_ar_nsew || state == s_ar_ewns)
            pw_req <= 1'b0;
        else if (!pw)   
            pw_req <= 1'b1;
    end 

    always_ff @(posedge clk or negedge rst_n) begin //reg stanja
        if (!rst_n)
            state <= s_nsg;
        else if (timer_done)
            state <= next_state;
    end



    always_comb begin  // case za nesxt stanja i odbrojavanja
        case (state)
            s_nsg:   begin 
                next_state = s_nsy; 
                timer_done = (timer == GREEN_TICKS-1 ) ? 1'b1 : 1'b0;
                timer_down = GREEN_TICKS - timer-1; 
            end
            s_nsy:   begin
                next_state = s_ar_nsew;  
                timer_done = (timer == AMBER_TICKS-1) ? 1'b1 : 1'b0;
                timer_down = AMBER_TICKS - timer-1; 
            end
            s_ar_nsew:     begin 
                next_state = s_ewg; 
                timer_done = (timer == RED_TICKS -1 ) ? 1'b1 : 1'b0;
                timer_down = RED_TICKS - timer-1; 
            end
            s_ewg:   begin 
                next_state = s_ewy; 
                timer_done = (timer == GREEN_TICKS -1) ? 1'b1 : 1'b0;
                timer_down = GREEN_TICKS - timer-1; 
             end
            s_ewy:   begin
                 next_state = s_ar_ewns;   
                 timer_done = (timer == AMBER_TICKS -1) ? 1'b1 : 1'b0;
                 timer_down = AMBER_TICKS - timer-1;  
                end
            s_ar_ewns:     begin 
                next_state = s_nsg; 
                timer_done = (timer == RED_TICKS -1) ? 1'b1 : 1'b0;
                timer_down = RED_TICKS - timer-1; 
            end
            default: begin 
                next_state = s_nsg;
                timer_done = 1'b0;
            end
            endcase
        if(pw_req&&timer_done) begin  // gura u pw mod ako je pw req 1
            next_state=s_ar_nsew;
        end
    end

  
    always_comb begin
        nsg   =(state == s_nsg);
        nsy   =  (state == s_nsy);
        ar   = (state == s_ar_nsew || state == s_ar_ewns);
        ewg   = (state == s_ewg);
        ewy   = (state == s_ewy);
    end

    always_comb begin
    case (timer_down)
        4'd0: HEX0 = 7'b1000000;
        4'd1: HEX0 = 7'b1111001;
        4'd2: HEX0 = 7'b0100100;
        4'd3: HEX0 = 7'b0110000;
        4'd4: HEX0 = 7'b0011001;
        4'd5: HEX0 = 7'b0010010;
        4'd6: HEX0 = 7'b0000010;
        4'd7: HEX0 = 7'b1111000;
        default: HEX0 = 7'b1111111;
    endcase
end

//assign timer_down_d=timer_down;


endmodule

