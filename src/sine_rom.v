// Full-range sine_rom.v (0–255)
// Auto-generated 64-entry 8-bit sine wave ROM
module sine_rom #(
    parameter ADDR_WIDTH = 6,  // 64 entries
    parameter DATA_WIDTH = 8   // 8-bit output
)(
    input  wire                  i_clk,
    input  wire                  i_rst_n,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    output reg  [DATA_WIDTH-1:0] o_data
);

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            o_data <= 8'd85;
        end else begin
            case (i_addr)
                6'd0: o_data <= 8'd128;
                6'd1: o_data <= 8'd140;
                6'd2: o_data <= 8'd152;
                6'd3: o_data <= 8'd165;
                6'd4: o_data <= 8'd176;
                6'd5: o_data <= 8'd188;
                6'd6: o_data <= 8'd198;
                6'd7: o_data <= 8'd208;
                6'd8: o_data <= 8'd218;
                6'd9: o_data <= 8'd226;
                6'd10: o_data <= 8'd234;
                6'd11: o_data <= 8'd240;
                6'd12: o_data <= 8'd245;
                6'd13: o_data <= 8'd250;
                6'd14: o_data <= 8'd253;
                6'd15: o_data <= 8'd254;
                6'd16: o_data <= 8'd255;
                6'd17: o_data <= 8'd254;
                6'd18: o_data <= 8'd253;
                6'd19: o_data <= 8'd250;
                6'd20: o_data <= 8'd245;
                6'd21: o_data <= 8'd240;
                6'd22: o_data <= 8'd234;
                6'd23: o_data <= 8'd226;
                6'd24: o_data <= 8'd218;
                6'd25: o_data <= 8'd208;
                6'd26: o_data <= 8'd198;
                6'd27: o_data <= 8'd188;
                6'd28: o_data <= 8'd176;
                6'd29: o_data <= 8'd165;
                6'd30: o_data <= 8'd152;
                6'd31: o_data <= 8'd140;
                6'd32: o_data <= 8'd128;
                6'd33: o_data <= 8'd115;
                6'd34: o_data <= 8'd103;
                6'd35: o_data <= 8'd90;
                6'd36: o_data <= 8'd79;
                6'd37: o_data <= 8'd67;
                6'd38: o_data <= 8'd57;
                6'd39: o_data <= 8'd47;
                6'd40: o_data <= 8'd37;
                6'd41: o_data <= 8'd29;
                6'd42: o_data <= 8'd21;
                6'd43: o_data <= 8'd15;
                6'd44: o_data <= 8'd10;
                6'd45: o_data <= 8'd5;
                6'd46: o_data <= 8'd2;
                6'd47: o_data <= 8'd1;
                6'd48: o_data <= 8'd0;
                6'd49: o_data <= 8'd1;
                6'd50: o_data <= 8'd2;
                6'd51: o_data <= 8'd5;
                6'd52: o_data <= 8'd10;
                6'd53: o_data <= 8'd15;
                6'd54: o_data <= 8'd21;
                6'd55: o_data <= 8'd29;
                6'd56: o_data <= 8'd37;
                6'd57: o_data <= 8'd47;
                6'd58: o_data <= 8'd57;
                6'd59: o_data <= 8'd67;
                6'd60: o_data <= 8'd79;
                6'd61: o_data <= 8'd90;
                6'd62: o_data <= 8'd103;
                6'd63: o_data <= 8'd115;
                default: o_data <= 8'd128;
            endcase
        end
    end

endmodule


