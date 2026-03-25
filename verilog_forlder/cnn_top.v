`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: cnn_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cnn_top
(
    input clk,
    input rst,
    input start,

    input         l2_wt_we,
    input  [11:0] l2_wt_wr_addr,
    input  signed [7:0] l2_wt_din,

    input        l2_bias_we,
    input  [3:0] l2_bias_wr_addr,
    input  signed [7:0] l2_bias_din,

    input  [8:0] l3_rd_addr,
    output [7:0] l3_pixel_out,

    output l2_done
);

wire l1_done;
wire l2_start;
reg  l2_start_reg;
reg  l2_started;

wire [12:0] l2_rd_addr;
wire [7:0]  l2_pixel_in;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        l2_start_reg <= 0;
        l2_started   <= 0;
    end
    else
    begin
        l2_start_reg <= 0;
        if(l1_done && !l2_started)
        begin
            l2_start_reg <= 1;
            l2_started   <= 1;
        end
    end
end

assign l2_start = l2_start_reg;

layer1_top layer1_inst(
    .clk(clk),
    .rst(rst),
    .start(start),
    .l2_rd_addr(l2_rd_addr),
    .l2_pixel_out(l2_pixel_in),
    .done(l1_done)
);


layer2_top layer2_inst(
    .clk(clk),
    .rst(rst),
    .start(l2_start),
    .l1_rd_addr(l2_rd_addr),
    .l1_pixel_in(l2_pixel_in),
    .l3_rd_addr(l3_rd_addr),
    .l3_pixel_out(l3_pixel_out),
    .done(l2_done)
);

endmodule

