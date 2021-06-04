`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 04.06.2021 10:42
// Design Name: TaylorSeries23_tb.sv
// Module Name: TaylorSeries23
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


module TaylorSeries23_tb;

function real cos (input real x);
    if( x <= 0.25) begin // Taylor
      real x2= x*x;
      cos= 1.0 + x2 * (-0.5 + x2 * (1.0/24.0 + x2 * (-1.0/720.0 + x2/40320.0)));
      end
    else begin // use formula cos(4x) = f( cos(x) )
      real cosx4= cos(0.25 * x); // cos(4x) = 2*cos^2(2x)-1 = 8*cos^4(x) - 8*cos^2(x) + 1
      cosx4= cosx4 * cosx4;
      cos= 8.0 * (cosx4 * (cosx4 - 1.0) ) + 1.0; // 
    end
endfunction

// Fixed Point representation variables
parameter integer W = 25; 
parameter FXP_MUL = 8388608.0;

// Simulation variables
reg clock, reset, start;
reg [W-1:0] angle_in, cos_out;
wire ready_out;

// Real cos representation variables
real real_cos, real_cos_out, real_cos_correct;

// Error check variables
real error_max_LSB, error_cos_LSB, sum_error2_cos_LSB, MSE_cos_LSB, ME_cos_LSB, sum_error_cos_LSB;
int N = 0;

TaylorSeries23 TaylorSeries23( clock, reset, start, ready_out, angle_in, cos_out);

// Clock generator
initial
 clock <= 1'b1;
always
    #5 clock <= ~clock;

// Reset signal
initial
begin
    reset <= 1'b1;
    #10 reset <= 1'b0;
end

// Stimuli signals
initial
begin
    angle_in <= 8192; // Modify value in fixed-point [2:16]
    start <= 1'b0;
    #20 start <= 1'b1;
    #20 start <= 1'b0;
end
always @ (posedge ready_out)
begin
    
    // Convert integer value of Taylor module output into real domain
    #5 real_cos_out = cos_out / FXP_MUL;
    
    // Increment counter
    N += 8192;
    
    // Convert integer value of input angle into real domain
    real_cos = N / FXP_MUL;
    
    // Add previous LSB error to summation variable
    sum_error_cos_LSB += error_cos_LSB;
    
    // Calculate correct reference value of cosine in real domain
    real_cos_correct = cos(real_cos);
    
    // Calculate difference between correct value of cosine 
    // and the one given by Taylor module and convert and
    // multiply it by FXP representation. Hence LSB error is given
    error_cos_LSB = (real_cos_correct - real_cos_out) * FXP_MUL;
    
    // Calculate error LSB sqared and sum it with previous results 
    sum_error2_cos_LSB += error_cos_LSB * error_cos_LSB;
    
    // Calculate Mean Square Error
    MSE_cos_LSB = sum_error2_cos_LSB / N;
    
    // Calculate Mean Error
    ME_cos_LSB = sum_error_cos_LSB / N;
    
    // Increment angle
    angle_in <= angle_in + 8192; 
       
    #50 start <= 1'b1;
    #20 start <= 1'b0;
    $display("real_cos:, %f, real_cos_out:, %f, sum_error_cos_LSB:, %f, real_cos_correct:, %f, error_cos_LSB:, %f, sum_error2_cos_LSB:, %f, MSE_cos_LSB:, %f, ME_cos_LSB:, %f,", real_cos, real_cos_out, sum_error_cos_LSB, real_cos_correct, error_cos_LSB, sum_error2_cos_LSB, MSE_cos_LSB, ME_cos_LSB);
       
    
    if (angle_in > 1.57 * FXP_MUL )
      $stop; 

end
endmodule