`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: clk_divider
// Description: Divides input clock by 3.
//              Output clk_new is HIGH for 1 fast-clock cycle, LOW for 2.
//              Period of clk_new = 3 × period of clk (33 % duty cycle).
//              This is sufficient for all synchronous downstream logic that
//              only samples on the posedge of clk_new.
//////////////////////////////////////////////////////////////////////////////////

module clk_divider(
    input  wire clk,
    input  wire rst,
    output reg  clk_new
);
    // 2-bit counter: cycles through 0 → 1 → 2 → 0 → …
    reg [1:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 2'd0;
            clk_new <= 1'b0;
        end else begin
            if (counter == 2'd2) begin
                // --- wrap: pulse clk_new HIGH for this one fast cycle ---
                counter <= 2'd0;
                clk_new <= 1'b1;
            end else begin
                counter <= counter + 2'd1;
                clk_new <= 1'b0;        // LOW for the other two cycles
            end
        end
    end

endmodule
