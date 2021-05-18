`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 24.04.2021 16:19:42
// Design Name: TaylorSeries.sv
// Module Name: TaylorSeries
// Project Name: System dedykowany realizaujący aproksymacje szeregu Taylor na platformie FPGA
// Target Devices: ZedBoard Zynq-7000
// Tool Versions: Vivado 2018.3
// Description: None
// 
// Dependencies: None
// 
// Revision: 
// Revision 0.02 - Toy example of behavioral
// Additional Comments: none
// 
//////////////////////////////////////////////////////////////////////////////////


module TaylorSeries(clock, reset, start, ready_out, angle_in, cos_out);

//Fixed Point
parameter integer W = 24; 
parameter FXP_MUL = 1024;
parameter FXP_SHIFT = 10;

//Input, outputs
input clock, reset, start;
input [W-1:0] angle_in;
output reg ready_out;
output reg [W-1:0] cos_out;

//Taylor coefficients
reg signed [W-1:0] divider[0:3] = { 12'b010000000000, 12'b001000000000, 12'b000000101011, 12'b000000000001 };

//States
parameter S1 = 4'h00, S2 = 4'h01, S3 = 4'h02, S4 = 4'h03, S5 = 4'h04, S6 = 4'h05, S7 = 4'h06;
reg [2:0] state;

//Temporary variables
reg signed [W -1:0] temp_x2;

always @ (posedge clock)
begin
    if(reset==1'b1)
    begin
        ready_out <= 1'b0;
        state <= S1;
    end
    else
    begin
    case(state)
        S1: begin
            if(start == 1'b1) state <= S2; else state <= S1;
           end
        S2: begin
            temp_x2 <= (angle_in * angle_in) / FXP_MUL;
            cos_out <= 0;
            ready_out <= 0;
            state <= S3;
        end
        S3: begin
            cos_out <= temp_x2 / 120;
            state <= S4;
        end
        S4:begin
            cos_out <= temp_x2 / 24 - cos_out; 
            state <= S5;
        end
        S5:begin
            cos_out <= temp_x2 / 2 + cos_out; 
            state <= S6;
        end
        S6:begin
            cos_out <= 1 * FXP_MUL -  cos_out; 
            ready_out = 1;
            state <= S7;
        end
        S7: begin
            if(start == 1'b0) state <= S7; else state <= S1;
        end
    endcase
    end
end

endmodule

