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
    parameter IMG_SIZE   = 28
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
    output reg [3:0] pool_col,
    output reg [3:0] pool_row_out,
    output reg [3:0] pool_col_out
);

reg [DATA_WIDTH-1:0] curr_row_buf [0:IMG_SIZE-1];
reg [DATA_WIDTH-1:0] prev_row_buf [0:IMG_SIZE-1];

reg [DATA_WIDTH-1:0] prev_pixel;

reg [5:0] row;
reg [5:0] col;

reg [DATA_WIDTH-1:0] a, b, c, d;
reg [DATA_WIDTH-1:0] max1, max2;

reg        valid_out_d;
reg [DATA_WIDTH-1:0] pixel_out_d;
reg [3:0]  pool_row_d;
reg [3:0]  pool_col_d;

integer i;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        row          <= 0;
        col          <= 0;
        prev_pixel   <= 0;
        pool_row     <= 0;
        pool_col     <= 0;
        pool_row_d   <= 0;
        pool_col_d   <= 0;
        pool_row_out <= 0;
        pool_col_out <= 0;
        valid_out    <= 0;
        valid_out_d  <= 0;
        pixel_out    <= 0;
        pixel_out_d  <= 0;

        for(i = 0; i < IMG_SIZE; i = i + 1)
        begin
            curr_row_buf[i] <= 0;
            prev_row_buf[i] <= 0;
        end
    end
    else if(fmap_start)
    begin
        row          <= 0;
        col          <= 0;
        prev_pixel   <= 0;
        valid_out    <= 0;
        valid_out_d  <= 0;
        pixel_out    <= 0;
        pixel_out_d  <= 0;
        pool_row_d   <= 0;
        pool_col_d   <= 0;
        pool_row_out <= 0;
        pool_col_out <= 0;

        for(i = 0; i < IMG_SIZE; i = i + 1)
        begin
            curr_row_buf[i] <= 0;
            prev_row_buf[i] <= 0;
        end
    end
    else
    begin
        // Stage 2 - output registered results
        // This fires every cycle so valid_out_d
        // propagates to valid_out one cycle later
        valid_out    <= valid_out_d;
        pixel_out    <= pixel_out_d;
        pool_row     <= pool_row_out;
        pool_col     <= pool_col_out;
        valid_out_d  <= 0;

        if(valid_in)
        begin
            // Write current pixel into curr_row_buf
            curr_row_buf[col] <= pixel_in;

            // At end of row - copy curr to prev
            // so prev_row_buf holds complete previous row
            if(col == IMG_SIZE-1)
            begin
                col <= 0;
                row <= row + 1;

                for(i = 0; i < IMG_SIZE; i = i + 1)
                    prev_row_buf[i] <= curr_row_buf[i];

                // Override last position since curr_row_buf[col]
                // non-blocking not updated yet this cycle
                prev_row_buf[IMG_SIZE-1] <= pixel_in;
            end
            else
                col <= col + 1;

            // Pool fires on odd row AND odd col
            if(row[0] && col[0])
            begin
                // prev_row_buf guaranteed to hold previous row
                // since it only updates at end of row
                a = prev_row_buf[col-1];  // prev row, col-1 ?
                b = prev_row_buf[col];    // prev row, col   ?
                c = prev_pixel;           // curr row, col-1 ?
                d = pixel_in;             // curr row, col   ?

                max1 = (a > b) ? a : b;
                max2 = (c > d) ? c : d;

                // Stage 1 - store result, fires next cycle
                pixel_out_d <= (max1 > max2) ? max1 : max2;
                valid_out_d <= 1;

                // Capture address BEFORE increment
                pool_row_out <= pool_row_d;
                pool_col_out <= pool_col_d;

                // Increment pool position
                if(pool_col_d == 13)
                begin
                    pool_col_d <= 0;
                    if(pool_row_d == 13)
                        pool_row_d <= 0;    // wraps for next kernel
                    else
                        pool_row_d <= pool_row_d + 1;
                end
                else
                    pool_col_d <= pool_col_d + 1;
            end

            prev_pixel <= pixel_in;
        end
    end
end

endmodule
