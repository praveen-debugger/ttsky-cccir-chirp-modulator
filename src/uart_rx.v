module uart_rx (
    input  wire        i_clk,        // System clock
    input  wire        i_rst_n,      // Active-low reset
    input  wire        i_rx,         // UART RX line
    input  wire [15:0] i_baud_div,   // Baud rate divider

    output reg  [7:0]  o_data,       // Received data
    output reg         o_valid_n      // Data valid flag
);

    reg [3:0]  r_bit_cnt;
    reg [15:0] r_clk_cnt;
    reg [7:0]  r_shift_reg;
    reg        r_rx_active;
    reg        r_sample;

    localparam IDLE = 3'd0,
               WAIT = 3'd1,
               BUSY = 3'd2,
               STOP = 3'd3,
               DONE = 3'd4;


    reg [2:0]  r_state;

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            r_bit_cnt   <= 0;
            r_clk_cnt   <= 0;
            r_rx_active <= 0;
            r_shift_reg <= 0;
            r_sample <= 0;
            r_state     <= IDLE;
            o_data      <= 8'd0;
            o_valid_n     <= 1'b1;
        end else begin
            case (r_state)
                IDLE: begin
                    o_valid_n <= 1'b1;
                    if (i_rx == 1'b0) begin  // Start bit detected
                        r_state     <= WAIT;
                        r_bit_cnt   <= 0;
                        r_clk_cnt   <= 0;
                        r_shift_reg <= 0;
                        r_rx_active <= 1'b1;
                    end
                end

                WAIT: begin // wait start symbol to end
                    if(r_clk_cnt   == i_baud_div) begin
                        r_clk_cnt   <= i_baud_div >> 1; // sample in middle of bit: count to half total of bit clock cycles
                        r_state     <= BUSY;
                    end
                    else begin
                        r_clk_cnt <= r_clk_cnt + 1;
                    end
                end


                BUSY: begin
                    if (r_clk_cnt == i_baud_div) begin
                        r_clk_cnt <= 0;
                        r_shift_reg <= {i_rx, r_shift_reg[7:1]}; //fill shift reg with data
                        r_bit_cnt <= r_bit_cnt + 1;

                        if (r_bit_cnt == 7) begin
                            r_rx_active <= 0;
                            r_state <= STOP;
                            r_shift_reg <= {i_rx, r_shift_reg[7:1]}; //fill last bit
                        end
                    end else begin
                        r_clk_cnt <= r_clk_cnt + 1;
                    end
                end

                STOP: begin
                    if (r_clk_cnt == i_baud_div) begin
                        r_state <= DONE;
                    end else begin
                        r_clk_cnt <= r_clk_cnt +1; 
                    end                   
                end

                DONE: begin
                    o_valid_n <= 1'b0; //activate valid
                    o_data <= r_shift_reg;
                    r_state <= IDLE;
                end
            endcase
        end
    end
endmodule
