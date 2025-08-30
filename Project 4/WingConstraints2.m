function [c, ceq, dcdx, dceqdx] = WingConstraints2(x, L, E, force_nom, yield, Nelem)
% Computes the nonlinear inequality constraints for the wing-spar problem
% Inputs:
%   x - the DVs; x(1:Nelem+1) inner and x(Nelem+2:2*(Nelem+1) outer radius
%   L - length of the beam
%   E - longitudinal elastic modulus
%   force - force per unit length along the beam axis x
%   yield - the yield stress for the material
%   Nelem - number of finite elements to use
% Outputs:
%   c, ceq - inequality (stress) and equality (empty) constraints
%   dcdx, dceqdx - Jacobians of c and ceq
%--------------------------------------------------------------------------
assert( size(force_nom,1) == (Nelem+1) );
assert( size(x,1) == (2*(Nelem+1)) );

c = CalcInequality(x);
ceq = [];
dcdx = zeros(2*(Nelem+1),Nelem+1);
dceqdx = [];
for i = 1:2*(Nelem+1)
    xc = x;
    xc(i) = xc(i) + complex(0.0, 1e-30);
    dcdx(i,:) = imag(CalcInequality(xc))/1e-30;
end 

    function cineq = CalcInequality(x)
        % compute the displacements and the stresses
        r_in = x(1:Nelem+1);
        r_out = x(Nelem+2:2*(Nelem+1));
        Iyy = CalcSecondMomentAnnulus(r_in, r_out);
        %u = CalcBeamDisplacement(L, E, Iyy, force, Nelem);
        %sigma = CalcBeamStress(L, E, r_out, u, Nelem);
        
        % using a 3 point Gauss - Hermite quadrature
        xi = [0.0;(1/2);(-1/2)]*sqrt(6);
        w = [(2/3);(1/6);(1/6)]/sqrt(pi);
        mean = 0.0;
        mean2 = 0.0;
        pf=zeros([1 4]);

        Nx = 0:L/Nelem:L;
        stdev = zeros([1 4]);

        for j=1:4
            stdev(j) = force_nom(1)/10*j;
        end

        for k=1:3
            pf(1) = sqrt(2)*stdev(1)*xi(k);
            for l=1:3
                pf(2) = sqrt(2)*stdev(2)*xi(l);
                for m=1:3
                    pf(3) = sqrt(2)*stdev(3)*xi(m);
                    for n=1:3
                        pf(4) = sqrt(2)*stdev(4)*xi(n);
                        d = 0;
                        for o=1:4
                            d = d + pf(o).*cos(pi*Nx*(2*o-1)/(2*L));
                        end
                        force=force_nom+d';
                        
                        u = CalcBeamDisplacement(L, E, Iyy, force, Nelem);
                        sigma = CalcBeamStress(L, E, r_out, u, Nelem);

                        mean = mean + w(k)*w(l)*w(m)*w(n)*sigma;
                        mean2 = mean2 + w(k)*w(l)*w(m)*w(n)*sigma.^2;
                    end
                end
            end
        end
        stdev2 = sqrt(mean2 - mean.^2);
        cineq = ((mean + 6.* stdev2)./yield) - 1.0;
    end
end