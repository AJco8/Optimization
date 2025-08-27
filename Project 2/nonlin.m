function [cineq, ceq, Jineq, Jeq] = nonlin(r,Su,L, E, force, Nelem)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    Iyy = MoI(r);
    [u] = CalcBeamDisplacement(L, E, Iyy, force, Nelem);
    [~,zmax] = ExtractRadii(r);
    [s] = CalcBeamStress(L, E, zmax, u, Nelem);
    cineq = s/Su-1;
    
    h = 1e-30;
    Nnode = Nelem+1;
    Nvar = 2*(Nnode);
    Jineq = zeros(Nnode,Nvar);
    xc = r;
    for i=1:size(r,1)
        %Finding Jacobian
        xc(i) = r(i)+complex(0,h);
        Iyy = MoI(xc);
        [u] = CalcBeamDisplacement(L, E, Iyy, force, Nelem);
        [~,zmax] = ExtractRadii(xc);
        [s] = CalcBeamStress(L, E, zmax, u, Nelem);
        Jineq(:,i)=imag(s/Su-1)/h;
        xc = r;
    end
    Jineq=Jineq';
    ceq = [];
    Jeq = [];
end