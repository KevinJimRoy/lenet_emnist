`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: l2_pool_bram
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

module l2_pool_bram
#(
    parameter DATA_WIDTH = 13,
    parameter DEPTH      = 400
)
(
    input clk,

    input        we,
    input  [8:0] wr_addr,
    input  [DATA_WIDTH-1:0] din,

    input  [8:0] rd_addr,
    output reg [DATA_WIDTH-1:0] dout0, dout1, dout2, dout3
);

localparam BANK_DEPTH = DEPTH / 4;

reg [DATA_WIDTH-1:0] mem0 [0:BANK_DEPTH-1];
reg [DATA_WIDTH-1:0] mem1 [0:BANK_DEPTH-1];
reg [DATA_WIDTH-1:0] mem2 [0:BANK_DEPTH-1];
reg [DATA_WIDTH-1:0] mem3 [0:BANK_DEPTH-1];


always @(posedge clk)
begin
    if (we) begin
        case (wr_addr[1:0])   
            2'd0: mem0[wr_addr[8:2]] <= din;
            2'd1: mem1[wr_addr[8:2]] <= din;
            2'd2: mem2[wr_addr[8:2]] <= din;
            2'd3: mem3[wr_addr[8:2]] <= din;
        endcase
    end
end


always @(posedge clk)
begin
    dout0 <= mem0[rd_addr[8:2]];  
    dout1 <= mem1[rd_addr[8:2]]; 
    dout2 <= mem2[rd_addr[8:2]]; 
    dout3 <= mem3[rd_addr[8:2]]; 
end

endmodule