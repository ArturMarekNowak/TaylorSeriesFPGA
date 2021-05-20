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


module TaylorSeries(clock, reset, start, ready_out, regAngle, tempAngle );

//Fixed Point
parameter integer W = 24; 
parameter FXP_MUL = 1024;
parameter FXP_SHIFT = 10;

//Input, outputs
input clock, reset, start;
input [W-1:0] regAngle;
output reg ready_out;
output reg [W-1:0] tempAngle ;

//Taylor coefficients
reg signed [W-1:0] divider[0:3] = { 12'b000000000001, 12'b000000101010, 12'b001000000000, 12'b000000000001 };

//States
parameter S1 = 4'h00, S2 = 4'h01, S3 = 4'h02, S4 = 4'h03, S5 = 4'h04, S6 = 4'h05, S7 = 4'h06, S8 = 4'h07, S9 = 4'h08, S10 = 4'h09, S11 = 4'h0A;
reg [2:0] state;

//Temporary variables
reg signed [W -1:0] const_x2, temp_x2, temp_x4, temp_x6;

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
            const_x2 <= (regAngle * regAngle) / FXP_MUL;
            tempAngle  <= 0;
            temp_x2 <= 0;
            temp_x4 <= 0;
            temp_x6 <= 0;
            ready_out <= 0;
            state <= S3;
        end
        S3: begin
            temp_x2 <= (const_x2 * divider[2]) >> FXP_SHIFT;
            temp_x4 <= (const_x2 * divider[1]) >> FXP_SHIFT;
            temp_x6 <= (const_x2 * divider[0]) >> FXP_SHIFT;
            state <= S4;
            $display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S4:begin
            temp_x6 <= (const_x2 * temp_x6) >> FXP_SHIFT;
            temp_x4 <= (const_x2 * temp_x4) >> FXP_SHIFT;
            state <= S5;
            $display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S5:begin
            temp_x6 <= (const_x2 * temp_x6) >> FXP_SHIFT;
            state <= S6;
            $display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S6:begin
            tempAngle  <= 1 * FXP_MUL -  temp_x2 + temp_x4 - temp_x6;  
            ready_out = 1;
            state <= S7;
            $display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S7: begin
            if(start == 1'b0) state <= S7; else state <= S1;
        end
    endcase
    end
end

endmodule
