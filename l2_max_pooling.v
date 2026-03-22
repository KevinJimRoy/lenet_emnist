`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: l2_max_pooling
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


module l2_max_pooling
#(
    parameter DATA_WIDTH = 8,
    parameter FMAP_SIZE  = 10,
    parameter OUT_SIZE   = 5
)
(
    input clk,
    input rst,
    input start,

    output reg [10:0] rd_addr,
    input      [DATA_WIDTH-1:0] pixel_in,

    output reg [DATA_WIDTH-1:0] pool_out,
    output reg                  pool_valid,
    output reg [3:0]            pool_kernel,
    output reg [2:0]            pool_row,
    output reg [2:0]            pool_col,

    // Captured before increment - use these for address
    output reg [3:0]            pool_kernel_out,
    output reg [2:0]            pool_row_out,
    output reg [2:0]            pool_col_out,

    output reg done
);

reg [4:0] state;

parameter IDLE     = 0;
parameter FETCH_A  = 1;
parameter WAIT_A1  = 2;
parameter WAIT_A2  = 3;
parameter FETCH_B  = 4;
parameter WAIT_B1  = 5;
parameter WAIT_B2  = 6;
parameter FETCH_C  = 7;
parameter WAIT_C1  = 8;
parameter WAIT_C2  = 9;
parameter FETCH_D  = 10;
parameter WAIT_D1  = 11;
parameter WAIT_D2  = 12;
parameter COMPUTE  = 13;
parameter OUTPUT   = 14;
parameter NEXT_POS = 15;
parameter FINISH   = 16;

reg [DATA_WIDTH-1:0] a, b, c, d;
reg [DATA_WIDTH-1:0] max1, max2;

reg [3:0] kernel;
reg [3:0] row;
reg [3:0] col;

reg [3:0] cur_kernel;
reg [3:0] cur_row;
reg [3:0] cur_col;

// Internal counters for address tracking
reg [3:0] pool_kernel_d;
reg [2:0] pool_row_d;
reg [2:0] pool_col_d;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state           <= IDLE;
        rd_addr         <= 0;
        pool_out        <= 0;
        pool_valid      <= 0;
        pool_kernel     <= 0;
        pool_row        <= 0;
        pool_col        <= 0;
        pool_kernel_out <= 0;
        pool_row_out    <= 0;
        pool_col_out    <= 0;
        pool_kernel_d   <= 0;
        pool_row_d      <= 0;
        pool_col_d      <= 0;
        done            <= 0;
        kernel          <= 0;
        row             <= 0;
        col             <= 0;
        cur_kernel      <= 0;
        cur_row         <= 0;
        cur_col         <= 0;
        a <= 0; b <= 0; c <= 0; d <= 0;
        max1 <= 0; max2 <= 0;
    end
    else
    begin
        pool_valid <= 0;

        case(state)

        IDLE:
        begin
            done <= 0;
            if(start)
            begin
                kernel        <= 0;
                row           <= 0;
                col           <= 0;
                pool_kernel_d <= 0;
                pool_row_d    <= 0;
                pool_col_d    <= 0;
                state         <= FETCH_A;
            end
        end

        FETCH_A:
        begin
            cur_kernel <= kernel;
            cur_row    <= row;
            cur_col    <= col;
            rd_addr    <= {7'b0, kernel} * 11'd100 +
                          {7'b0, row}    * 11'd10  +
                          {7'b0, col};
            state      <= WAIT_A1;
        end

        WAIT_A1: state <= WAIT_A2;
        WAIT_A2: begin a <= pixel_in; state <= FETCH_B; end

        FETCH_B:
        begin
            rd_addr <= {7'b0, cur_kernel} * 11'd100 +
                       {7'b0, cur_row}    * 11'd10  +
                       {7'b0, cur_col}    + 11'd1;
            state   <= WAIT_B1;
        end

        WAIT_B1: state <= WAIT_B2;
        WAIT_B2: begin b <= pixel_in; state <= FETCH_C; end

        FETCH_C:
        begin
            rd_addr <= {7'b0, cur_kernel} * 11'd100          +
                       ({7'b0, cur_row}   + 11'd1) * 11'd10  +
                       {7'b0, cur_col};
            state   <= WAIT_C1;
        end

        WAIT_C1: state <= WAIT_C2;
        WAIT_C2: begin c <= pixel_in; state <= FETCH_D; end

        FETCH_D:
        begin
            rd_addr <= {7'b0, cur_kernel} * 11'd100          +
                       ({7'b0, cur_row}   + 11'd1) * 11'd10  +
                       {7'b0, cur_col}    + 11'd1;
            state   <= WAIT_D1;
        end

        WAIT_D1: state <= WAIT_D2;
        WAIT_D2: begin d <= pixel_in; state <= COMPUTE; end

        COMPUTE:
        begin
            max1  = (a > b) ? a : b;
            max2  = (c > d) ? c : d;
            state <= OUTPUT;
        end

        OUTPUT:
        begin
            pool_out <= (max1 > max2) ? max1 : max2;
            pool_valid <= 1;

            // Capture address BEFORE incrementing
            pool_kernel_out <= pool_kernel_d;
            pool_row_out    <= pool_row_d;
            pool_col_out    <= pool_col_d;

            // Update output ports for monitoring
            pool_kernel <= pool_kernel_d;
            pool_row    <= pool_row_d;
            pool_col    <= pool_col_d;

            // Now increment
            if(pool_col_d == 4)
            begin
                pool_col_d <= 0;
                if(pool_row_d == 4)
                begin
                    pool_row_d    <= 0;
                    pool_kernel_d <= pool_kernel_d + 1;
                end
                else
                    pool_row_d <= pool_row_d + 1;
            end
            else
                pool_col_d <= pool_col_d + 1;

            state <= NEXT_POS;
        end

        NEXT_POS:
        begin
            if(col < 8)
            begin
                col   <= col + 2;
                state <= FETCH_A;
            end
            else if(row < 8)
            begin
                col   <= 0;
                row   <= row + 2;
                state <= FETCH_A;
            end
            else if(kernel < 15)
            begin
                col    <= 0;
                row    <= 0;
                kernel <= kernel + 1;
                state  <= FETCH_A;
            end
            else
                state <= FINISH;
        end

        FINISH:
        begin
            pool_valid <= 0;
            done       <= 1;
        end

        endcase
    end
end

endmodule