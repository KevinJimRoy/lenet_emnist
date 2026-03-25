module weight_bram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8,
    parameter DEPTH = 150
)
(
    input clk,
    input [ADDR_WIDTH-1:0] addr,
    output reg signed [DATA_WIDTH-1:0] weight_out
);

    (* ram_style = "block" *)
    reg signed [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        $readmemh("C:/ACAD/Sem6/OELP_DL_VLSI/cnn_conv/cnn_conv.srcs/sources_1/new/c1_weight_f0.hex", mem);
    end

    always @(posedge clk) begin
        weight_out <= mem[addr];
    end

endmodule
