`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 11:33:20
// Design Name: 
// Module Name: window_layer1
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

module layer1_controller(

    input clk,
    input rst,
    input start,

    input weights_ready,
    input window_valid,
    input conv_done,

    output reg weight_load_start,
    output reg window_start,
    output reg conv_start,
    output reg out_write_en,

    output reg [2:0] kernel_id,
    output reg [5:0] base_row,
    output reg [5:0] base_col,

    output reg [12:0] out_addr,
    output reg done
);

reg [3:0] state;

parameter IDLE          = 0;
parameter LOAD_WEIGHTS  = 1;
parameter WAIT_WEIGHTS  = 2;
parameter GEN_WINDOW    = 3;
parameter WAIT_WINDOW   = 4;
parameter START_CONV    = 5;
parameter WAIT_CONV     = 6;
parameter WRITE_OUTPUT  = 7;
parameter NEXT_WINDOW   = 8;
parameter NEXT_KERNEL   = 9;
parameter FINISH        = 10;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state <= IDLE;
        kernel_id <= 0;
        base_row <= 0;
        base_col <= 0;
        done <= 0;
    end
    else
    begin
        case(state)

        IDLE:
            if(start)
                state <= LOAD_WEIGHTS;

        LOAD_WEIGHTS:
        begin
            weight_load_start <= 1;
            state <= WAIT_WEIGHTS;
        end

        WAIT_WEIGHTS:
        begin
            weight_load_start <= 0;
            if(weights_ready)
                state <= GEN_WINDOW;
        end

        GEN_WINDOW:
        begin
            window_start <= 1;
            state <= WAIT_WINDOW;
        end

        WAIT_WINDOW:
        begin
            window_start <= 0;
            if(window_valid)
                state <= START_CONV;
        end

        START_CONV:
        begin
            conv_start <= 1;
            state <= WAIT_CONV;
        end

        WAIT_CONV:
        begin
            conv_start <= 0;
            if(conv_done)
                state <= WRITE_OUTPUT;
        end

        WRITE_OUTPUT:
        begin
            out_write_en <= 1;
            out_addr <= kernel_id*196 + (base_row>>1)*14 + (base_col>>1);
            state <= NEXT_WINDOW;
        end

        NEXT_WINDOW:
        begin
            out_write_en <= 0;

            if(base_col < 27)
            begin
                base_col <= base_col + 1;
                state <= GEN_WINDOW;
            end
            else if(base_row < 27)
            begin
                base_col <= 0;
                base_row <= base_row + 1;
                state <= GEN_WINDOW;
            end
            else
                state <= NEXT_KERNEL;
        end

        NEXT_KERNEL:
        begin
            base_row <= 0;
            base_col <= 0;

            if(kernel_id < 5)
            begin
                kernel_id <= kernel_id + 1;
                state <= LOAD_WEIGHTS;
            end
            else
                state <= FINISH;
        end

        FINISH:
            done <= 1;

        endcase
    end
end

endmodule
