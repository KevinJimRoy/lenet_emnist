`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2026 21:43:09
// Design Name: 
// Module Name: l3_top
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

`timescale 1ns / 1ps

module l3_top #(
    parameter DATA_WIDTH = 13,
    parameter out_dw     = 8
)(
    input  wire        clk, rst, start,
    output wire        done,           // Final pipeline done (from Argmax)
    output wire [8:0]  l3_rd_addr,
    input  wire [DATA_WIDTH-1:0]  l3_pixel_out_0, l3_pixel_out_1, l3_pixel_out_2, l3_pixel_out_3,
    input  wire [3:0]  out_rd_addr,
    output wire [out_dw-1:0]  out_dout,
    output wire [3:0]  prediction
);

    wire fetch_en, data_valid, mac_valid, wr_en, fnn_done;
    wire [8:0] pix_addr;
    wire [13:0] wt_addr, wt_rd_addr_w;
    wire [DATA_WIDTH-1:0] pix0, pix1, pix2, pix3, wt0, wt1, wt2, wt3, wt_w0, wt_w1, wt_w2, wt_w3, bias_dout;
    wire signed [2*DATA_WIDTH+3:0] mac_out;
    wire [3:0] bias_rd_addr, wr_addr, argmax_rd_addr;
    wire [7:0] wr_data;

    assign l3_rd_addr = pix_addr;

    // Standard L3 Components
    l3_weight_bram #(.DATA_WIDTH(DATA_WIDTH)) u_wt_bram (.clk(clk), .rd_addr(wt_rd_addr_w[9:0]), .w0(wt_w0), .w1(wt_w1), .w2(wt_w2), .w3(wt_w3));
    l3_bias_bram #(.DATA_WIDTH(DATA_WIDTH)) u_bias_rom (.clk(clk), .rd_addr(bias_rd_addr), .dout(bias_dout));
    l3_fetch_unit #(.data_width_out(DATA_WIDTH)) u_fetch (.clk(clk), .rst(rst), .fetch_en(fetch_en), .pix_addr(pix_addr), .wt_addr(wt_addr), .data_valid(data_valid), .pix0(pix0), .pix1(pix1), .pix2(pix2), .pix3(pix3), .wt0(wt0), .wt1(wt1), .wt2(wt2), .wt3(wt3), .pool_d0(l3_pixel_out_0), .pool_d1(l3_pixel_out_1), .pool_d2(l3_pixel_out_2), .pool_d3(l3_pixel_out_3), .wt_rd_addr(wt_rd_addr_w), .wt_w0(wt_w0), .wt_w1(wt_w1), .wt_w2(wt_w2), .wt_w3(wt_w3));
    l3_mac_unit #(.DATA_WIDTH(DATA_WIDTH)) u_mac (.clk(clk), .rst(rst), .data_valid(data_valid), .pix0(pix0), .pix1(pix1), .pix2(pix2), .pix3(pix3), .wt0(wt0), .wt1(wt1), .wt2(wt2), .wt3(wt3), .mac_valid(mac_valid), .mac_out(mac_out));

    l3_controller #(.DATA_WIDTH(DATA_WIDTH)) u_ctrl (
        .clk(clk), .rst(rst), .start(start), .done(fnn_done),
        .fetch_en(fetch_en), .pix_addr(pix_addr), .wt_addr(wt_addr), .data_valid(data_valid),
        .mac_valid(mac_valid), .mac_out(mac_out), .bias_rd_addr(bias_rd_addr),
        .bias_dout(bias_dout), .wr_en(wr_en), .wr_addr(wr_addr), .wr_data(wr_data)
    );

    // FIX: Clearer mux logic to prevent BRAM "XX" output
    reg argmax_active;
    always @(posedge clk) begin
        if (rst) argmax_active <= 0;
        else if (fnn_done) argmax_active <= 1;
        else if (done) argmax_active <= 0;
    end

    // Use Argmax address if active, otherwise use Controller for writing or TB for debug
    wire [3:0] mux_rd_addr = argmax_active ? argmax_rd_addr : (wr_en ? wr_addr : out_rd_addr);

    l3_output_bram #(.DATA_WIDTH(out_dw)) u_out_bram (
        .clk     (clk),
        .we      (wr_en),
        .wr_addr (wr_addr),
        .din     (wr_data),
        .rd_addr (mux_rd_addr),
        .dout    (out_dout)
    );

    l3_argmax u_argmax (
        .clk(clk), .rst(rst), .start(fnn_done), .done(done),
        .rd_addr(argmax_rd_addr), .rd_data(out_dout), .max_index(prediction)
    );

endmodule