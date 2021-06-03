`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 03.06.2021 22:01
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
// Revision 0.05 - added 16bit FXP module 
// Additional Comments: none
// 
//////////////////////////////////////////////////////////////////////////////////


module TaylorSeries_tb;

function real cos (input real x);
    if( x <= 0.25) begin // Taylor
      real x2= x*x;
      //cos= 1.0 + x2 * (-0.5 + x2 * (1.0/24.0 + x2 * (-1.0/720.0 + x2 * (1.0/40320.0 + x2 * (-1.0/3628800.0 + x2/479001600.0)))))  ; // skipped -x^10 / 10!
      cos= 1.0 + x2 * (-0.5 + x2 * (1.0/24.0 + x2 * (-1.0/720.0 + x2/40320.0)))  ;
      end
    else begin // use formula cos(4x) = f( cos(x) )
      real cosx4= cos(0.25 * x); // cos(4x) = 2*cos^2(2x)-1 = 8*cos^4(x) - 8*cos^2(x) + 1
      cosx4= cosx4 * cosx4;
      cos= 8.0 * (cosx4 * (cosx4 - 1.0) ) + 1.0; // 
    end
endfunction


parameter integer W = 18; 
reg clock, reset, start;
reg [W-1:0] angle_in, cos_out;
wire ready_out;
real abs, real_real_cos, error_max_LSB, real_cos_out, real_cos_correct, error_cos_LSB, sum_error2_cos_LSB = 0.0, MSE_cos_LSB, ME_cos_LSB, sum_error_cos_LSB= 0.0;;
int N = 0;

parameter FXP_MUL = 65536.0;

const real FXP_MUL_REV = 1.0 / FXP_MUL;

TaylorSeries TaylorSeries( clock, reset, start, ready_out, angle_in, cos_out);

//Clock generator
initial
 clock <= 1'b1;
always
    #5 clock <= ~clock;

//Reset signal
initial
begin
    reset <= 1'b1;
    #10 reset <= 1'b0;
end

//Stimuli signals
initial
begin
    angle_in <= 64; //Modify value in fixed-point [2:10]
    start <= 1'b0;
    #20 start <= 1'b1;
    #20 start <= 1'b0;
end
always @ (posedge ready_out)
begin

    #5 real_cos_out = cos_out * FXP_MUL_REV;
    N += 64;
    real_real_cos= N * FXP_MUL_REV;
    sum_error_cos_LSB+= error_cos_LSB;
    real_cos_correct= cos(real_real_cos);
    error_cos_LSB= (real_cos_correct - real_cos_out) / FXP_MUL_REV;
    sum_error2_cos_LSB+= error_cos_LSB * error_cos_LSB;
    MSE_cos_LSB= sum_error2_cos_LSB / N;
    ME_cos_LSB= sum_error_cos_LSB / N;
    
    
    
    
    //$display("Real values: cos=%f", real_cos_out);
    angle_in <= angle_in + 64; // Increment angle
       
    #50 start <= 1'b1;
    #20 start <= 1'b0;
      
    if (angle_in > 1.57 * FXP_MUL )
      $stop; 

end
endmodule
