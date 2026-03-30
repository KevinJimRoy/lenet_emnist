`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: l2_sliding_window
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


module l2_sliding_window
#(
    parameter DATA_WIDTH = 8,
    parameter FMAP_SIZE  = 14,
    parameter KERNEL_SIZE = 5,
    parameter TOTAL_PIXELS = 150
)
(
    input clk,
    input rst,
    input start,

    input [3:0] base_row,
    input [3:0] base_col,

    output reg [12:0]              rd_addr,
    input      [DATA_WIDTH-1:0]    pixel_in,

    output reg [KERNEL_SIZE*KERNEL_SIZE*DATA_WIDTH-1:0] pixel_bus_0,
    output reg [KERNEL_SIZE*KERNEL_SIZE*DATA_WIDTH-1:0] pixel_bus_1,
    output reg [KERNEL_SIZE*KERNEL_SIZE*DATA_WIDTH-1:0] pixel_bus_2,
    output reg [KERNEL_SIZE*KERNEL_SIZE*DATA_WIDTH-1:0] pixel_bus_3,
    output reg [KERNEL_SIZE*KERNEL_SIZE*DATA_WIDTH-1:0] pixel_bus_4,
    output reg [KERNEL_SIZE*KERNEL_SIZE*DATA_WIDTH-1:0] pixel_bus_5,

    output reg window_valid
);



reg [7:0]  addr_counter;
reg [7:0]  data_counter;
reg        loading;
reg        read_active_1;
reg        read_active_2;

reg [2:0]  current_fmap;   
reg [4:0]  current_pixel;  

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        addr_counter  <= 0;
        data_counter  <= 0;
        rd_addr       <= 0;
        loading       <= 0;
        read_active_1 <= 0;
        read_active_2 <= 0;
        window_valid  <= 0;
        pixel_bus_0   <= 0;
        pixel_bus_1   <= 0;
        pixel_bus_2   <= 0;
        pixel_bus_3   <= 0;
        pixel_bus_4   <= 0;
        pixel_bus_5   <= 0;
    end
    else
    begin
        window_valid <= 0;

        if(start && !loading)
        begin
            loading       <= 1;
            addr_counter  <= 0;
            data_counter  <= 0;
            read_active_1 <= 0;
            read_active_2 <= 0;
        end
        else if(loading)
        begin
            if(addr_counter < TOTAL_PIXELS)
            begin
               
                current_fmap  = addr_counter / 25;
                current_pixel = addr_counter % 25;

                rd_addr <= current_fmap * 196 +
                           (base_row + current_pixel / KERNEL_SIZE) * FMAP_SIZE +
                           (base_col + current_pixel % KERNEL_SIZE);

                addr_counter  <= addr_counter + 1;
                read_active_1 <= 1;
            end
            else
                read_active_1 <= 0;

            read_active_2 <= read_active_1;

            if(read_active_2)
            begin
                current_fmap  = data_counter / 25;
                current_pixel = data_counter % 25;

                case(current_fmap)
                    0: pixel_bus_0[current_pixel*DATA_WIDTH +: DATA_WIDTH] <= pixel_in;
                    1: pixel_bus_1[current_pixel*DATA_WIDTH +: DATA_WIDTH] <= pixel_in;
                    2: pixel_bus_2[current_pixel*DATA_WIDTH +: DATA_WIDTH] <= pixel_in;
                    3: pixel_bus_3[current_pixel*DATA_WIDTH +: DATA_WIDTH] <= pixel_in;
                    4: pixel_bus_4[current_pixel*DATA_WIDTH +: DATA_WIDTH] <= pixel_in;
                    5: pixel_bus_5[current_pixel*DATA_WIDTH +: DATA_WIDTH] <= pixel_in;
                endcase

                data_counter <= data_counter + 1;

                if(data_counter == TOTAL_PIXELS - 1)
                begin
                    loading      <= 0;
                    window_valid <= 1;
                end
            end
        end
    end
end

endmodule
