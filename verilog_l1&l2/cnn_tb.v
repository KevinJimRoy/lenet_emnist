`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2026 23:23:14
// Design Name: 
// Module Name: cnn_tb
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


module cnn_tb;

    reg clk;
    reg rst;
    reg start;

    reg  [8:0] l3_rd_addr;
    wire [7:0] l3_pixel_out;

    wire l2_done;

    integer f_out;
    integer i;

    // ================= DUT =================
    cnn_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .l3_rd_addr(l3_rd_addr),
        .l3_pixel_out(l3_pixel_out),

        .l2_done(l2_done)
    );

    // ================= CLOCK =================
    always #5 clk = ~clk;

    // ================= INIT =================
    initial begin
        clk = 0;
        rst = 1;
        start = 0;


        l3_rd_addr = 0;

        #20;
        rst = 0;

        // Start CNN
        #10;
        start = 1;
        #10;
        start = 0;

        // Wait for L2 to finish
        wait(l2_done);

        $display("LAYER 2 DONE");

        // ================= DUMP OUTPUT =================
        f_out = $fopen("layer2_maxpool.hex", "w");

        // Adjust this size if needed
        for (i = 0; i < 400; i = i + 1) begin
            l3_rd_addr = i;
            #10;  // allow data to settle

            $fwrite(f_out, "%02x\n", l3_pixel_out & 8'hFF);
        end

        $fclose(f_out);

        $display("HEX FILE GENERATED");
        $stop;
    end

endmodule
