function Iyy = MoI(r)
% Moment of Inertia with respect to y-axis
% Input
%   r: radius array
% Output
%   Iyy: Moment of Inertia
    [r_in,r_out]=ExtractRadii(r);
    Iyy = (r_out.^4-r_in.^4).*(pi/4);
    tol = 1e-8;
    Iyy(Iyy<tol) = tol;
end