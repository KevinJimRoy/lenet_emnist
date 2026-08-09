`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: l2_conv_core
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


module l2_conv_core
#(
    parameter DATA_WIDTH = 13,
    parameter ACC_WIDTH  = 36 // multplication would be 26 in the format of 6.20 and as we have 150 additions the required bits would be log 256 which is 8 just for safety well take to so 26 +10 which is 16.20
)
(
    input clk,
    input rst,
    input start,

    input signed [25*DATA_WIDTH-1:0] pixel_bus_0,
    input signed [25*DATA_WIDTH-1:0] pixel_bus_1,
    input signed [25*DATA_WIDTH-1:0] pixel_bus_2,
    input signed [25*DATA_WIDTH-1:0] pixel_bus_3,
    input signed [25*DATA_WIDTH-1:0] pixel_bus_4,
    input signed [25*DATA_WIDTH-1:0] pixel_bus_5,

    input signed [25*DATA_WIDTH-1:0] weight_bus_0,
    input signed [25*DATA_WIDTH-1:0] weight_bus_1,
    input signed [25*DATA_WIDTH-1:0] weight_bus_2,
    input signed [25*DATA_WIDTH-1:0] weight_bus_3,
    input signed [25*DATA_WIDTH-1:0] weight_bus_4,
    input signed [25*DATA_WIDTH-1:0] weight_bus_5,

    input signed [DATA_WIDTH-1:0] bias,

    output reg signed [DATA_WIDTH-1:0] conv_out,
    output reg done
);

integer i;

reg signed [ACC_WIDTH-1:0] acc_next;

reg signed [2*DATA_WIDTH -1:0] mac_0, mac_1, mac_2, mac_3, mac_4, mac_5;

always @(*) begin
    acc_next = 0;

    for(i = 0; i < 25; i = i + 1) begin
        mac_0 = $signed(pixel_bus_0[i*DATA_WIDTH +: DATA_WIDTH]) *
                $signed(weight_bus_0[i*DATA_WIDTH +: DATA_WIDTH]);

        mac_1 = $signed(pixel_bus_1[i*DATA_WIDTH +: DATA_WIDTH]) *
                $signed(weight_bus_1[i*DATA_WIDTH +: DATA_WIDTH]);

        mac_2 = $signed(pixel_bus_2[i*DATA_WIDTH +: DATA_WIDTH]) *
                $signed(weight_bus_2[i*DATA_WIDTH +: DATA_WIDTH]);

        mac_3 = $signed(pixel_bus_3[i*DATA_WIDTH +: DATA_WIDTH]) *
                $signed(weight_bus_3[i*DATA_WIDTH +: DATA_WIDTH]);

        mac_4 = $signed(pixel_bus_4[i*DATA_WIDTH +: DATA_WIDTH]) *
                $signed(weight_bus_4[i*DATA_WIDTH +: DATA_WIDTH]);

        mac_5 = $signed(pixel_bus_5[i*DATA_WIDTH +: DATA_WIDTH]) *
                $signed(weight_bus_5[i*DATA_WIDTH +: DATA_WIDTH]);

        acc_next = acc_next +
            {{(ACC_WIDTH-2*DATA_WIDTH){mac_0[2*DATA_WIDTH -1]}}, mac_0} +
            {{(ACC_WIDTH-2*DATA_WIDTH){mac_1[2*DATA_WIDTH -1]}}, mac_1} +
            {{(ACC_WIDTH-2*DATA_WIDTH){mac_2[2*DATA_WIDTH -1]}}, mac_2} +
            {{(ACC_WIDTH-2*DATA_WIDTH){mac_3[2*DATA_WIDTH -1]}}, mac_3} +
            {{(ACC_WIDTH-2*DATA_WIDTH){mac_4[2*DATA_WIDTH -1]}}, mac_4} +
            {{(ACC_WIDTH-2*DATA_WIDTH){mac_5[2*DATA_WIDTH -1]}}, mac_5};
    end

    acc_next = acc_next + {{(ACC_WIDTH-DATA_WIDTH-10){bias[DATA_WIDTH-1]}}, bias, 10'b0};
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        conv_out <= 0;
        done     <= 0;
    end
    else if (start) begin
        if (acc_next[ACC_WIDTH-1] == 1)
            conv_out <= 0;
        else if (acc_next[22] ==1)
            conv_out <= 13'hfff;
        else
            conv_out <= acc_next[22:10] ;  //from  Q16.20 fromat to 3.10 format

        done <= 1;
    end
    else begin
        done <= 0;
    end
end

endmodule

