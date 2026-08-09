`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: l2_relu
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


module l2_relu #(
    parameter new_width = 13
)(
    input  signed [new_width-1:0] din,
    output signed [new_width-1:0] dout
);

assign dout = (din[new_width-1] == 1'b1) ? 13'd0 : din;

endmodule
