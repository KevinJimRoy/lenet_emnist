`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 20:06:55
// Design Name: 
// Module Name: l3_mac_unit
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


module l3_mac_unit #(
    parameter DATA_WIDTH=13
)(
    input  wire        clk,
    input  wire        rst,

    input  wire        data_valid,
    input  wire [DATA_WIDTH-1:0]  pix0, pix1, pix2, pix3,
    input  wire [DATA_WIDTH-1:0]  wt0,  wt1,  wt2,  wt3,

    output reg         mac_valid,
    output wire signed [2*DATA_WIDTH+3:0] mac_out
);

    reg signed [DATA_WIDTH-1:0] p0_r, p1_r, p2_r, p3_r;
    reg signed [DATA_WIDTH-1:0] w0_r, w1_r, w2_r, w3_r;


    reg [2:0] pipe_valid;

    always @(posedge clk) begin
        if (rst) begin
            p0_r <= 0; p1_r <= 0; p2_r <= 0; p3_r <= 0;
            w0_r <= 0; w1_r <= 0; w2_r <= 0; w3_r <= 0;
            pipe_valid <= 3'b000;
            mac_valid  <= 0;
        end else begin
            if (data_valid) begin
                p0_r <= $signed(pix0);
                p1_r <= $signed(pix1);
                p2_r <= $signed(pix2);
                p3_r <= $signed(pix3);
                w0_r <= $signed(wt0);
                w1_r <= $signed(wt1);
                w2_r <= $signed(wt2);
                w3_r <= $signed(wt3);
            end

            pipe_valid[0] <= data_valid;
            pipe_valid[1] <= pipe_valid[0];
            pipe_valid[2] <= pipe_valid[1];
            mac_valid     <= pipe_valid[2];
        end
    end

    l3_mac  u_mac (
        .clk     (clk),
        .p0      (p0_r), .p1(p1_r), .p2(p2_r), .p3(p3_r),
        .w0      (w0_r), .w1(w1_r), .w2(w2_r), .w3(w3_r),
        .mac_out (mac_out)
    );

endmodule
