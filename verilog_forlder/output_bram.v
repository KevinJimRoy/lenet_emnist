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

    input [12:0] addr,
    input [DATA_WIDTH-1:0] din,

    output reg [DATA_WIDTH-1:0] dout
);
(* ram_style = "block" *)
reg [DATA_WIDTH-1:0] mem [0:1175];

always @(posedge clk)
begin
    if(we)
        mem[addr] <= din;

    dout <= mem[addr];
end

endmodule