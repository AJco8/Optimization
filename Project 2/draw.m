clear,clc

R = 3; %outer radius
r = 2; %inner radius
steps = 100;

theta = 0:2*pi/steps:2*pi;
r_outer = ones(size(theta))*R;
r_inner = ones(size(theta))*r;
rr = [r_outer;r_inner];
theta = [theta;theta];
xx = rr.*cos(theta);
yy = rr.*sin(theta);
plot(xx,yy)