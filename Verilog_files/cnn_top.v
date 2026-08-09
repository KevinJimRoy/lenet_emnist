`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: cnn_top
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

module cnn_top #(
    parameter new_width = 13 
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,

    output wire [3:0]  prediction,  
    output wire        pipeline_done
);

    // ---------------- INTERNAL SIGNALS ----------------

    wire [3:0] out_rd_addr = 4'd0;
    wire [7:0] l3_final_out;

    wire [12:0] l2_gen_rd_addr;
    wire [8:0]  l3_gen_rd_addr;

    wire [12:0] muxed_l1_rd_addr = l2_gen_rd_addr;
    wire [8:0]  muxed_l2_rd_addr = l3_gen_rd_addr;
    wire [3:0]  muxed_l3_rd_addr = out_rd_addr;

    wire [new_width-1:0] l2_pixel_in;
    wire [new_width-1:0] l3_pix_0, l3_pix_1, l3_pix_2, l3_pix_3;

    wire l1_done, l2_done;

    // ---------------- ORIGINAL WORKING CONTROL ----------------

reg l2_started, l3_started;
wire l2_start_pulse = (l1_done && !l2_started);
wire l3_start_pulse = (l2_done && !l3_started); // Now a 1-cycle pulse!

always @(posedge clk or posedge rst) begin
    if (rst) begin
        l2_started <= 0;
        l3_started <= 0;
    end else begin
        if (l1_done) l2_started <= 1;
        if (l2_done) l3_started <= 1;
    end
end

    // ---------------- LAYER 1 ----------------

    layer1_top layer1_inst (
        .clk(clk), 
        .rst(rst), 
        .start(start),
        .l2_rd_addr(muxed_l1_rd_addr), 
        .l2_pixel_out(l2_pixel_in), 
        .done(l1_done)
    );

    // ---------------- LAYER 2 ----------------

    layer2_top layer2_inst (
        .clk(clk), 
        .rst(rst), 
        .start(l2_start_pulse),   // â†? ORIGINAL STYLE
        .l1_rd_addr(l2_gen_rd_addr), 
        .l1_pixel_in(l2_pixel_in),
        .l3_rd_addr(muxed_l2_rd_addr),
        .l3_pixel_out_0(l3_pix_0), 
        .l3_pixel_out_1(l3_pix_1),
        .l3_pixel_out_2(l3_pix_2), 
        .l3_pixel_out_3(l3_pix_3),
        .done(l2_done)
    );

    // ---------------- LAYER 3 ----------------

    l3_top u_layer3 (
        .clk(clk), 
        .rst(rst), 
        .start(l3_start_pulse),
        .l3_rd_addr(l3_gen_rd_addr),
        .l3_pixel_out_0(l3_pix_0), 
        .l3_pixel_out_1(l3_pix_1),
        .l3_pixel_out_2(l3_pix_2), 
        .l3_pixel_out_3(l3_pix_3),
        .out_rd_addr(muxed_l3_rd_addr), 
        .out_dout(l3_final_out),
        .prediction(prediction), 
        .done(pipeline_done)
    );

endmodule