`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 23:11:36
// Design Name: 
// Module Name: l3_weight_bram
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


module l3_weight_bram #(
    parameter DATA_WIDTH = 13,
    parameter DEPTH      = 4000
)(
    input  wire                          clk,
    input  wire [$clog2(DEPTH/4)-1:0]    rd_addr,
    output reg  [DATA_WIDTH-1:0]         w0,
    output reg  [DATA_WIDTH-1:0]         w1,
    output reg  [DATA_WIDTH-1:0]         w2,
    output reg  [DATA_WIDTH-1:0]         w3
);
    (* ram_style = "block" *)
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        $readmemh("l3_weights.mem", mem);
    end

    always @(posedge clk) begin
        w0 <= {mem[{rd_addr, 2'b00}],5'b0};
        w1 <= {mem[{rd_addr, 2'b01}],5'b0};
        w2 <= {mem[{rd_addr, 2'b10}],5'b0};
        w3 <= {mem[{rd_addr, 2'b11}],5'b0};
    end

endmodule