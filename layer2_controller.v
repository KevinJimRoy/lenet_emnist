`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: layer2_controller
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


module layer2_controller
(
    input clk,
    input rst,
    input start,

    input fmap_read_done,
    input weights_ready,
    input window_valid,
    input conv_done,
    input pool_done,

    output reg fmap_read_start,
    output reg weight_load_start,
    output reg window_start,
    output reg conv_start,
    output reg pool_start,
    output reg out_write_en,

    output reg [3:0] kernel_id,
    output reg [3:0] base_row,
    output reg [3:0] base_col,

    output reg [10:0] out_addr,
    output reg done
);

reg [4:0] state;

parameter IDLE          = 0;
parameter READ_FMAPS    = 1;
parameter WAIT_FMAPS    = 2;
parameter LOAD_WEIGHTS  = 3;
parameter WAIT_WEIGHTS  = 4;
parameter GEN_WINDOW    = 5;
parameter WAIT_WINDOW   = 6;
parameter START_CONV    = 7;
parameter WAIT_CONV     = 8;
parameter WRITE_OUTPUT  = 9;
parameter WRITE_OUTPUT2 = 10;
parameter NEXT_WINDOW   = 11;
parameter NEXT_KERNEL   = 12;
parameter START_POOL    = 13;
parameter WAIT_POOL     = 14;
parameter FINISH        = 15;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state             <= IDLE;
        kernel_id         <= 0;
        base_row          <= 0;
        base_col          <= 0;
        done              <= 0;
        fmap_read_start   <= 0;
        weight_load_start <= 0;
        window_start      <= 0;
        conv_start        <= 0;
        pool_start        <= 0;
        out_write_en      <= 0;
        out_addr          <= 0;
    end
    else
    begin
        case(state)

        IDLE:
            if(start)
                state <= READ_FMAPS;

        READ_FMAPS:
        begin
            fmap_read_start <= 1;
            state           <= WAIT_FMAPS;
        end

        WAIT_FMAPS:
        begin
            fmap_read_start <= 0;
            if(fmap_read_done)
            begin
                kernel_id <= 0;
                state     <= LOAD_WEIGHTS;
            end
        end

        LOAD_WEIGHTS:
        begin
            weight_load_start <= 1;
            state             <= WAIT_WEIGHTS;
        end

        WAIT_WEIGHTS:
        begin
            weight_load_start <= 0;
            if(weights_ready)
            begin
                base_row <= 0;
                base_col <= 0;
                state    <= GEN_WINDOW;
            end
        end

        GEN_WINDOW:
        begin
            window_start <= 1;
            state        <= WAIT_WINDOW;
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
            state      <= WAIT_CONV;
        end

        WAIT_CONV:
        begin
            conv_start <= 0;
            if(conv_done)
                state <= WRITE_OUTPUT;
        end

        // Stage 1 - set address, de-assert we
        WRITE_OUTPUT:
        begin
            out_write_en <= 0;
            out_addr     <= {7'b0, kernel_id} * 11'd100 +
                            {7'b0, base_row}  * 11'd10  +
                            {7'b0, base_col};
            state        <= WRITE_OUTPUT2;
        end

        // Stage 2 - assert we for exactly 1 cycle, address stable
        WRITE_OUTPUT2:
        begin
            out_write_en <= 1;
            state        <= NEXT_WINDOW;
        end

        NEXT_WINDOW:
        begin
            out_write_en <= 0;

            if(base_col < 9)
            begin
                base_col <= base_col + 1;
                state    <= GEN_WINDOW;
            end
            else if(base_row < 9)
            begin
                base_col <= 0;
                base_row <= base_row + 1;
                state    <= GEN_WINDOW;
            end
            else
                state <= NEXT_KERNEL;
        end

        NEXT_KERNEL:
        begin
            base_row <= 0;
            base_col <= 0;

            if(kernel_id < 15)
            begin
                kernel_id <= kernel_id + 1;
                state     <= LOAD_WEIGHTS;
            end
            else
                state <= START_POOL;
        end

        START_POOL:
        begin
            pool_start <= 1;
            state      <= WAIT_POOL;
        end

        WAIT_POOL:
        begin
            pool_start <= 0;
            if(pool_done)
                state <= FINISH;
        end

        FINISH:
            done <= 1;

        endcase
    end
end

endmodule