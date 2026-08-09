`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.04.2026 00:06:04
// Design Name: 
// Module Name: arg_max
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
`timescale 1ns / 1ps

module l3_argmax (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,      
    output reg         done,
    output reg  [3:0]  rd_addr,
    input  wire [7:0]  rd_data,    
    output reg  [3:0]  max_index
);

    localparam S_IDLE = 2'd0, S_WAIT = 2'd1, S_COMP = 2'd2, S_DONE = 2'd3;

    reg [1:0] state;
    reg [3:0] count;
    reg signed [7:0] max_val;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= S_IDLE;
            rd_addr   <= 0;
            max_val   <= 8'sh80; 
            max_index <= 0;
            count     <= 0;
            done      <= 0;
        end else begin
            done <= 0;
            case (state)
                S_IDLE: begin
                    if (start) begin
                        count   <= 0;
                        rd_addr <= 0;
                        max_val <= 8'sh80;
                        state   <= S_WAIT;
                    end
                end
                S_WAIT: begin
                    state <= S_COMP;
                end
                S_COMP: begin
                    if ($signed(rd_data) > max_val) begin
                        max_val   <= $signed(rd_data);
                        max_index <= count;
                    end
                    if (count == 9) begin
                        state <= S_DONE;
                    end else begin
                        count   <= count + 1;
                        rd_addr <= count + 1;
                        state   <= S_WAIT; 
                    end
                end
                S_DONE: begin
                    done  <= 1;
                end
            endcase
        end
    end
endmodule