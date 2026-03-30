`timescale 1ns / 1ps

module l2_weight_bram
#(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 2400
)
(
    input clk,

    input  [11:0] rd_addr,
    output reg signed [DATA_WIDTH-1:0] weight_out
);

    (* ram_style = "block" *)
    reg signed [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial
    begin
        $readmemh("C:/ACAD/Sem6/OELP_DL_VLSI/cnn_l1_l2/cnn_l1_l2.srcs/sources_1/new/c2_weights.hex", mem);
    end

    always @(posedge clk)
    begin
        weight_out <= mem[rd_addr];
    end

endmodule
