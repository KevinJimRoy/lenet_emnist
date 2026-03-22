`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2026 13:52:03
// Design Name: 
// Module Name: conv_core
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

module bias_bram
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3,
    parameter DEPTH = 6
)
(
    input clk,
    input [ADDR_WIDTH-1:0] addr,
    output reg signed [DATA_WIDTH-1:0] bias_out
);

    (* ram_style = "block" *)
    reg signed [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial
    begin
        $readmemh("upload path of req. hex file", mem);
    end

    always @(posedge clk)
    begin
        bias_out <= mem[addr];
    end

endmodule
