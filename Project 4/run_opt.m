%% Initialize
clear all;
close all;
set(0,'DefaultFigureWindowStyle','docked')

% Length (wing semi-span)
L = 7.5;%m
% Total mass
m = 500;%kg

%% Material Properties (Carbon fiber composite)
% Density
rho = 1600;%kg/m^3
% Young’s modulus 
E = 70e9;%Pa
% Ultimate tensile/compressive strength
Su = 600e6;%Pa

%% Constrains
% Inner Radius Minimum
r_min = 1e-2;%m
% Outer Radius Maximum
R_max = 5e-2;%m
% Minimum Thickness
t_min = 2.5e-3;%m
% Design Variables
Nelem_array = 4:2:200;
DV = @(Nelem) DesVars(Nelem,L);
stress = @(r, force, Nelem) sigma(r, force, Nelem, L, E);
        
%% Initial
Nelem = 30;
[r,x] = DV(Nelem);
[r_in,r_out]=ExtractRadii(r);
Iyy = CalcSecondMomentAnnulus(r_in, r_out);

[mean,sigma] = Perturbation(r, x, L, E, Nelem);
u = CalcBeamDisplacement(L, E, Iyy, fnom(x), Nelem);
s = CalcBeamStress(L, E, r_out, u, Nelem);
nomplot = figure(Name="Nominal Stress",NumberTitle="off");
plot(x,s)
hold on
plot(x,mean)
plot(x,mean+6*sigma)
plot(x,mean-6*sigma)
legend('f_{nom}','f_{nom}+\delta_{f}(x,\xi)','+6\sigma','-6\sigma')
xlabel('y')
ylabel('Stress')
title('Nominal Spar')
hold off

%% Mesh Convergence Study
s_tip = zeros(size(Nelem_array));
pdiff = zeros(size(Nelem_array));
pdiff(1) = NaN;
for i=1:size(Nelem_array,2)
    Nelem=Nelem_array(i);
    [r,x] = DV(Nelem);
    [r_in,r_out] = ExtractRadii(r);

    Iyy = CalcSecondMomentAnnulus(r_in,r_out);
    [u] = CalcBeamDisplacement(L, E, Iyy, fnom(x), Nelem);
    [s] = CalcBeamStress(L, E, r_out, u, Nelem);
    s_tip(i) = s(end); 
    if i>1
        pdiff(i)=abs(200*(s(end)-s_tip(i-1))/(s(end)+s_tip(i-1)));
    end
end

mesh = figure(Name='Mesh',NumberTitle='off');
hold on
title('Mesh Convergence Study')
xlabel("Number of Elements")

yyaxis left
semilogy(Nelem_array,s_tip)
% set(gca, 'YDir','reverse')
ylabel("Stress")
ylim([-1e6 0])

yyaxis right
plot(Nelem_array,pdiff)
ylabel("Percent Change (%)")
ylim([0 100])
hold off

Nelem = Nelem_array(find(pdiff < 10,1))
[r,x,Nnode,Nvar] = DV(Nelem);

%% Optimization
fun = @(r) SparWeight(r, L, rho, Nelem);
nonlcon = @(r) WingConstraints(r, L, E, fnom(x), Su, Nelem);
lb = 0.01*ones(2*(Nelem+1),1);
up = 0.05*ones(2*(Nelem+1),1);
A = zeros(Nelem+1,2*(Nelem+1));
b = -0.0025*ones(Nelem+1,1);
for k = 1:(Nelem+1)
    A(k,k) = 1.0;
    A(k,Nelem+1+k) = -1.0;
end

% define initial guess (the nominal spar)
r0 = zeros(2*(Nelem+1),1);
r0(1:Nelem+1) = 0.04625*ones(Nelem+1,1);
r0(Nelem+2:2*(Nelem+1)) = 0.05*ones(Nelem+1,1);

options = optimset('GradObj','on','GradConstr','on', 'TolCon', 1e-4, 'TolX', 1e-8, 'Display','iter', 'Algorithm', 'active-set','OutputFcn',@outfun); %, 'DerivativeCheck','on');
[ropt,fval,exitflag,output] = fmincon(fun, r0, A, b, [], [], lb, up, nonlcon, options);

%% Optimized
% Feasibility
fplot = figure(Name="Feasibility",NumberTitle="off");
hold on
title('Optimization')
xlabel('Iteration') 
% lastiter = find(feashistory == 0,1,'last');
feas = feashistory;%(lastiter:end);
optim = optimhistory;%(lastiter:end);
iter = 1:size(feas,1);
semilogy(iter,feas)
semilogy(iter,[NaN;optim])
legend('Feasibility','First Order Optimality')
hold off

% Cross Section
csplot = figure(Name="Cross Section",NumberTitle="off");
hold on
[r_in, r_out] = ExtractRadii(ropt);
plot(x,r_in/1e-2,'b')
plot(x,r_out/1e-2,'b')
xlabel('Length (m)')
ylabel('Distance from center (cm)')
hold off

% Displacement
uplot = figure(Name="Displacement",NumberTitle="off");
hold on
Iyy = CalcSecondMomentAnnulus(r_in, r_out);
u = CalcBeamDisplacement(L, E, Iyy, fnom(x), Nelem);
plot(x,u(1:2:2*(Nelem+1)),'b');
xlabel('Length (m)')
ylabel('Displacement')
hold off

% Stresses
[mean,sigma] = Perturbation(ropt, x, L, E, Nelem);
s = CalcBeamStress(L, E, r_out, u, Nelem);
splot = figure(Name="Stress",NumberTitle="off");
plot(x,s)
hold on
plot(x,mean)
plot(x,mean+6*sigma)
plot(x,mean-6*sigma)
legend('f_{nom}','f_{nom}+\delta_{f}(x,\xi)','+6\sigma','-6\sigma')
xlabel('Length (m)')
ylabel('Stress (Pa)')
title('Optimized Spar')
hold off

% Geometry
geo = figure(NumberTitle="off",Name='Model');
[X,Y,Z] = cylinder(r_out);
surf(X,Z*L,Y)
ylim([0 L])
xlim([-.5 .5])
zlim([-.5 .5])
view([-260 30])
zlabel('Radius (m)')
xlabel('Radius (m)')
title('3D Model of Spar')

%% Final Values
fval
proj2 = 4.9;
fval-proj2
200*(fval-proj2)/(fval+proj2)

%% Save
saveas(uplot, 'Plots/Displacement.png');
saveas(splot, 'Plots/Stress.png');
saveas(mesh, 'Plots/Mesh.png');
saveas(fplot, 'Plots/Feasibility.png');
saveas(csplot, 'Plots/Cross Section.png');
saveas(geo, 'Plots/Geometry.png');
saveas(nomplot, 'Plots/Nominal.png');
% save opt.mat

%% Functions
% Design Variables
function [r,x,Nnode,Nvar] = DesVars(Nelem,L)
% Returns the Design Variables
    Nnode = Nelem+1;
    Nvar = 2*(Nnode);
    r = zeros(2*(Nelem+1),1);
    r(1:Nelem+1) = 0.04625*ones(Nelem+1,1);
    r(Nelem+2:2*(Nelem+1)) = 0.05*ones(Nelem+1,1);
    x = 0:L/Nelem:L;
end