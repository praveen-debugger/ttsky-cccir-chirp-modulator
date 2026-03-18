module tick_generator #(
    parameter BW_BITWIDTH = 2,
    parameter DIVIDER_BITWIDTH = 7
)(
    input  wire                    i_clk,
    input  wire                    i_rst_n,
    input  wire                    i_start_n,        // Active-low level signal
    input  wire [BW_BITWIDTH-1:0]  i_bw_config,      // 00:125kHz, 01:250kHz, 10:500kHz
    output reg                     o_sample_tick_n   // Active-low 1-cycle pulse
);

    // --------------------------------------------------------------------------
    // State definition
    // --------------------------------------------------------------------------
    parameter  IDLE = 2'b00;
    parameter  RUN  = 2'b01;

    reg [1:0] r_state;

    // --------------------------------------------------------------------------
    // Divider selection
    // --------------------------------------------------------------------------
    wire [DIVIDER_BITWIDTH-1:0] w_divider_val =
        (i_bw_config == 2'd0) ? 7'd80 :  // 125kHz
        (i_bw_config == 2'd1) ? 7'd40 :  // 250kHz
        (i_bw_config == 2'd2) ? 7'd20 :  // 500kHz
                                7'd80;

    // --------------------------------------------------------------------------
    // Internal signals
    // --------------------------------------------------------------------------
    reg [DIVIDER_BITWIDTH-1:0] r_counter;

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            r_state <= IDLE;
            r_counter       <= 0;
            o_sample_tick_n <= 1'b1;  // inactive
        end else begin
            case (r_state)
                IDLE: begin
                    r_counter       <= 0;
                    o_sample_tick_n <= 1'b1;
                    if(i_start_n) begin
                        r_state <= RUN;
                    end
                end

                RUN: begin
                    if (r_counter == w_divider_val - 1) begin
                        r_counter       <= 0;
                        o_sample_tick_n <= 1'b0;  // active-low pulse
                        r_state <= IDLE;
                    end else begin
                        r_counter       <= r_counter + 1;
                        o_sample_tick_n <= 1'b1;
                        r_state <= RUN;
                    end
                end
            endcase
        end
    end

endmodule

