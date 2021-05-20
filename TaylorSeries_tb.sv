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


module TaylorSeries_tb;
reg clock, reset, start;
reg [23:0] angle_in;
wire ready_out;
wire [23:0] cos_out;
real real_cos;

parameter FXP_MUL = 1024.0;

TaylorSeries TaylorSeries(clock, reset, start, ready_out, angle_in, cos_out);

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
    angle_in <= 0.0 * FXP_MUL; //Modify value in fixed-point [2:10]
    start <= 1'b0;
    #20 start <= 1'b1;
end
always @ (posedge ready_out)
begin
    #10 real_cos = cos_out /FXP_MUL;
    $display("Real values: cos=%f", real_cos);
    #100 angle_in <= angle_in + 0.1 * FXP_MUL; // Increment angle
      
    if (angle_in > 1.5 * FXP_MUL )
      $stop; 

end
endmodule