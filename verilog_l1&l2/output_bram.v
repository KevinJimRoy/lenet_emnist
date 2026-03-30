`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 23:33:37
// Design Name: 
// Module Name: output_bram
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


module output_bram
#(
    parameter DATA_WIDTH = 8
)
(
    input clk,

    input we,
    input [12:0] wr_addr,
    input [DATA_WIDTH-1:0] din,

    input  [12:0] rd_addr,
    output reg [DATA_WIDTH-1:0] dout
);

reg [DATA_WIDTH-1:0] mem [0:1175];

integer i;
initial
begin
    for(i = 0; i < 1176; i = i + 1)
        mem[i] = 8'h00;
end

always @(posedge clk)
begin
    if(we)
        mem[wr_addr] <= din;
    dout <= mem[rd_addr];
end

endmodule