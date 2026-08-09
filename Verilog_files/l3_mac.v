`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 23:44:11
// Design Name: 
// Module Name: l3_mac
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


module l3_mac #(
    parameter DATA_WIDTH = 13
)(
    input clk,

    input signed [DATA_WIDTH-1:0] p0,
    input signed [DATA_WIDTH-1:0] p1,
    input signed [DATA_WIDTH-1:0] p2,
    input signed [DATA_WIDTH-1:0] p3,

    input signed [DATA_WIDTH-1:0] w0,
    input signed [DATA_WIDTH-1:0] w1,
    input signed [DATA_WIDTH-1:0] w2,
    input signed [DATA_WIDTH-1:0] w3,

    output reg signed [2*DATA_WIDTH+3:0] mac_out
);

    reg signed [2*DATA_WIDTH-1:0] m0;
    reg signed [2*DATA_WIDTH-1:0] m1;
    reg signed [2*DATA_WIDTH-1:0] m2;
    reg signed [2*DATA_WIDTH-1:0] m3;

    reg signed [2*DATA_WIDTH+1:0] s0;
    reg signed [2*DATA_WIDTH+1:0] s1;

    always @(posedge clk) begin
        m0 <= p0 * w0;
        m1 <= p1 * w1;
        m2 <= p2 * w2;
        m3 <= p3 * w3;

        s0 <= m0 + m1;
        s1 <= m2 + m3;

        mac_out <= s0 + s1;
    end

endmodule
