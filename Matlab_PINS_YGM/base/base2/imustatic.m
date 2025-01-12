function [imu, eth] = imustatic(avp0, ts, T, imuerr)
% SIMU sensor incremental outputs on static base.
%
% Prototype: [imu, eth] = imustatic(avp0, ts, T, imuerr)
% Inputs: avp0 - initial avp0=[att0,vn0,pos0]
%         ts - SIMU sampling interval
%         T - total sampling simulation time
%         imuerr - SIMU error setting structure array from imuerrset
% Outputs: imu - gyro & acc incremental outputs
%          eth - the Earth parameters corresponding to avp0
% 
% See also  imuerrset, trjsimu, trjunilat, insupdate.

% Copyright(c) 2009-2014, by Gongmin Yan, All rights reserved.
% Northwestern Polytechnical University, Xi An, P.R.China
% 28/08/2013, 10/01/2014
    Cbn = a2mat(avp0(1:3))';
    eth = earth(avp0(7:9), avp0(4:6));
    imu = [Cbn*eth.wnie; -Cbn*eth.gn]';
    if nargin<2,  ts = 1; T = ts;  end
    if nargin<3,  T = ts;  end
    len = round(T/ts);
    imu = repmat(imu*ts, len, 1);
            %repmat是复制和平铺矩阵，语法有B = repmat(A,m,n)，将矩阵 A 复制 m×n 块，
            %即把 A 作为 B 的元素，B 由 m×n 个 A 平铺而成。B 的维数是 [size(A,1)*m, size(A,2)*n] 。
    if nargin==4
        imu = imuadderr(imu, imuerr, ts);
    end
    imu(:,7) = (1:len)'*ts;
