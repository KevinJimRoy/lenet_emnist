`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: l2_fmap_reader
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


module l2_fmap_reader
(
    input clk,
    input rst,
    input start,

    output reg [12:0] rd_addr,
    input      [7:0]  pixel_in,

    output reg [7:0]  pixel_out,
    output reg [12:0] pixel_addr_out,
    output reg        pixel_valid,
    output reg        done
);

reg [3:0] state;

parameter IDLE      = 0;
parameter READ_ADDR = 1;
parameter WAIT1     = 2;
parameter WAIT2     = 3;
parameter CAPTURE   = 4;
parameter FINISH    = 5;

reg [2:0]  kernel_id;
reg [3:0]  row;
reg [3:0]  col;
reg [12:0] current_addr;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state           <= IDLE;
        rd_addr         <= 0;
        pixel_out       <= 0;
        pixel_valid     <= 0;
        done            <= 0;
        kernel_id       <= 0;
        row             <= 0;
        col             <= 0;
        current_addr    <= 0;
    end
    else
    begin
        case(state)

        IDLE:
        begin
            pixel_valid <= 0;
            done        <= 0;
            if(start)
            begin
                kernel_id <= 0;
                row       <= 0;
                col       <= 0;
                state     <= READ_ADDR;
            end
        end

        READ_ADDR:
        begin
            current_addr <= kernel_id * 196 + row * 14 + col;
            rd_addr      <= kernel_id * 196 + row * 14 + col;
            // do NOT clear pixel_valid here
            // let it stay high one more cycle so BRAM write completes
            state        <= WAIT1;
        end

        WAIT1:
        begin
            pixel_valid <= 0;   // clear here instead of READ_ADDR
            state       <= WAIT2;
        end

        WAIT2:
            state <= CAPTURE;

        CAPTURE:
        begin
            pixel_out      <= pixel_in;
            pixel_addr_out <= current_addr;
            pixel_valid    <= 1;

            if(col < 13)
            begin
                col   <= col + 1;
                state <= READ_ADDR;
            end
            else if(row < 13)
            begin
                col   <= 0;
                row   <= row + 1;
                state <= READ_ADDR;
            end
            else if(kernel_id < 5)
            begin
                col       <= 0;
                row       <= 0;
                kernel_id <= kernel_id + 1;
                state     <= READ_ADDR;
            end
            else
                state <= FINISH;
        end

        FINISH:
        begin
            pixel_valid <= 0;
            done        <= 1;
            state       <= IDLE;
        end

        endcase
    end
end

endmodule
