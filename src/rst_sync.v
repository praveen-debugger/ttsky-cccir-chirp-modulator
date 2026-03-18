module rst_sync (
    input wire i_rst_n,
    input wire i_clk,
    output reg o_rst_n
);

always@(posedge i_clk) begin
    o_rst_n <= i_rst_n;
end

endmodule