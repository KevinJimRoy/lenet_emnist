module l2_bias_bram
#(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)
(
    input clk,

    input  [3:0] rd_addr,
    output reg signed [DATA_WIDTH-1:0] bias_out
);

    (* ram_style = "block" *)
    reg signed [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial
    begin
      $readmemh(req addr, mem);
    end

    always @(posedge clk)
    begin
        bias_out <= mem[rd_addr];
    end

endmodule
