// Optimized version of nco_chirp.v for low-area
module nco_chirp #(
    parameter PHASE_WIDTH   = 32,   // phase accumulator width
    parameter MAX_SF_WIDTH  = 8,    // SF bits
    parameter MAX_SF_VALUE  = 32,
    parameter BW_BITWIDTH   = 2     // BW config width
)(
    input  wire                      i_clk,
    input  wire                      i_rst_n,
    input  wire                      i_start_n,
    input  wire [MAX_SF_WIDTH-1:0]   i_SF,
    input  wire [1:0]                i_bw_config,
    input  wire [PHASE_WIDTH-1:0]    i_init_phase_inc,
    input  wire [PHASE_WIDTH-1:0]    i_slope,
    input  wire                      i_sample_tick_n,
    output reg  [PHASE_WIDTH-1:0]    o_phase_acc,
    output reg                       o_done_n
);
    reg [PHASE_WIDTH-1:0] r_phase_inc;

    reg [PHASE_WIDTH-1:0] PHASE_INC_MAX; //Phase inc maximum before chirp wraparound
    
    always @* begin
        case (i_bw_config)
            2'd0: PHASE_INC_MAX = 32'h0333_3333;
            2'd1: PHASE_INC_MAX = 32'h0666_6666;
            2'd2: PHASE_INC_MAX = 32'h0CCC_CCCC;
            default: PHASE_INC_MAX = 32'h0333_3333;
        endcase
    end

    localparam STATE_IDLE = 2'd0,
               STATE_LOAD = 2'd1,
               STATE_RUN  = 2'd2,
               STATE_DONE = 2'd3;

    reg [1:0] r_state, r_next_state;
    reg [MAX_SF_WIDTH-1:0] sample_cnt;
    wire [MAX_SF_VALUE-1:0] total_samples = (1 << i_SF);

    reg sample_tick_d;
    wire sample_tick_fall = sample_tick_d & ~i_sample_tick_n;

    reg [PHASE_WIDTH:0] next_inc;

    always @(posedge i_clk) begin
        sample_tick_d <= i_sample_tick_n;

        if (!i_rst_n) begin
            r_state     <= STATE_IDLE;
            sample_cnt  <= 0;
            o_phase_acc <= 0;
            r_phase_inc <= 0;
            o_done_n    <= 1;
        end else begin
            o_done_n <= 1;
            r_state  <= r_next_state;

            case (r_next_state)
                STATE_IDLE: begin
                    sample_cnt <= 0;
                    o_phase_acc <= 0;
                end
                STATE_LOAD: begin
                    sample_cnt  <= 0;
                    o_phase_acc <= 0;
                    r_phase_inc <= i_init_phase_inc;
                end
                STATE_RUN: begin
                    o_phase_acc <= o_phase_acc + r_phase_inc;
                    if (sample_tick_fall) begin
                        next_inc = r_phase_inc + i_slope;
                        r_phase_inc <= (next_inc >= PHASE_INC_MAX) ? (next_inc - PHASE_INC_MAX) : next_inc;
                        sample_cnt <= sample_cnt + 1;
                    end
                end
                STATE_DONE: begin
                    o_done_n <= 0;
                    o_phase_acc <= 0;
                end
            endcase
        end
    end

    always @(*) begin
        r_next_state = r_state;
        case (r_state)
            STATE_IDLE: if (!i_start_n) r_next_state = STATE_LOAD;
            STATE_LOAD:                r_next_state = STATE_RUN;
            STATE_RUN: if (sample_cnt == total_samples - 1) r_next_state = STATE_DONE;
            STATE_DONE:                r_next_state = STATE_IDLE;
        endcase
    end

endmodule


