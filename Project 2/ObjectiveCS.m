function [m,grad] = ObjectiveCS(L,r,rho,Nelem)
%Returns the mass of the spar and the gradient of the function
% Inputs:
%   L = Length of spar
%   r = Array of radius design variables
%   rho = Density of material
%   Nelem = Number of elements
% Outputs
%   m = Total mass of spar
%   grad = Gradient of objective function
    mass = @(r) Objective(L,r,rho,Nelem);
    m = mass(r);  
    h = 1e-30;
    grad = zeros([(Nelem+1)*2 1]);
    for i=1:size(r,1)
        xc = r;
        xc(i) = r(i)+complex(0,h);
        grad(i) = imag(mass(xc))/h;
    end
end