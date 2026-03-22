`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: module l2_weight_loader
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


module l2_weight_loader
#(
    parameter DATA_WIDTH = 8
)
(
    input clk,
    input rst,
    input start,

    input [3:0] kernel_id,        // 0 to 15

    input signed [DATA_WIDTH-1:0] weight_in,

    output reg [11:0]              bram_addr,
    output reg                     weights_ready,

    // 6 weight buses, one per input fmap
    output reg [25*DATA_WIDTH-1:0] weight_bus_0,
    output reg [25*DATA_WIDTH-1:0] weight_bus_1,
    output reg [25*DATA_WIDTH-1:0] weight_bus_2,
    output reg [25*DATA_WIDTH-1:0] weight_bus_3,
    output reg [25*DATA_WIDTH-1:0] weight_bus_4,
    output reg [25*DATA_WIDTH-1:0] weight_bus_5
);

// Total weights per kernel = 6 fmaps * 25 = 150
parameter TOTAL_WEIGHTS = 150;

reg [7:0]  addr_counter;
reg [7:0]  data_counter;
reg        loading;
reg        read_active_1;
reg        read_active_2;

wire [11:0] base_addr;
assign base_addr = kernel_id * 150;  // each kernel has 150 weights

reg [2:0] current_fmap;
reg [4:0] current_weight;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        addr_counter  <= 0;
        data_counter  <= 0;
        bram_addr     <= 0;
        loading       <= 0;
        read_active_1 <= 0;
        read_active_2 <= 0;
        weights_ready <= 0;
        weight_bus_0  <= 0;
        weight_bus_1  <= 0;
        weight_bus_2  <= 0;
        weight_bus_3  <= 0;
        weight_bus_4  <= 0;
        weight_bus_5  <= 0;
    end
    else
    begin
        weights_ready <= 0;

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
            if(addr_counter < TOTAL_WEIGHTS)
            begin
                bram_addr     <= base_addr + addr_counter;
                addr_counter  <= addr_counter + 1;
                read_active_1 <= 1;
            end
            else
                read_active_1 <= 0;

            read_active_2 <= read_active_1;

            if(read_active_2)
            begin
                current_fmap   = data_counter / 25;
                current_weight = data_counter % 25;

                case(current_fmap)
                    0: weight_bus_0[current_weight*DATA_WIDTH +: DATA_WIDTH] <= weight_in;
                    1: weight_bus_1[current_weight*DATA_WIDTH +: DATA_WIDTH] <= weight_in;
                    2: weight_bus_2[current_weight*DATA_WIDTH +: DATA_WIDTH] <= weight_in;
                    3: weight_bus_3[current_weight*DATA_WIDTH +: DATA_WIDTH] <= weight_in;
                    4: weight_bus_4[current_weight*DATA_WIDTH +: DATA_WIDTH] <= weight_in;
                    5: weight_bus_5[current_weight*DATA_WIDTH +: DATA_WIDTH] <= weight_in;
                endcase

                data_counter <= data_counter + 1;

                if(data_counter == TOTAL_WEIGHTS - 1)
                begin
                    loading       <= 0;
                    weights_ready <= 1;
                end
            end
        end
    end
end

endmodule
