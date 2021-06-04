`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 04.06.2021 10:42
// Design Name: TaylorSeries16.sv
// Module Name: TaylorSeries16
// Project Name: System dedykowany realizaujący aproksymacje szeregu Taylor na platformie FPGA
// Target Devices: ZedBoard Zynq-7000
// Tool Versions: Vivado 2018.3
// Description: None
// 
// Dependencies: None
// 
// Revision: 
// Revision 0.06 - cleaned version of the project 
// Additional Comments: none
// 
//////////////////////////////////////////////////////////////////////////////////


module TaylorSeries16(clock, reset, start, ready_out, angle_in, cos_out );

// Fixed Point representation variables
parameter integer W = 18; 
parameter FXP_MUL = 65536;
parameter FXP_SHIFT = 16;

//Input, outputs
input clock, reset, start;
input [W-1:0] angle_in;
output reg ready_out;
output reg [W-1:0] cos_out;

// Taylor coefficients
reg signed [W-1:0] divider[0:3] = { 18'b00000000000000010,
                                    18'b00000000001011011,
                                    18'b00000101010101011, 
                                    18'b01000000000000000
                                    };

// States
parameter S1 = 4'h00, S2 = 4'h01, S3 = 4'h02, S4 = 4'h03, S5 = 4'h04, S6 = 4'h05, S7 = 4'h06, S8 = 4'h07;
reg [2:0] state;

// Temporary variables
reg signed [2*(W-1):0] const_x2, temp_x2, temp_x4, temp_x6, temp_x8;

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
            const_x2 <= (angle_in * angle_in) >> FXP_SHIFT;
            cos_out  <= 0;
            temp_x2 <= 0;
            temp_x4 <= 0;
            temp_x6 <= 0;
            temp_x8 <= 0;
            ready_out <= 0;
            state <= S3;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, regAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, regAngle);
        end
        S3: begin
            temp_x2 <= (const_x2 * divider[3]) >> FXP_SHIFT;
            temp_x4 <= (const_x2 * divider[2]) >> FXP_SHIFT;
            temp_x6 <= (const_x2 * divider[1]) >> FXP_SHIFT;
            temp_x8 <= (const_x2 * divider[0]) >> FXP_SHIFT;
            state <= S4;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d, div[2] = %d, div[1] = %d, div[0] = ", const_x2, temp_x2, temp_x4, temp_x6, tempAngle, divider[2], divider[1], divider[0]);
        end
        S4:begin
            temp_x4 <= (const_x2 * temp_x4) >> FXP_SHIFT;
            temp_x6 <= (const_x2 * temp_x6) >> FXP_SHIFT;
            temp_x8 <= (const_x2 * temp_x8) >> FXP_SHIFT;
            state <= S5;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S5:begin
            temp_x6 <= (const_x2 * temp_x6) >> FXP_SHIFT;
            temp_x8 <= (const_x2 * temp_x8) >> FXP_SHIFT;
            state <= S6;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S6:begin
            temp_x8 <= (const_x2 * temp_x8) >> FXP_SHIFT;
            state <= S7;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end 
        S7:begin
            cos_out  <= 1 * FXP_MUL -  temp_x2 + temp_x4 - temp_x6 + temp_x8;  
            ready_out = 1;
            state <= S8;
            //$display("const_x2 = %d, tempx2 = %d, tempx4 = %d, tempx6 = %d, tempAngle = %d", const_x2, temp_x2, temp_x4, temp_x6, tempAngle);
        end
        S8: begin
            if(start == 1'b0) state <= S8; else state <= S1;
        end
    endcase
    end
end

endmodule