`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 15:57:39
// Design Name: 
// Module Name: layer2_top
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


module layer2_top
(
    input clk,
    input rst,
    input start,

    output [12:0] l1_rd_addr,
    input  [7:0]  l1_pixel_in,

    input  [8:0] l3_rd_addr,
    output [7:0] l3_pixel_out,

    output done
);

wire fmap_read_done;
wire weights_ready;
wire window_valid;
wire conv_done;
wire pool_done;

wire fmap_read_start;
wire weight_load_start;
wire window_start;
wire conv_start;
wire pool_start;
wire out_write_en;

wire [3:0]  kernel_id;
wire [3:0]  base_row;
wire [3:0]  base_col;
wire [10:0] out_addr;

wire [7:0]  fmap_pixel_to_bram;
wire [12:0] fmap_addr_to_bram;
wire        fmap_we;
wire [12:0] fmap_rd_addr;
wire [7:0]  fmap_bram_out;

wire [11:0] weight_rd_addr;
wire signed [7:0] weight_data;
wire signed [7:0] bias_data;

wire [199:0] pixel_bus_0, pixel_bus_1, pixel_bus_2;
wire [199:0] pixel_bus_3, pixel_bus_4, pixel_bus_5;

wire [199:0] weight_bus_0, weight_bus_1, weight_bus_2;
wire [199:0] weight_bus_3, weight_bus_4, weight_bus_5;

wire signed [7:0] conv_out;
wire [7:0]        relu_out;

wire [10:0] pool_rd_addr;
wire [7:0]  pool_pixel_in;
wire [7:0]  pool_out;
wire        pool_valid;
wire [3:0]  pool_kernel;
wire [2:0]  pool_row;
wire [2:0]  pool_col;

// Captured before increment
wire [3:0]  pool_kernel_out;
wire [2:0]  pool_row_out;
wire [2:0]  pool_col_out;

// Registered pool signals
reg [8:0]  pool_wr_addr_r;
reg [7:0]  pool_out_r;
reg        pool_valid_r;

always @(posedge clk)
begin
    pool_valid_r   <= pool_valid;
    pool_out_r     <= pool_out;
    pool_wr_addr_r <= {5'b0, pool_kernel_out} * 9'd25 +
                      {6'b0, pool_row_out}    * 9'd5  +
                      {6'b0, pool_col_out};
end

/////////////////////////////////////////////////
// Controller
/////////////////////////////////////////////////
layer2_controller controller(
    .clk(clk), .rst(rst), .start(start),
    .fmap_read_done(fmap_read_done),
    .weights_ready(weights_ready),
    .window_valid(window_valid),
    .conv_done(conv_done),
    .pool_done(pool_done),
    .fmap_read_start(fmap_read_start),
    .weight_load_start(weight_load_start),
    .window_start(window_start),
    .conv_start(conv_start),
    .pool_start(pool_start),
    .out_write_en(out_write_en),
    .kernel_id(kernel_id),
    .base_row(base_row),
    .base_col(base_col),
    .out_addr(out_addr),
    .done(done)
);

/////////////////////////////////////////////////
// FMAP Reader
/////////////////////////////////////////////////
l2_fmap_reader fmap_reader_inst(
    .clk(clk), .rst(rst),
    .start(fmap_read_start),
    .rd_addr(l1_rd_addr),
    .pixel_in(l1_pixel_in),
    .pixel_out(fmap_pixel_to_bram),
    .pixel_addr_out(fmap_addr_to_bram),
    .pixel_valid(fmap_we),
    .done(fmap_read_done)
);

/////////////////////////////////////////////////
// Local FMAP BRAM
/////////////////////////////////////////////////
l2_fmap_bram fmap_bram_inst(
    .clk(clk),
    .we(fmap_we),
    .wr_addr(fmap_addr_to_bram),
    .din(fmap_pixel_to_bram),
    .rd_addr(fmap_rd_addr),
    .dout(fmap_bram_out)
);

/////////////////////////////////////////////////
// Sliding Window
/////////////////////////////////////////////////
l2_sliding_window sliding_window_inst(
    .clk(clk), .rst(rst),
    .start(window_start),
    .base_row(base_row),
    .base_col(base_col),
    .rd_addr(fmap_rd_addr),
    .pixel_in(fmap_bram_out),
    .pixel_bus_0(pixel_bus_0),
    .pixel_bus_1(pixel_bus_1),
    .pixel_bus_2(pixel_bus_2),
    .pixel_bus_3(pixel_bus_3),
    .pixel_bus_4(pixel_bus_4),
    .pixel_bus_5(pixel_bus_5),
    .window_valid(window_valid)
);

/////////////////////////////////////////////////
// Weight BRAM
/////////////////////////////////////////////////
l2_weight_bram weight_bram_inst(
    .clk(clk),
    .rd_addr(weight_rd_addr),
    .weight_out(weight_data)
);

/////////////////////////////////////////////////
// Weight Loader
/////////////////////////////////////////////////
l2_weight_loader weight_loader_inst(
    .clk(clk), .rst(rst),
    .start(weight_load_start),
    .kernel_id(kernel_id),
    .weight_in(weight_data),
    .bram_addr(weight_rd_addr),
    .weights_ready(weights_ready),
    .weight_bus_0(weight_bus_0),
    .weight_bus_1(weight_bus_1),
    .weight_bus_2(weight_bus_2),
    .weight_bus_3(weight_bus_3),
    .weight_bus_4(weight_bus_4),
    .weight_bus_5(weight_bus_5)
);

/////////////////////////////////////////////////
// Bias BRAM
/////////////////////////////////////////////////
l2_bias_bram bias_bram_inst(
    .clk(clk),
    .rd_addr(kernel_id),
    .bias_out(bias_data)
);

/////////////////////////////////////////////////
// Conv Core
/////////////////////////////////////////////////
l2_conv_core conv_core_inst(
    .clk(clk), .rst(rst),
    .start(conv_start),
    .pixel_bus_0(pixel_bus_0), .pixel_bus_1(pixel_bus_1),
    .pixel_bus_2(pixel_bus_2), .pixel_bus_3(pixel_bus_3),
    .pixel_bus_4(pixel_bus_4), .pixel_bus_5(pixel_bus_5),
    .weight_bus_0(weight_bus_0), .weight_bus_1(weight_bus_1),
    .weight_bus_2(weight_bus_2), .weight_bus_3(weight_bus_3),
    .weight_bus_4(weight_bus_4), .weight_bus_5(weight_bus_5),
    .bias(bias_data),
    .conv_out(conv_out),
    .done(conv_done)
);

/////////////////////////////////////////////////
// ReLU
/////////////////////////////////////////////////
l2_relu relu_inst(
    .din(conv_out),
    .dout(relu_out)
);

/////////////////////////////////////////////////
// Output BRAM (16x10x10)
/////////////////////////////////////////////////
l2_output_bram output_bram_inst(
    .clk(clk),
    .we(out_write_en),
    .wr_addr(out_addr),
    .din(relu_out),
    .rd_addr(pool_rd_addr),
    .dout(pool_pixel_in)
);

/////////////////////////////////////////////////
// Max Pooling
/////////////////////////////////////////////////
l2_max_pooling maxpool_inst(
    .clk(clk), .rst(rst),
    .start(pool_start),
    .rd_addr(pool_rd_addr),
    .pixel_in(pool_pixel_in),
    .pool_out(pool_out),
    .pool_valid(pool_valid),
    .pool_kernel(pool_kernel),
    .pool_row(pool_row),
    .pool_col(pool_col),
    .pool_kernel_out(pool_kernel_out),
    .pool_row_out(pool_row_out),
    .pool_col_out(pool_col_out),
    .done(pool_done)
);

/////////////////////////////////////////////////
// Pool Output BRAM (16x5x5 = 400)
// Uses registered signals for correct write timing
/////////////////////////////////////////////////
l2_pool_bram pool_bram_inst(
    .clk(clk),
    .we(pool_valid_r),
    .wr_addr(pool_wr_addr_r),
    .din(pool_out_r),
    .rd_addr(l3_rd_addr),
    .dout(l3_pixel_out)
);

endmodule