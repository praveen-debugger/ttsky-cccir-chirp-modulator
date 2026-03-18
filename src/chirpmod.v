module chirpmod #(
  parameter PHASE_WIDTH        = 32,
  parameter MAX_SF_WIDTH       = 8,
  parameter BW_BITWIDTH        = 2,
  parameter ADDR_WIDTH         = 6,
  parameter DATA_WIDTH         = 8,
  parameter DIVIDER_BITWIDTH   = 7
)(
  input  wire                      i_clk,     //!Input clock: 10 MHz
  input  wire                      i_rst_n,   //!Input reset active Low
  input  wire                      i_rx,      //!Input UART rx (9600 bps)
  output wire                      o_done_n,  //!Output done active Low
  output wire [DATA_WIDTH-1:0]     o_data     //!Output bus data
);

  // Fixed configuration parameters
  wire [15:0]              w_baud_div  = 16'd1042;      //UART rx baud rate = i_clk/Baud Divider (9600 bps)
  wire [MAX_SF_WIDTH-1:0]  w_SF      = 8'd8;            //SF value (SF8)
  wire [PHASE_WIDTH-1:0]   w_slope   = 32'h0003_3333;   //Slope for the phase accumulator of the chirp nco
  wire [BW_BITWIDTH-1:0]   w_bw_cfg  = 2'd0;            //BW config: 0 = 125 kHz

  // Internal connections
  wire [7:0]               w_rx_data;
  wire                     w_rx_valid_n;
  wire [PHASE_WIDTH-1:0]   w_init_phase_inc;
  wire                     w_slope_done_n;
  wire                     w_sample_tick_n;
  wire [PHASE_WIDTH-1:0]   w_phase_acc;
  wire [ADDR_WIDTH-1:0]    w_rom_addr = w_phase_acc[PHASE_WIDTH-1 -: ADDR_WIDTH];

  //Reset input synchronizer
  wire w_rst_n_synch; //Synchronized reset signal for all the logic blocks
  rst_sync rst_sync_inst(
    .i_rst_n(i_rst_n),
    .i_clk(i_clk),
    .o_rst_n(w_rst_n_synch)
  );

  // UART Receiver
  uart_rx uart_rx_inst (
    .i_clk(i_clk),
    .i_rst_n(w_rst_n_synch),
    .i_rx(i_rx),
    .i_baud_div(w_baud_div),
    .o_data(w_rx_data),
    .o_valid_n(w_rx_valid_n)
  );

  // Slope Accumulator
  slope_accumulator slope_acc_inst (
    .i_clk(i_clk),
    .i_rst_n(w_rst_n_synch),
    .i_start_n(w_rx_valid_n),
    .i_symbol(w_rx_data),
    .i_slope(w_slope),
    .o_done_n(w_slope_done_n),
    .o_value(w_init_phase_inc)
  );

  // Tick Generator
  tick_generator #(
    .BW_BITWIDTH(BW_BITWIDTH),
    .DIVIDER_BITWIDTH(DIVIDER_BITWIDTH)
  ) tick_gen_inst (
    .i_clk(i_clk),
    .i_rst_n(w_rst_n_synch),
    .i_start_n(w_slope_done_n),
    .i_bw_config(w_bw_cfg),
    .o_sample_tick_n(w_sample_tick_n)
  );

  // NCO Chirp Generator
  nco_chirp #(
    .PHASE_WIDTH(PHASE_WIDTH),
    .MAX_SF_WIDTH(MAX_SF_WIDTH),
    .MAX_SF_VALUE(32),
    .BW_BITWIDTH(BW_BITWIDTH)
  ) nco_inst (
    .i_clk(i_clk),
    .i_rst_n(w_rst_n_synch),
    .i_start_n(w_slope_done_n),
    .i_SF(w_SF),
    .i_bw_config(w_bw_cfg),
    .i_init_phase_inc(w_init_phase_inc),
    .i_slope(w_slope),
    .i_sample_tick_n(w_sample_tick_n),
    .o_phase_acc(w_phase_acc),
    .o_done_n(o_done_n)
  );

  // ROM Sample Output
  sine_rom #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) rom_inst (
    .i_clk(i_clk),
    .i_rst_n(w_rst_n_synch),
    .i_addr(w_rom_addr),
    .o_data(o_data)
  );

endmodule

