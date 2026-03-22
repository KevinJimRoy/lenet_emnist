`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2026 19:07:52
// Design Name: 
// Module Name: max_pooling
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


module max_pooling
#(
    parameter DATA_WIDTH = 8,
    parameter IMG_SIZE = 28
)
(
    input clk,
    input rst,

    input valid_in,
    input fmap_start,

    input [DATA_WIDTH-1:0] pixel_in,

    output reg valid_out,
    output reg [DATA_WIDTH-1:0] pixel_out,

    output reg [3:0] pool_row,
    output reg [3:0] pool_col
);

reg [DATA_WIDTH-1:0] line_buffer [0:IMG_SIZE-1];
reg [DATA_WIDTH-1:0] prev_pixel;

reg [5:0] row;
reg [5:0] col;

reg [DATA_WIDTH-1:0] a,b,c,d;
reg [DATA_WIDTH-1:0] max1,max2;

integer i;

always @(posedge clk or posedge rst)
begin
    if(rst || fmap_start)
    begin
        row <= 0;
        col <= 0;
        prev_pixel <= 0;

        pool_row <= 0;
        pool_col <= 0;

        valid_out <= 0;

        for(i=0;i<IMG_SIZE;i=i+1)
            line_buffer[i] <= 0;
    end

    else if(valid_in)
    begin

        line_buffer[col] <= pixel_in;

        if(row[0] && col[0])
        begin
            a = line_buffer[col-1];
            b = line_buffer[col];

            c = prev_pixel;
            d = pixel_in;

            max1 = (a>b)?a:b;
            max2 = (c>d)?c:d;

            pixel_out <= (max1>max2)?max1:max2;

            valid_out <= 1;

            if(pool_col == 13)
            begin
                pool_col <= 0;
                pool_row <= pool_row + 1;
            end
            else
                pool_col <= pool_col + 1;

        end
        else
            valid_out <= 0;

        prev_pixel <= pixel_in;

        if(col == IMG_SIZE-1)
        begin
            col <= 0;
            row <= row + 1;
        end
        else
            col <= col + 1;

    end
end

endmodule
