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

%Start with 10, try 100 later
%Or are we suppoesed to track output as N changes
Nx = 10;
Ny = Nx;
x = (0:L/Nx:L).';

%Initial Design Variables
a = ones([Nx+1,1])*(h_max+h_min)/2;
a(end) = 0.02;

%A and b inequality
nvar = size(a,1); % number of design variables
Aineq = zeros(2*(Nx+1),nvar);
bineq = zeros(2*(Nx+1),1);
for i = 1:(Nx+1)
  % first, the upper bound
  Aineq(i,1) = 1.0; % this coefficient corresponds to variable a_1
  for k = 2:nvar
    Aineq(i,k) = sin(2*pi*(k-1)*x(i)/L); % this coefficient corresponds to variable a_k
  end
  bineq(i) = 0.05; % the upper bound value
  % next, the lower bound; we use ptr to shift the index in Aineq and bineq
  ptr = Nx+1;
  Aineq(ptr+i,1) = -1.0; % note the negative here!!! fmincon expects inequality in a form A*x < b
  for k = 2:nvar
    Aineq(ptr+i,k) = -sin(2*pi*(k-1)*x(i)/L); % again, a negative
  end
  bineq(ptr+i) = -0.01; % negative lower bound
end

height = @(a) a.*Aineq';
%h = height_array(x,a,L);
plot(x,height(a))%Mesh Convergence plot?

options = optimoptions('fmincon','Display','iter','Algorithm','active-set');
[a_opt, fval] = fmincon(@(a) objective(a,L,Nx,Ny,k,T_air,T_water),a(1),Aineq,bineq);%,[],[],[],[],[],options);

%Optimal Height
h_opt = height_array(x,a_opt,L);

%Plot Height
plot(x',h_opt')
xlim([0 L])
xlabel('X (meters)')
ylabel('Height (meters)')

%Functions
function h = height_array(x,a)
    h = zeros([size(a,1) 1]);
    for i = 1:size(x,1)
        h(i) = height(x(i));
    end
end

function [f] = objective(h,L,Nx,Ny,K,Ttop,Tbot)
    [flux,~,~,~] = CalcFlux(L, h, Nx, Ny, K, Ttop, Tbot);
    f = 1/flux;
end

