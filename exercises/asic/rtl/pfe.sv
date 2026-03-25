module pfe #(
    parameter int DSIZE  = 256
)(
    input  logic             clk_i,
    input  logic             rst_ni,

    input  logic [DSIZE-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,
    
    output logic [DSIZE-1:0] out_data_o,
    output logic             out_valid_o,
    input  logic             out_ready_i
);
    localparam int head = 15;

    logic [4:0] pc;
    logic [7:0] tape_mem [0:31];
    logic [7:0] instruction_memory_32x8 [0:31];
    logic [7:0] state_register;
    logic signed [4:0] operand;

    typedef enum logic [2:0] {
        OP_left_shift  = 3'b000,
        OP_right_shift = 3'b001,
        OP_minus       = 3'b010,
        OP_plus        = 3'b011,
        OP_if_jump     = 3'b100,
        OP_jump        = 3'b101
    } Opcode;

    Opcode current_instruction;

    typedef enum logic [2:0] {
        LOAD    = 3'b000,
        FETCH   = 3'b001,
        DECODE  = 3'b010,
        EXECUTE = 3'b011,
        UPDATE  = 3'b100,
        HALT    = 3'b101
    } fsm_t;

    fsm_t FSM_stage;

    always_comb begin
        for (int i = 0; i < 32; i++) begin
            out_data_o[i*8 +: 8] = tape_mem[i];
        end
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            FSM_stage      <= LOAD;
            pc             <= 5'b0;
            state_register <= 8'b0;
            for (int i = 0; i < 32; i++) begin
                tape_mem[i]                <= i + 1; // Inicijalizacija trake
                instruction_memory_32x8[i] <= 8'b0;
            end

        end else begin
            case (FSM_stage)

                LOAD: begin
                    if (in_valid_i) begin
                        for (int i = 0; i < 32; i++)
                            instruction_memory_32x8[i] <= in_data_i[i*8 +: 8];
                        FSM_stage <= FETCH;
                    end
                end

                FETCH: begin
                    state_register <= tape_mem[head];
                    FSM_stage      <= DECODE;
                end

                DECODE: begin
                    current_instruction <= Opcode'(instruction_memory_32x8[pc][2:0]);
                    operand             <= instruction_memory_32x8[pc][7:3];
                    FSM_stage           <= EXECUTE;
                end

                EXECUTE: begin
                    case (current_instruction)
                        OP_left_shift: begin
                            for (int i = 31; i > 0; i--) tape_mem[i] <= tape_mem[i-1];
                            tape_mem[0] <= 8'b0;
                            FSM_stage   <= UPDATE;
                        end
                        OP_right_shift: begin
                            for (int i = 0; i < 31; i++) tape_mem[i] <= tape_mem[i+1];
                            tape_mem[31] <= 8'b0;
                            FSM_stage    <= UPDATE;
                        end
                        OP_minus: begin
                            state_register <= state_register - 1;
                            FSM_stage      <= UPDATE;
                        end
                        OP_plus: begin
                            state_register <= state_register + 1;
                            FSM_stage      <= UPDATE;
                        end
                        OP_if_jump: FSM_stage <= fsm_t'((state_register != 0) ? UPDATE : HALT);
                        OP_jump:    FSM_stage <= fsm_t'((operand == 5'b0)     ? HALT   : UPDATE);
                        default:    FSM_stage <= UPDATE;
                    endcase
                end

                UPDATE: begin
                    if (current_instruction != OP_jump && current_instruction != OP_if_jump)
                        pc <= pc + 1;
                    else
                        pc <= pc + $unsigned(operand);

                    if (current_instruction == OP_plus || current_instruction == OP_minus)
                        tape_mem[head] <= state_register;

                    FSM_stage <= FETCH;         
                end

                HALT: begin
                    if (out_ready_i) begin
                        FSM_stage <= LOAD;
                        pc        <= 5'b0;
                    end
                end

                default: FSM_stage <= LOAD;
            endcase
        end
    end
    
    assign in_ready_o  = (FSM_stage == LOAD);
    assign out_valid_o = (FSM_stage == HALT);

endmodule