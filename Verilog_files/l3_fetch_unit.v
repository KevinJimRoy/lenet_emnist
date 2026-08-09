`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 20:06:55
// Design Name: 
// Module Name: l3_fetch_unit
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


module l3_fetch_unit #(
    parameter data_width_in=8 ,
    parameter data_width_out=13
) (
    input  wire        clk,
    input  wire        rst,

    input  wire        fetch_en,
    input  wire [8:0]  pix_addr,
    input  wire [13:0] wt_addr,
    output reg         data_valid,

    output reg  [data_width_out-1:0]  pix0, pix1, pix2, pix3,
    output reg  [data_width_out-1:0]  wt0,  wt1,  wt2,  wt3,

    // pool BRAM port
    output reg  [8:0]  pool_rd_addr,
    input  wire [data_width_out-1:0]  pool_d0, pool_d1, pool_d2, pool_d3,

    // weight BRAM port
    output reg  [13:0] wt_rd_addr,
    input  wire [data_width_out-1:0]  wt_w0, wt_w1, wt_w2, wt_w3
);

    localparam F_IDLE      = 3'd0;
    localparam F_PIX_ADDR  = 3'd1;   // drive pool address
    localparam F_PIX_WAIT  = 3'd2;   // wait pool output
    localparam F_PIX_LATCH = 3'd3;   // latch pixels + drive wt address
    localparam F_WT_WAIT   = 3'd4;   // wait weight output
    localparam F_WT_LATCH  = 3'd5;   // latch weights + assert valid

    reg [2:0] fstate;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fstate       <= F_IDLE;
            data_valid   <= 0;
            pool_rd_addr <= 0;
            wt_rd_addr   <= 0;
            pix0 <= 0; pix1 <= 0; pix2 <= 0; pix3 <= 0;
            wt0  <= 0; wt1  <= 0; wt2  <= 0; wt3  <= 0;
        end else begin
            data_valid <= 0;

            case (fstate)

                F_IDLE: begin
                    if (fetch_en)
                        fstate <= F_PIX_ADDR;
                end


                F_PIX_ADDR: begin
                    pool_rd_addr <= pix_addr;
                    fstate       <= F_PIX_WAIT;
                end


                F_PIX_WAIT: begin
                    fstate <= F_PIX_LATCH;
                end


                F_PIX_LATCH: begin
                    pix0       <= pool_d0;
                    pix1       <= pool_d1;
                    pix2       <= pool_d2;
                    pix3       <= pool_d3;
                    wt_rd_addr <= wt_addr;
                    fstate     <= F_WT_WAIT;
                end


                F_WT_WAIT: begin
                    fstate <= F_WT_LATCH;
                end


                F_WT_LATCH: begin
                    wt0        <= wt_w0;
                    wt1        <= wt_w1;
                    wt2        <= wt_w2;
                    wt3        <= wt_w3;
                    data_valid <= 1;
                    fstate     <= F_IDLE;
                end

            endcase
        end
    end

endmodule