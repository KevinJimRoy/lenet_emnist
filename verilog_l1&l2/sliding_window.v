`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 20:38:12
// Design Name: 
// Module Name: sliding_window
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


module sliding_window
#(
    parameter DATA_WIDTH = 8
)
(
    input clk,
    input rst,
    input start,

    input [5:0] base_row,
    input [5:0] base_col,

    input [DATA_WIDTH-1:0] pixel_in,

    output reg [9:0] pixel_addr,
    output reg [25*DATA_WIDTH-1:0] pixel_bus,

    output reg window_valid
);

reg [4:0] addr_counter;
reg [4:0] data_counter;
reg loading;

reg read_active_1;
reg read_active_2;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        addr_counter  <= 0;
        data_counter  <= 0;
        pixel_addr    <= 0;
        loading       <= 0;
        read_active_1 <= 0;
        read_active_2 <= 0;
        window_valid  <= 0;
        pixel_bus     <= 0;
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
            if(addr_counter < 25)
            begin
                pixel_addr    <= (base_row + (addr_counter / 5)) * 32 +
                                 (base_col + (addr_counter % 5));
                addr_counter  <= addr_counter + 1;
                read_active_1 <= 1;
            end
            else
                read_active_1 <= 0;

            read_active_2 <= read_active_1;

            if(read_active_2)
            begin
                pixel_bus[data_counter*DATA_WIDTH +: DATA_WIDTH] <= pixel_in;
                data_counter <= data_counter + 1;

                if(data_counter == 24)
                begin
                    loading      <= 0;
                    window_valid <= 1;
                end
            end
        end
    end
end

endmodule