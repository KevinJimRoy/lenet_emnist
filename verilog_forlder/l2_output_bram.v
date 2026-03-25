`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: l2_output_bram
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


module l2_output_bram
#(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 1600   
)
(
    input clk,


    input         we,
    input  [10:0] wr_addr,
    input  [DATA_WIDTH-1:0] din,


    input  [10:0] rd_addr,
    output reg [DATA_WIDTH-1:0] dout
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

always @(posedge clk)
begin
    if(we)
        mem[wr_addr] <= din;

    dout <= mem[rd_addr];
end

endmodule
