clear all; %#ok<CLALL>
close all;
set(0,'DefaultFigureWindowStyle','docked') %Opens figures docked to application (does not open new window)

%Length (wing semi-span)
L = 7.5;%m

%Total mass
m = 500;%kg

%Material Properties (Carbon fiber composite)
%Density
rho = 1600;%kg/m^3
%Young’s modulus 
E = 70e9;%Pa
%Ultimate tensile/compressive strength
Su = 600e6;%Pa

%Constrains
%Inner Radius Minimum
r_min = 1e-2;%m
%Outer Radius Maximum
R_max = 5e-2;%m
%Minimum Thickness
t_min = 2.5e-3;%m
%Total Mass
m_total = 500;%kg

%Force
g = 9.81;%m/s^2
force = 2.5*g*m;
q0 = force/L;

%Design Variables
Nelem_array = 4:2:200;
DV = @(Nelem) DesVars(Nelem,L,q0);

%% Initial Points
Nelem = Nelem_array(1);
Nnode = Nelem+1;
Nvar = 2*(Nnode);
r = zeros([Nvar 1]);
for i=1:2:Nvar
    r(i) = 4.635e-2;
    r(i+1) = R_max;
end
x = 0:L/Nelem:L;
q = q0-x*q0/L;


%Cross Section
csplot = figure('Name','Cross Section',NumberTitle='off');
hold on
title('Cross Section of Spar')
[r_in, r_out] = ExtractRadii(r);
plot(x,r_in,'r-')
plot(x,r_out,'r-')
xlabel('Distance along wing (m)')
ylabel('Height (m)')
ylim([0 0.1])
xlim([0 L])
hold off

%Vertical displacement
uplot = figure('Name','Displacement',NumberTitle='off');
hold on
Iyy = MoI(r);
[u] = CalcBeamDisplacement(L, E, Iyy, q, Nelem);
plot(x,u(1:2:2*(Nelem+1)),'r');
xlabel('Distance along wing (m)')
ylabel('Vertical displacement')
title('Displacement of Spar')
xlim([0 L])
hold off

%Stresses
splot = figure('Name','Stress',NumberTitle='off');
hold on
title('Stress')
[s] = CalcBeamStress(L, E, r_out, u, Nelem);
plot(x,s,'r')
xlabel('Distance along wing (m)')
ylabel('Normal Stress')
xlim([0 L])
hold off

%% Mesh Convergence Study
mesh = figure('Name','Mesh','NumberTitle','off');
hold on

s_tip = zeros(size(Nelem_array));
m_array = zeros(size(Nelem_array));
for i=1:size(Nelem_array,2)
    Nelem=Nelem_array(i);
    [r,~,q] = DV(Nelem);
    m_array(i) = Objective(L, r, rho, Nelem); 

    Iyy = MoI(r);
    [u] = CalcBeamDisplacement(L, E, Iyy, q, Nelem);
    [~,zmax] = ExtractRadii(r);
    [s] = CalcBeamStress(L, E, zmax, u, Nelem);
    s_tip(i) = s(end); 
end

title('Mesh Convergence Study')
xlabel("Number of Elements")

yyaxis left
plot(Nelem_array,s_tip)
ylabel("Stress")
%ylim([0 6])

yyaxis right
pdiff = abs(PercentDifference(s_tip));
plot(Nelem_array,pdiff)
ylabel("Percent Change (%)")
%ylim([0 6])
hold off

%% Optimization
Nelem = Nelem_array(find(pdiff < 5,1));
[r,x,q,Nnode,Nvar] = DV(Nelem);

%Inequality Matrix
Aineq = zeros([Nnode Nvar]);
for i=0:Nnode-1
    Aineq(i+1,i*2+1)=1;
    Aineq(i+1,i*2+2)=-1;
end
bineq = ones([Nnode 1])*-t_min;

%Upper and Lower bounds
lb = zeros([Nvar 1]);
ub = zeros([Nvar 1]);
for i=1:2:Nvar
    %Inner Radius
    lb(i) = r_min;
    ub(i) = R_max-t_min;
    %Outer radius
    lb(i+1) = r_min+t_min;
    ub(i+1) = R_max;
end

obj=@(r)ObjectiveCS(L,r,rho,Nelem);
noncon=@(r)nonlin(r,Su,L,E,q,Nelem);
options = optimoptions('fmincon','SpecifyObjectiveGradient',true,'SpecifyConstraintGradient',true,'Display','iter','Algorithm','sqp','OutputFcn',@outfun);
[r_opt,fval] = fmincon(@(r) obj(r),r,Aineq,bineq,[],[],lb,ub,noncon,options);

%% Optimized
%Plot Feasibility
fplot = figure(Name='Feasibility',NumberTitle='off');
hold on
title('Optimization')
xlabel('Iteration') 
lastiter = find(feashistory == 0,1,'last');
feas = feashistory(lastiter:end);
optim = optimhistory(lastiter:end);
iter = 1:size(feas);
semilogy(iter,feas)
semilogy(iter,optim)
legend('Feasibility','First Order Optimality')
hold off

%Cross Section
figure(1)
hold on
[r_in, r_out] = ExtractRadii(r_opt);
plot(x,r_in,'b-')
plot(x,r_out,'b-')
legend('Original','','Optimized','')
hold off

%Optimized Displacement
figure(2)
hold on
Iyy = MoI(r_opt);
[u] = CalcBeamDisplacement(L, E, Iyy, q, Nelem);
plot(x,u(1:2:2*(Nelem+1)),'b');
legend("Original","Optimized")
hold off

%Optimized Stresses
figure(3)
hold on
[s] = CalcBeamStress(L, E, r_out, u, Nelem);
plot(x,s,'b')
legend("Original","Optimized")
hold off

%% Geometry
geo = figure(6);
[X,Y,Z] = cylinder(r_opt);
surf(X,Z*L,Y)
ylim([0 L])
xlim([-.5 .5])
zlim([-.5 .5])
view([-260 30])
zlabel('Radius (m)')
xlabel('Radius (m)')
title('3D Model of Spar')

%% Save Plots
saveas(uplot, 'Plots/Displacement.png');
saveas(splot, 'Plots/Stress.png');
saveas(mesh, 'Plots/Mesh.png');
saveas(fplot, 'Plots/Feasibility.png');
saveas(csplot, 'Plots/Cross Section.png');
saveas(geo, 'Plots/Geometry.png');

fval %Prints final weight to command window

function [r,x,q,Nnode,Nvar] = DesVars(Nelem,L,q0)
% Returns the 
    Nnode = Nelem+1;
    Nvar = 2*(Nnode);
    r = zeros([Nvar 1]);
    for i=1:2:Nvar
        %Initial Values
        r(i) = 4.635e-2;
        r(i+1) = 5e-2;
    end
    x = 0:L/Nelem:L;
    q = q0-x*q0/L;
end