% Generates plot of feasibility and first-order optimality from the output of fmincon function
%
% fmincon output:
% Iter  Func-count            Fval   Feasibility   Step Length       Norm of   First-order  
%                                                                       step    optimality
%    0          11    3.468315e-05     0.000e+00     1.000e+00     0.000e+00     2.389e-03  
%    1          22    3.468057e-05     5.204e-18     1.000e+00     6.421e-06     5.235e-06  
%    2          33    3.467686e-05     1.561e-17     1.000e+00     7.072e-06     2.998e-06  
%    3          34    3.467686e-05     1.561e-17     7.000e-01     9.984e-18     4.608e-19  
%Iterations
iter = [0,1,2,3];
%Feasibility 
f = [0,5.204e-18, 1.561e-17, 1.561e-17];
%First-Order Optimality
foo = [2.389e-03, 5.235e-06, 2.998e-06, 4.608e-19];

%Plot Feasibility
%Feasibility
fig = figure();
semilogy(iter,f)
hold on
semilogy(iter,foo)
title('Optimization Convergence Plot')
legend('Feasibility','First Order Optimality')
xlabel('Iteration') 
saveas(fig, 'Feasibility.png');
