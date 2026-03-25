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


module conv_core
#(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 24
)
(
    input clk,
    input rst,
    input start,

    input signed [25*DATA_WIDTH-1:0] pixel_bus,
    input signed [25*DATA_WIDTH-1:0] weight_bus,
    input signed [DATA_WIDTH-1:0] bias,

    output reg signed [DATA_WIDTH-1:0] conv_out,
    output reg done
);

integer i;
reg signed [15:0] product [0:24];
reg signed [ACC_WIDTH-1:0] next_acc;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        conv_out <= 0;
        done <= 0;
    end
    else if(start)
    begin
        next_acc = 0;
        
        for(i = 0; i < 25; i = i + 1)
        begin
            product[i] = 
                $signed(pixel_bus[i*DATA_WIDTH +: DATA_WIDTH]) *
                $signed(weight_bus[i*DATA_WIDTH +: DATA_WIDTH]);
            next_acc = next_acc + product[i];
        end

        next_acc = next_acc + {{(ACC_WIDTH-DATA_WIDTH){bias[DATA_WIDTH-1]}}, bias};

        if (next_acc > 24'sd32767) begin        
            conv_out <= 8'h7F;
        end else if (next_acc < -24'sd32768) begin 
            conv_out <= 8'h80;
        end else begin
            conv_out <= next_acc[15:8];       
        end

        done <= 1;
    end
    else
    begin
        done <= 0;
    end
end

endmodule