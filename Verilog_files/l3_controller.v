`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 23:52:52
// Design Name: 
// Module Name: l3_controller
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


module l3_controller #(
    parameter DATA_WIDTH   = 13,
    parameter N_INPUTS     = 400,
    parameter N_NEURONS    = 10,       
    parameter ACCUM_WIDTH  = 38, 
    parameter Q_FRAC_BITS  = 10,
    parameter NEW_DATA_WIDTH = 8
)(
    input  wire        clk, rst, start,
    output wire        done,
    output reg         fetch_en,
    output reg  [8:0]  pix_addr,
    output reg  [13:0] wt_addr,
    input  wire        data_valid, mac_valid,
    input  wire signed [2*DATA_WIDTH+3:0] mac_out,
    output reg  [3:0]  bias_rd_addr, 
    input  wire signed [DATA_WIDTH-1:0] bias_dout,
    output reg         wr_en,
    output reg  [3:0]  wr_addr,       
    output reg  [NEW_DATA_WIDTH-1:0] wr_data
);

    localparam S_IDLE=0, S_FETCH=1, S_WAIT_MAC=2, S_ACCUM=3, S_BIAS_REQ=4, S_BIAS_WAT=5, S_BIAS_ADD=6, S_QUANT=7, S_WRITE=8;
    reg [3:0] state;
    reg [3:0] neuron_idx;
    reg [6:0] input_idx;
    reg signed [ACCUM_WIDTH-1:0] accum;
    reg done_r;
    assign done = done_r;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE; neuron_idx <= 0; input_idx <= 0; accum <= 0; fetch_en <= 0;
            bias_rd_addr <= 0; wr_en <= 0; done_r <= 0;
        end else begin
            fetch_en <= 0; wr_en <= 0; done_r <= 0;
            case (state)
                S_IDLE: if (start) begin neuron_idx <= 0; input_idx <= 0; accum <= 0; state <= S_FETCH; end
                S_FETCH: begin
                    pix_addr <= {input_idx, 2'b00};
                    wt_addr  <= (neuron_idx * 7'd100) + {7'b0, input_idx};
                    fetch_en <= 1; state <= S_WAIT_MAC;
                end
                S_WAIT_MAC: if (mac_valid) state <= S_ACCUM;
                S_ACCUM: begin
                    accum <= accum + {{(ACCUM_WIDTH-(2*DATA_WIDTH+4)){mac_out[2*DATA_WIDTH+3]}}, mac_out};
                    if (input_idx == 99) state <= S_BIAS_REQ;
                    else begin input_idx <= input_idx + 1; state <= S_FETCH; end
                end
                S_BIAS_REQ: begin bias_rd_addr <= neuron_idx; state <= S_BIAS_WAT; end
                S_BIAS_WAT: state <= S_BIAS_ADD;
                S_BIAS_ADD: begin
                    accum <= accum + ({{(ACCUM_WIDTH-DATA_WIDTH){bias_dout[DATA_WIDTH-1]}}, bias_dout} <<< 10);
                    state <= S_QUANT;
                end
                S_QUANT: begin
                    if (!accum[ACCUM_WIDTH-1] && accum[ACCUM_WIDTH-2:22] > 0) wr_data <= 8'sh7F;
                    else if (accum[ACCUM_WIDTH-1] && accum[ACCUM_WIDTH-2:22] < 15'h7FFF) wr_data <= 8'sh80;
                    else wr_data <= accum[22:15];
                    state <= S_WRITE;
                end
                S_WRITE: begin
                    wr_en <= 1; wr_addr <= neuron_idx;
                    if (neuron_idx == 9) begin done_r <= 1; state <= S_IDLE; end
                    else begin neuron_idx <= neuron_idx + 1; input_idx <= 0; accum <= 0; state <= S_FETCH; end
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule