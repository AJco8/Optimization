function m = Objective(L,r,rho,Nelem)
%Returns the mass of the spar
% Inputs:
%   L = Length of spar
%   r = Array of radius design variables
%   rho = Density of material
%   Nelem = Number of elements
% Outputs
%   m = Total mass of spar
    [r_in,r_out] = ExtractRadii(r);
    V = zeros([Nelem 1]);
    for i=1:Nelem
        h=L/Nelem;
        V(i)=( (r_out(i)^2+r_out(i)*r_out(i+1)+r_out(i+1)^2) - (r_in(i)^2+r_in(i)*r_in(i+1)+r_in(i+1)^2) )*pi*h/3;
    end
    m = sum(V)*rho;
end