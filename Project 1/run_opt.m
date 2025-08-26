%Main File
%Finds optimal shape of heat exchanger and plots the flux found at
%different number of sections.
clear all; %#ok<CLALL>
close all;

%Given Parameters

%Length of section
L = 0.05;%m

%Thermal Conductivity 
K = 20;%W/mK

%Temperature of the Water
T_water = 90;%degrees C

%Temperature of the air
T_air = 20;%degrees C

%Height
h_max = 0.05;%m
h_min = 0.01;%m 

%Number of elements
Nx = 800;

%Points along the x-axis
x = (0:L/Nx:L);

%Initial Design Variables
nvar = 10; % number of design variables
a_0 = zeros([nvar,1]); 
a_0(1) = (h_max+h_min)/2;
a_0(end) = 0.02;

%A and b inequality
[Aineq,bineq] = ineq(Nx,nvar,x,L,h_min,h_max);

%Anonymous Functions
%Height given a, with set values for x and L
h = @(a) height_array(x,a,L);
%Objective Function given a, with set values for L, Nx, K, T_air, T_water
obj = @(a) objective(h(a),L,Nx,K,T_air,T_water);

%fmincon function call
options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
[a_opt,fval] = fmincon(obj,a_0,Aineq,bineq,[],[],[],[],[],options);

%Optimal Height
h_opt = height_array(x,a_opt,L);
a_opt

%Plot Height
f1 = figure(1);
%Original Height
plot(x,height_array(x,a_0,L))
hold on
%Optimized Height
plot(x,h_opt)
title('Shape of Section')
legend('Original','Optimized')
xlim([0 L])
ylim([0 h_max+h_min])
xlabel('X (meters)')
ylabel('Height (meters)')
saveas(f1, ['Height N=' N '.png']);
hold off

%Mesh Convergence Study
%Array of Nx values to test
N_array = [0.5,1,2,4,6,8,10]*100;
flux = zeros([size(N_array,2) 1]);
for i = 1:size(N_array,2)
    N=N_array(i);
    x = (0:L/N:L);
    obj = @(a) objective(height_array(x,a_0,L),L,N,K,T_air,T_water);
    [Aineq,bineq] = ineq(N,nvar,x,L,h_min,h_max);
    [a_opt, fval] = fmincon(obj,a_0,Aineq,bineq);
    flux(i)=1/fval;
end
%Plot of flux at Nx values
f2 = figure(2);
plot(N_array,flux,'r*')
title("  Mesh Convergence")
xlabel('Number of Sections')
ylabel('Flux (W/m)') 
xlim([0 1000])
saveas(f2, 'Flux.png');

%Functions
function h = height(x,a,L)
% produces the height at an x position
% h(x) function in notes
% Inputs:
%   x - position in x direction
%   L - length of domain in x direction
%   a - design variables
% Outputs:
%   h - height at x
    h = a(1);
    for k = 2:size(a,1)
        h = h + a(k)*sin(2*pi*(k-1)*x/L);
    end
end

function h = height_array(x,a,L)
% produces an array of heights at all x positions
% Inputs:
%   x - positions in x direction
%   L - length of domain in x direction
%   a - design variables
% Outputs:
%   h - array of heights
    h = zeros(size(x))';
    for i = 1:size(x,2)
        h(i) = height(x(i),a,L);
    end
end

function [Aineq,bineq] = ineq(Nx,nvar,x,L,h_min,h_max)
% produces the A maxrix and the b vector needed to create the inequality
% matrix (Ax<b)
% Inputs:
%   Nx - Number of elements along x-axis
%   nvar - the number of design variables
%   x - positions in x direction
%   L - length of domain in x direction
%   h_min - the minimum height constraint
%   h_max - the maximum height constraint
% Outputs:
%   Aineq - A-inequality maxrix 
%   b - b-inequality vector
    Aineq = zeros(2*(Nx+1),nvar);
    bineq = zeros(2*(Nx+1),1);
    for i = 1:(Nx+1)
      Aineq(i,1) = 1.0;
      for k = 2:nvar
        Aineq(i,k) = sin(2*pi*(k-1)*x(i)/L);
      end
      bineq(i) = h_max; % upper bound
      ptr = Nx+1;
      Aineq(ptr+i,1) = -1.0;
      for k = 2:nvar
        Aineq(ptr+i,k) = -sin(2*pi*(k-1)*x(i)/L); 
      end
      bineq(ptr+i) = -h_min; % lower bound
    end
end