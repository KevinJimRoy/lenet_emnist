module image_bram
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10,
    parameter DEPTH = 1024
)
(
    input clk,
    input [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] pixel_out
);

    (* ram_style = "block" *)
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial
    begin
        $readmemh(req adr, mem);
    end

    always @(posedge clk)
    begin
        pixel_out <= mem[addr];
    end

endmodule
