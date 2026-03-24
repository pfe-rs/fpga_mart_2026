module game (
    input logic clk,
    input logic rst,

    input logic [3:0]seed,

    input logic paddle1_up,
    input logic paddle1_down,
    input logic paddle2_up,
    input logic paddle2_down,

    output logic [2:0] paddle1_y,
    output logic [2:0] paddle2_y,
    output logic [2:0] ball_x,
    output logic [2:0] ball_y,
    output logic [3:0] score1,
    output logic [3:0] score2
);

    logic velx;
    logic signed [1:0] vely;
    logic [3:0] random;

    logic [2:0]next_ball_x;
    logic [2:0]next_ball_y;
    logic [2:0]next_paddle1Y;
    logic [2:0]next_paddle2Y;
    logic next_velx;
    logic signed [1:0] next_vely;


    always_comb begin

        //default values setup
        next_paddle1Y = paddle1_y;
        next_paddle2Y = paddle2_y;
        next_ball_x   = ball_x;
        next_ball_y   = ball_y;
        next_velx     = velx;
        next_vely     = vely;


        //kretanje paddle-a
        if (paddle1_up && paddle1_y > 0)
                next_paddle1Y = paddle1_y - 1;
        else if (paddle1_down && paddle1_y < 5)
                next_paddle1Y = paddle1_y + 1;

        if (paddle2_up && paddle2_y > 0)
                next_paddle2Y= paddle2_y - 1;
        else if (paddle2_down && paddle2_y < 5)
                next_paddle2Y = paddle2_y + 1;


        //kretanje loptice
        if(velx)
            next_ball_x = ball_x + 1;
        else
            next_ball_x = ball_x - 1;

        if(vely == 1)
            next_ball_y = ball_y + 1;
        if(vely == -1)
            next_ball_y = ball_y - 1;

        //flipovanje, odbijanje od zida
        if(next_ball_y == 0)
            next_vely = 1;
        else if (next_ball_y == 7)
            next_vely = -1;

        //flipovanje od paddova za levi paddle
        if(next_ball_x == 1 && !velx)begin
            if(next_ball_y >= next_paddle1Y && next_ball_y < next_paddle1Y + 3) begin
                next_velx = 1;
                if (next_ball_y == next_paddle1Y) begin
                    next_vely = -1;
                end else if (next_ball_y == next_paddle1Y + 1) begin
                    next_vely = 0;
                end else begin
                    next_vely = 1;
                end
            end
        end


        //flipovanje od paddova za desni paddle
        if(next_ball_x == 6 && velx)begin
            if(next_ball_y >= next_paddle2Y && next_ball_y < next_paddle2Y + 3) begin
                next_velx = 0;
                if (next_ball_y == next_paddle2Y) begin
                    next_vely = -1;
                end else if (next_ball_y == next_paddle2Y + 1) begin
                    next_vely = 0;
                end else begin
                    next_vely = 1;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            paddle1_y <= 3;
            paddle2_y <= 3;
            random <= seed;

            if(seed[0])begin
                ball_x <= 4;
                velx <= 1;
            end else begin
                ball_x <= 3;
                velx <= 0;
            end

            ball_y <= 4;
            vely <= 0;

            score1 <= 0;
            score2 <= 0;
        end
        else begin

            paddle1_y <= next_paddle1Y;
            paddle2_y <= next_paddle2Y;
            ball_x <= next_ball_x;
            ball_y <= next_ball_y;
            velx <= next_velx;
            vely <= next_vely;

            //zapocinjanje nove runde
            if(next_ball_x == 0 || next_ball_x == 7) begin
                if(next_ball_x == 0)
                score1 <= score1 + 1;
                else
                score2 <= score2 + 1;

                if(random[0])begin
                    ball_x <= 4;
                    velx <= 1;
                end else begin
                    ball_x <= 3;
                    velx <= 0;
                end
                random <= {random[2:0], random[3] ^ random[2]};

                ball_y <= 4;
                vely <= 0;

                paddle1_y <= 3;
                paddle2_y <= 3;
            end
        end
    end
endmodule
