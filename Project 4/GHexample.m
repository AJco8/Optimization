
% define function and Gaussian variables
f = @(xi1 ,xi2) (xi1 -2.0) .^2./(1.0 + xi2.^2);
mu1 = 2.0; 
mu2 = -1.0; 
sigma1 = 1; 
sigma2 = 4.0;

% using a 3 point Gauss - Hermite quadrature
xi = [ -1.22474487139; 0.0; 1.22474487139];
wts = [0.295408975151; 1.1816359006; 0.295408975151]./ sqrt (pi) ; % adjusted weights !
mean_f = 0.0;
for i1 = 1: size (xi ,1)
    pt1 = sqrt (2)*sigma1*xi(i1) + mu1;
    for i2 = 1: size (xi ,1)
        pt2 = sqrt (2)*sigma2*xi(i2) + mu2;
        mean_f = mean_f + wts(i1)*wts(i2)*f(pt1 ,pt2);
    end
end

mean_f