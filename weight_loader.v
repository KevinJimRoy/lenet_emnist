`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2026 13:52:03
// Design Name: 
// Module Name: conv_core
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


module weight_loader
#(
    parameter DATA_WIDTH = 8
)
(
    input clk,
    input rst,
    input start,
    input [2:0] kernel_id,

    input signed [DATA_WIDTH-1:0] weight_in,

    output reg [7:0] bram_addr,
    output reg weights_ready,

    output reg [25*DATA_WIDTH-1:0] weights_bus
);

reg [4:0] addr_counter;
reg [4:0] data_counter;
reg loading;

reg read_active_1;
reg read_active_2;

wire [7:0] base_addr;
assign base_addr = kernel_id * 8'd25;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        addr_counter <= 0;
        data_counter <= 0;
        bram_addr <= 0;
        loading <= 0;
        read_active_1 <= 0;
        read_active_2 <= 0;
        weights_ready <= 0;
        weights_bus <= 0;
    end
    else
    begin
        weights_ready <= 0;
        
        if(start && !loading)
        begin
            loading <= 1;
            addr_counter <= 0;
            data_counter <= 0;
            read_active_1 <= 0;
            read_active_2 <= 0;
        end
        else if(loading)
        begin
            if (addr_counter < 25)
            begin
                bram_addr <= base_addr + addr_counter;
                addr_counter <= addr_counter + 1;
                read_active_1 <= 1;
            end
            else
            begin
                read_active_1 <= 0;
            end

            read_active_2 <= read_active_1;

            if (read_active_2)
            begin
                weights_bus[data_counter*DATA_WIDTH +: DATA_WIDTH] <= weight_in;
                data_counter <= data_counter + 1;
                
                if(data_counter == 24)
                begin
                    loading <= 0;
                    weights_ready <= 1;
                end
            end
        end
    end
end

endmodule