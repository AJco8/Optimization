function x = samples(n)
%Produces Latin Hypercube Samples for the design variables between the
%upper and lower bounds
%Inputs:
%   n = number of samples
%Outputs:
%   x = matrix of samples
    %lower bounds
    lb = [3*(2*pi/60),0.1,0];
    %upper bounds
    ub = [8*(2*pi/60),1.5,0.3];  
    x = (ub-lb).*lhsdesign(n,3)+lb;
    x = sort(x);
end