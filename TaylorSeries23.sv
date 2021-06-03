`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 03.06.2021 18:24
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
// Revision 0.04 - increased FXP and added correct error analysis
// Additional Comments: none
// 
//////////////////////////////////////////////////////////////////////////////////


module TaylorSeries(clock, reset, start, ready_out, regAngle, tempAngle );

//Fixed Point
parameter integer W = 24; 
parameter FXP_MUL = 8388608;
parameter FXP_SHIFT = 23;

//Input, outputs
input clock, reset, start;
input [W-1:0] regAngle;
output reg ready_out;
output reg [W-1:0] tempAngle;

//Taylor coefficients
reg signed [W-1:0] divider[0:4] = { 24'b00000000000000000000010,
                                    24'b00000000000000011010000,
                                    24'b00000000010110110000011, 
                                    24'b00001010101010101010101, 
                                    24'b10000000000000000000000 };
/*
reg signed [W-1:0] divider[0:3] = { 24'b000000000000000001011011, 
                                    24'b000000000000101010101011, 
                                    24'b000000001000000000000000, 
                                    24'b000000001000000000000000 };
*/
//States
parameter S1 = 4'h00, S2 = 4'h01, S3 = 4'h02, S4 = 4'h03, S5 = 4'h04, S6 = 4'h05, S7 = 4'h06, S8 = 4'h07, S9 = 4'h08;
reg [2:0] state;

//Temporary variables
reg signed [2*W:0] const_x2, temp_x2, temp_x4, temp_x6, temp_x8, temp_x10;

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
            const_x2 <= (regAngle * regAngle) >> FXP_SHIFT;
            tempAngle  <= 0;
            temp_x2 <= 0;
            temp_x4 <= 0;
            temp_x6 <= 0;
            temp_x8 <= 0;
            temp_x10 <= 0;
            ready_out <= 0;
            state <= S3;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, regAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, regAngle);
        end
        S3: begin
            temp_x2 <= (const_x2 * divider[4]) >> FXP_SHIFT;
            temp_x4 <= (const_x2 * divider[3]) >> FXP_SHIFT;
            temp_x6 <= (const_x2 * divider[2]) >> FXP_SHIFT;
            temp_x8 <= (const_x2 * divider[1]) >> FXP_SHIFT;
            temp_x10 <= (const_x2 * divider[0]) >> FXP_SHIFT;
            state <= S4;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d, div[2] = %d, div[1] = %d, div[0] = ", const_x2, temp_x2, temp_x4, temp_x6, tempAngle, divider[2], divider[1], divider[0]);
        end
        S4:begin
            temp_x4 <= (const_x2 * temp_x4) >> FXP_SHIFT;
            temp_x6 <= (const_x2 * temp_x6) >> FXP_SHIFT;
            temp_x8 <= (const_x2 * temp_x8) >> FXP_SHIFT;
            temp_x10 <= (const_x2 * temp_x10) >> FXP_SHIFT;
            state <= S5;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S5:begin
            temp_x6 <= (const_x2 * temp_x6) >> FXP_SHIFT;
            temp_x8 <= (const_x2 * temp_x8) >> FXP_SHIFT;
            temp_x10 <= (const_x2 * temp_x10) >> FXP_SHIFT;
            state <= S6;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S6:begin
            temp_x8 <= (const_x2 * temp_x8) >> FXP_SHIFT;
            temp_x10 <= (const_x2 * temp_x10) >> FXP_SHIFT;
            state <= S7;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S7:begin
            temp_x10 <= (const_x2 * temp_x10) >> FXP_SHIFT;
            state <= S8;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end      
        S8:begin
            tempAngle  <= 1 * FXP_MUL -  temp_x2 + temp_x4 - temp_x6 + temp_x8 - temp_x10;  
            ready_out = 1;
            state <= S9;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S9: begin
            if(start == 1'b0) state <= S9; else state <= S1;
        end
    endcase
    end
end

endmodule
