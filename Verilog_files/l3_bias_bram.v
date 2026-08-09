`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 12:00:59
// Design Name: 
// Module Name: l3_bias_bram
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



module l3_bias_bram #(
    parameter N_NEURONS  = 10,       
    parameter DATA_WIDTH = 13
)(
    input  wire                         clk,
    input  wire [$clog2(N_NEURONS)-1:0] rd_addr, 
    output reg  signed [DATA_WIDTH-1:0] dout
);

    // Memory array for 10 bias values
    (* ram_style = "block" *)
    reg signed [DATA_WIDTH-1:0] mem [0:N_NEURONS-1];

    initial begin
        $readmemh("l3_bias.mem", mem);
    end

    always @(posedge clk) begin
        dout <= {mem[rd_addr],5'b0};
    end

endmodule
