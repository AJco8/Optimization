function [mean,sigma] = Perturbation(r, x, L, E, Nelem)
%Calculates the expected value of the stress from perturbed force
% Inputs
%   r = radius design variable column array
%   x = x-axis array
%   L = length of the beam
%   E = longitudinal elastic modulus
%   Nelem = number of finite elements to use
% Outputs:
%   mean = expected value
%   sigma = standard deviation
    [r_in,r_out] = ExtractRadii(r);
    Iyy = CalcSecondMomentAnnulus(r_in, r_out);
    standev=@(n)fnom(1)/(10*n); 
    
    % using a 3 point Gauss - Hermite quadrature
    xi = [ -1.22474487139; 0.0; 1.22474487139];
    w = [0.295408975151; 1.1816359006; 0.295408975151]./sqrt (pi);
    mean = 0.0;
    mean2 = mean;
    m=3;
    p=zeros([1 4]);
    for i=1:m
        p(1) = sqrt(2)*standev(1)*xi(i);
        for j=1:m
            p(2) = sqrt(2)*standev(2)*xi(j);
            for k=1:m
                p(3) = sqrt(2)*standev(3)*xi(k);
                for l=1:m
                    p(4) = sqrt(2)*standev(4)*xi(l);
                    
                    d=0;
                    for n=1:4
                        d = d + p(n).*cos(pi*x*(2*n-1)/(2*L));
                    end

                    f=fnom(x)+d';
    
                    % plot(x,f')
                    
                    u = CalcBeamDisplacement(L, E, Iyy, f, Nelem);
                    s = CalcBeamStress(L, E, r_out, u, Nelem);
    
                    mean = mean + w(i)*w(j)*w(k)*w(l)*s;
                    mean2 = mean2 + w(i)*w(j)*w(k)*w(l)*(s.^2);
                end
            end
        end
    end
    sigma = sqrt(mean2 - mean.^2);
end