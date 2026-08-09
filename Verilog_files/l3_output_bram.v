`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 11:08:02
// Design Name: 
// Module Name: l3_output_bram
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


module l3_output_bram #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 10  
)(
    input  wire clk,
    input  wire we,

    input  wire [$clog2(DEPTH)-1:0] wr_addr,
    input  wire [DATA_WIDTH-1:0]    din,

    input  wire [$clog2(DEPTH)-1:0] rd_addr,
    output reg  [DATA_WIDTH-1:0]    dout
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];


    always @(posedge clk) begin
        if (we) begin
            mem[wr_addr] <= din;
        end
        dout <= mem[rd_addr]; 
    end

endmodule