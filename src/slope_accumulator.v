// Serial adder FSM: o_value = i_symbol × i_slope using 1-cycle start pulse
module slope_accumulator (
    input  wire        i_clk,
    input  wire        i_rst_n,      // Active-low reset
    input  wire        i_start_n,    // Active-low start pulse
    input  wire [7:0]  i_symbol,     // Symbol to transmit
    input  wire [31:0] i_slope,      // Step to accumulate
    output reg         o_done_n,     // Active-low done pulse
    output reg [31:0]  o_value       // Output = symbol × slope
);

    // FSM state encoding
    
    localparam IDLE       = 2'd0;
    localparam LOAD       = 2'd1;
    localparam ACCUMULATE = 2'd2;
    localparam DONE       = 2'd3;

    reg [1:0] state, next_state;

    reg [7:0] r_count;

    // FSM sequential
    always @(posedge i_clk) begin
        if (!i_rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM combinational
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:       if (!i_start_n)        next_state = LOAD;
            LOAD:                             next_state = (i_symbol != 0) ? ACCUMULATE : DONE;
            ACCUMULATE: if (r_count == 1)     next_state = DONE;
            DONE:                              next_state = IDLE;
        endcase
    end

    // Outputs and datapath
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            o_value   <= 32'd0;
            r_count   <= 8'd0;
            o_done_n  <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    o_done_n <= 1'b1;
                end
                LOAD: begin
                    o_value  <= 32'd0;
                    r_count  <= i_symbol;
                end
                ACCUMULATE: begin
                    o_value  <= o_value + i_slope;
                    r_count  <= r_count - 1;
                end
                DONE: begin
                    o_done_n <= 1'b0;  // Pulse done low
                end
            endcase
        end
    end

endmodule
