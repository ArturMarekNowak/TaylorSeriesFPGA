module Taylor_beh();
/**
* Cordic algorithm
*/
real t_angle = 0.5; //Input parameter. The angle

real cos = 1.0; //Initial vector x coordinate
real sin = 0.0; //and y coordinate

real angle = 0.0; //A running angle
real regAngle = 0, tempAngle = 0, tempx2 = 0;
parameter FXP_MUL = 1024;
parameter FXP_SHIFT = 10;

integer cnt = 0, d;

initial //Execute only once

begin
    regAngle = t_angle ;
    tempx2 = regAngle * regAngle ;
    $display("tx2=%f", tempx2);
    tempAngle = tempx2 / 720;
    $display("rA=%f", tempAngle);
    tempAngle = - tempx2 / 24 + tempx2 * tempAngle;
    $display("rA=%f", tempAngle);
    tempAngle = tempx2 / 2 - tempx2 * tempAngle;
    $display("rA=%f", tempAngle);
    tempAngle = 1 - tempAngle;
    $display("rA=%f", tempAngle);
    tempAngle = tempAngle;
    
cos = tempAngle; 
$display("cos=%f", cos);
end
endmodule

