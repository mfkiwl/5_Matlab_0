function ahrs = QEAHRSUpdate(ahrs, gyro, acc, mag, ts)
% Quaternion&EKF based AHRS algorithm with state vector
% X=[q0,q1,q2,q3,ebx,eby,ebz]' : q*-quaternion element, eb*-gyro drift.
%
% Prototype: ahrs = QEAHRSUpdate(ahrs, gyro, acc, mag, ts)
% Inputs: ahrs - AHRS structure array
%        gyro - gyro sample in deg/s
%        acc - accelerometer sample in g
%        mag - magetic output in mGauss
%        ts - sample interval
% Output: ahrs - output AHRS structure array
%
% See also  QEAHRSInit, MahonyUpdate.

% Copyright(c) 2009-2017, by Gongmin Yan, All rights reserved.
% Northwestern Polytechnical University, Xi An, P.R.China
% 07/06/2017
    gyro = gyro*(pi/180);
    q0 = ahrs.kf.xk(1); q1 = ahrs.kf.xk(2); q2 = ahrs.kf.xk(3); q3 = ahrs.kf.xk(4); 
	wx = gyro(1); wy = gyro(2); wz = gyro(3); 
	fx = acc(1);  fy = acc(2);  fz = acc(3); 
	mx = mag(1);  my = mag(2);  mz = mag(3); 
    ahrs.kf.Phikk_1 = eye(7) + ...
        [ 0 -wx -wy -wz  q1  q2  q3;
         wx   0  wz -wy -q0  q3 -q2;
         wy -wz   0  wx -q3 -q0  q1;
         wz  wy  -wx  0  q2 -q1 -q0;
        zeros(3,7) ]*ts/2;
    h11 = fx*q0-fy*q3+fz*q2;  h12 = fx*q1+fy*q2+fz*q3;
    h21 = fx*q3+fy*q0-fz*q1;  h22 = fx*q2-fy*q1-fz*q0;
    ahrs.kf.Hk(1:2,:) = [ h11  h12  -h22 -h21  0 0 0
                          h21  h22   h12  h11  0 0 0 ] *2 ;
    magH = ahrs.Cnb*mag;
    nm = norm(magH(1:2));
    if nm>0
        yaw = atan2(magH(1), magH(2));
        C22 = ahrs.Cnb(2,2); C12 = ahrs.Cnb(1,2);
        ahrs.kf.Hk(3,:) = [2*q3*C22+2*q0*C12, -2*q2*C22-2*q1*C12, -2*q1*C22+2*q2*C12, 2*q0*C22-2*q3*C12, 0, 0, 0]/(C22^2+C12^2);
    else
        yaw = 0;
        ahrs.kf.Hk(3,:) = zeros(1,7);
    end
    ahrs.kf = kfupdate(ahrs.kf, [0;0; yaw]);
    ahrs.kf.xk(1:4) = qnormlz(ahrs.kf.xk(1:4));
    ahrs.Cnb = q2mat(ahrs.kf.xk(1:4));
    ahrs.tk = ahrs.tk + ts;
