`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 16:44:38
// Design Name: 
// Module Name: top_g
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


module top_g  (
    input  wire        clk_in,         
    input  wire        rst,           
    input  wire        start,          
    output wire [3:0]  prediction,     
    output wire        pipeline_done   
);

    wire slow_clk;

    clk_divider u_divider (
        .clk(clk_in),
        .rst(rst),
        .clk_new(slow_clk)
    );

    cnn_top  u_cnn_core (
        .clk(slow_clk),               
        .rst(rst),                    
        .start(start),                
        .prediction(prediction),     
        .pipeline_done(pipeline_done) 
    );

endmodule    
    



