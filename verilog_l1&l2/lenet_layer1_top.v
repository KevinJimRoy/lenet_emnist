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

    input  [12:0] l2_rd_addr,
    output [7:0]  l2_pixel_out,

    output done
);

wire weight_load_start;
wire window_start;
wire conv_start;
wire out_write_en;

wire [2:0]  kernel_id;
wire [5:0]  base_row;
wire [5:0]  base_col;

wire weights_ready;
wire window_valid;
wire conv_done;

wire [199:0] pixel_bus;
wire [199:0] weight_bus;

wire [7:0]        pixel_data;
wire [7:0]        weight_data;
wire signed [7:0] bias_data;
wire signed [7:0] conv_out;
wire [7:0]        relu_out;

wire [7:0]  pool_out;
wire        pool_valid;
wire [3:0]  pool_row;
wire [3:0]  pool_col;
wire [3:0]  pool_row_out;
wire [3:0]  pool_col_out;

wire [12:0] out_addr;
wire [9:0]  pixel_addr;
wire [7:0]  weight_addr;

// Delayed kernel_id - holds previous kernel value
// when pool_valid fires so address is correct
reg [2:0] kernel_id_sync;

always @(posedge clk or posedge rst)
begin
    if(rst)
        kernel_id_sync <= 0;
    else
        kernel_id_sync <= kernel_id;
end

// 5-cycle delayed fmap_start
reg [4:0] fmap_start_pipe;

always @(posedge clk or posedge rst)
begin
    if(rst)
        fmap_start_pipe <= 5'b00000;
    else
        fmap_start_pipe <= {fmap_start_pipe[3:0], weight_load_start};
end

wire fmap_start_delayed;
assign fmap_start_delayed = fmap_start_pipe[4];

// Registered pool signals
// Use kernel_id_sync for correct address
reg [12:0] pool_addr_r;
reg [7:0]  pool_out_r;
reg        pool_valid_r;

always @(posedge clk)
begin
    pool_valid_r <= pool_valid;
    pool_out_r   <= pool_out;
    pool_addr_r  <= {10'b0, kernel_id_sync} * 13'd196 +
                    {9'b0,  pool_row_out}   * 13'd14  +
                    {9'b0,  pool_col_out};
end

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
    .out_addr(out_addr),
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
    .fmap_start(fmap_start_delayed),
    .pixel_in(relu_out),
    .valid_out(pool_valid),
    .pixel_out(pool_out),
    .pool_row(pool_row),
    .pool_col(pool_col),
    .pool_row_out(pool_row_out),
    .pool_col_out(pool_col_out)
);

/////////////////////////////////////////////////
// OUTPUT BRAM
/////////////////////////////////////////////////
output_bram output_bram_inst(
    .clk(clk),
    .we(pool_valid_r),
    .wr_addr(pool_addr_r),
    .din(pool_out_r),
    .rd_addr(l2_rd_addr),
    .dout(l2_pixel_out)
);

endmodule