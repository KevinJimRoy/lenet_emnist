`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: l2_fmap_bram
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


module l2_fmap_bram
(
    input clk,

    // Write port — from fmap reader
    input         we,
    input  [12:0] wr_addr,
    input  [7:0]  din,

    // Read port — from sliding window
    input  [12:0] rd_addr,
    output reg [7:0] dout
);

reg [7:0] mem [0:1175];  // 6 * 14 * 14 = 1176

always @(posedge clk)
begin
    if(we)
        mem[wr_addr] <= din;

    dout <= mem[rd_addr];
end

endmodule
