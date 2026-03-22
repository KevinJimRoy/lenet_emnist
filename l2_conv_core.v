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
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
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
reg signed [15:0]       product [0:24];
reg signed [ACC_WIDTH-1:0] acc;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        conv_out <= 0;
        done     <= 0;
    end
    else if(start)
    begin
        acc = 0;

        for(i = 0; i < 25; i = i + 1)
        begin
            product[i] = $signed(pixel_bus_0[i*DATA_WIDTH +: DATA_WIDTH]) *
                         $signed(weight_bus_0[i*DATA_WIDTH +: DATA_WIDTH]);
            acc = acc + product[i];

            product[i] = $signed(pixel_bus_1[i*DATA_WIDTH +: DATA_WIDTH]) *
                         $signed(weight_bus_1[i*DATA_WIDTH +: DATA_WIDTH]);
            acc = acc + product[i];

            product[i] = $signed(pixel_bus_2[i*DATA_WIDTH +: DATA_WIDTH]) *
                         $signed(weight_bus_2[i*DATA_WIDTH +: DATA_WIDTH]);
            acc = acc + product[i];

            product[i] = $signed(pixel_bus_3[i*DATA_WIDTH +: DATA_WIDTH]) *
                         $signed(weight_bus_3[i*DATA_WIDTH +: DATA_WIDTH]);
            acc = acc + product[i];

            product[i] = $signed(pixel_bus_4[i*DATA_WIDTH +: DATA_WIDTH]) *
                         $signed(weight_bus_4[i*DATA_WIDTH +: DATA_WIDTH]);
            acc = acc + product[i];

            product[i] = $signed(pixel_bus_5[i*DATA_WIDTH +: DATA_WIDTH]) *
                         $signed(weight_bus_5[i*DATA_WIDTH +: DATA_WIDTH]);
            acc = acc + product[i];
        end

        acc = acc + {{(ACC_WIDTH-DATA_WIDTH){bias[DATA_WIDTH-1]}}, bias};

        if(acc > 32'sd32767)
            conv_out <= 8'h7F;
        else if(acc < -32'sd32768)
            conv_out <= 8'h80;
        else
            conv_out <= acc[15:8];

        done <= 1;
    end
    else if(done)   // FIX - only clear after high
        done <= 0;
end

endmodule

