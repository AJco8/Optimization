function F = fnom(x)
%The force applied to the spar during the 2.5g maneuver
%Inputs:
%   x = array representing the x-axis
%Outputs:
%   F = Array of force in newtons
    %Total Mass
    m = 500;%kg
    L = 7.5;%m
    g = 9.81;%m/s^2
    W = g*m;
    F = 2.5*W/L*(1-x'/L);
end