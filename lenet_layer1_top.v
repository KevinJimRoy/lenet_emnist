`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2026 12:56:06
// Design Name: 
// Module Name: bram_load
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

module layer1_top(

    input clk,
    input rst,
    input start,

    output done
);

wire weight_load_start;
wire window_start;
wire conv_start;
wire out_write_en;

wire [2:0] kernel_id;
wire [5:0] base_row;
wire [5:0] base_col;

wire weights_ready;
wire window_valid;
wire conv_done;

wire [199:0] pixel_bus;
wire [199:0] weight_bus;

wire [7:0] pixel_data;
wire [7:0] weight_data;

wire signed [7:0] bias_data;
wire signed [7:0] conv_out;
wire [7:0] relu_out;

wire [7:0] pool_out;
wire pool_valid;

wire [3:0] pool_row;
wire [3:0] pool_col;

wire fmap_start;

wire [12:0] pool_addr;

wire [9:0] pixel_addr;
wire [7:0] weight_addr;

assign fmap_start = weight_load_start;

assign pool_addr = kernel_id*196 + pool_row*14 + pool_col;

/////////////////////////////////////////////////
// Controller
/////////////////////////////////////////////////

layer1_controller controller(

    .clk(clk),
    .rst(rst),
    .start(start),

    .weights_ready(weights_ready),
    .window_valid(window_valid),
    .conv_done(conv_done),

    .weight_load_start(weight_load_start),
    .window_start(window_start),
    .conv_start(conv_start),
    .out_write_en(out_write_en),

    .kernel_id(kernel_id),
    .base_row(base_row),
    .base_col(base_col),

    .done(done)
);

/////////////////////////////////////////////////
// IMAGE BRAM
/////////////////////////////////////////////////

image_bram image_bram_inst(

    .clk(clk),
    .addr(pixel_addr),
    .pixel_out(pixel_data)

);

/////////////////////////////////////////////////
// SLIDING WINDOW
/////////////////////////////////////////////////

sliding_window sliding_window_inst(

    .clk(clk),
    .rst(rst),
    .start(window_start),

    .base_row(base_row),
    .base_col(base_col),

    .pixel_in(pixel_data),
    .pixel_addr(pixel_addr),

    .pixel_bus(pixel_bus),
    .window_valid(window_valid)

);

/////////////////////////////////////////////////
// WEIGHTS
/////////////////////////////////////////////////

weight_loader weight_loader_inst(

    .clk(clk),
    .rst(rst),
    .start(weight_load_start),
    .kernel_id(kernel_id),

    .weight_in(weight_data),

    .bram_addr(weight_addr),
    .weights_ready(weights_ready),

    .weights_bus(weight_bus)

);

weight_bram weight_bram_inst(

    .clk(clk),
    .addr(weight_addr),
    .weight_out(weight_data)

);

bias_bram bias_bram_inst(

    .clk(clk),
    .addr(kernel_id),
    .bias_out(bias_data)

);

/////////////////////////////////////////////////
// CONVOLUTION
/////////////////////////////////////////////////

conv_core conv_core_inst(

    .clk(clk),
    .rst(rst),
    .start(conv_start),

    .pixel_bus(pixel_bus),
    .weight_bus(weight_bus),
    .bias(bias_data),

    .conv_out(conv_out),
    .done(conv_done)

);

/////////////////////////////////////////////////
// RELU
/////////////////////////////////////////////////

relu relu_inst(

    .din(conv_out),
    .dout(relu_out)

);

/////////////////////////////////////////////////
// MAXPOOL
/////////////////////////////////////////////////

max_pooling maxpool_inst(

    .clk(clk),
    .rst(rst),

    .valid_in(out_write_en),
    .fmap_start(fmap_start),

    .pixel_in(relu_out),

    .valid_out(pool_valid),
    .pixel_out(pool_out),

    .pool_row(pool_row),
    .pool_col(pool_col)

);

/////////////////////////////////////////////////
// OUTPUT BRAM
/////////////////////////////////////////////////

output_bram output_bram_inst(

    .clk(clk),
    .we(pool_valid),
    .addr(pool_addr),
    .din(pool_out)

);

endmodule