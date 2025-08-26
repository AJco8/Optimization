function f = objective(h, L, Nx, kappa, Ttop, Tbot)
% Calculates the reciprocal of heat flux to act as the objective function
% for fmincon
% Inputs:
%   L - length of domain in x direction
%   h - height as a function of x; note that size(h,1) must be Nx+1
%   Nx - number of elements along the x direction
%   Ny - number of elements along the y direction
%   kappa - thermal conductivity
%   Ttop - the ambient air temperature along the top of the domain
%   Tbot - the fluid temperature along the bottom of the domain
% Outputs:
%   f - inverse of the heat flux per unit length
    Ny = Nx;
    [flux,~,~,~] = CalcFlux(L, h, Nx, Ny, kappa, Ttop, Tbot);
    f = 1/flux;
end
