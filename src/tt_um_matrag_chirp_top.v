/*
 * Copyright (c) 2024 matrag
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_matrag_chirp_top (
    input  wire [7:0] ui_in,    // Dedicated inputs - ui_in[0] UART RX
    output wire [7:0] uo_out,   // Dedicated outputs - Out 8 bit data: uo_out[7:0]
    input  wire [7:0] uio_in,   // IOs: Input path - unused
    output wire [7:0] uio_out,  // IOs: Output path - Done signal from chirp generator: uio_out[0]
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled, always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

//-------------------Design instantiation-------------------------------
chirpmod #(
    .PHASE_WIDTH        (32),
    .MAX_SF_WIDTH       (8),
    .BW_BITWIDTH        (2),
    .ADDR_WIDTH         (6),
    .DATA_WIDTH         (8),
    .DIVIDER_BITWIDTH   (7)
  ) 
  chirp_module 
  (
    .i_clk   (clk),   //!Input clock: 10 MHz
    .i_rst_n (rst_n),   //!Input reset active Low
    .i_rx    (ui_in[0]),   //!Input UART rx (9600 bps) //UART RX input line: ui_in[0] port
    .o_done_n(uio_out[0]), //!Output done active Low
    .o_data  (uo_out)    //!Output bus data (8 bit)
  );

     //-------------------IO Ports assigned to Output ('1')------------------
    assign uio_oe   [7:0]   = 8'b0000_0001; //enable used uio outputs
    assign uio_out  [7:1]   = 7'b0000_000;   //set other to zero

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_oe[7:0], uio_out[7:1], ui_in[7:1], uio_in[7:0], 1'b0};

endmodule












