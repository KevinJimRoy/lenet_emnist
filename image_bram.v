`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 20:29:44
// Design Name: 
// Module Name: image_bram
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

module image_bram
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10,
    parameter DEPTH = 1024
)
(
    input clk,
    input [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] pixel_out
);

    (* ram_style = "block" *)
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial
    begin
        $readmemh("C:/ACAD/Sem6/OELP_DL_VLSI/cnn_conv/cnn_conv.srcs/sources_1/new/input_image.hex", mem);
    end

    always @(posedge clk)
    begin
        pixel_out <= mem[addr];
    end

endmodule
