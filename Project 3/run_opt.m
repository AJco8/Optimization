%% Initialize
clear all; %#ok<CLALL>
close all;
set(0,'DefaultFigureWindowStyle','docked') %Opens figures docked to application

%Initial Values
w_nom = 6.5*pi/30;
r2_nom = 0.8;
a1_nom = 0.058;
x_nom = [w_nom,r2_nom,a1_nom]';

%Constraints
lb = [3*(2*pi/60),0.1,0];%lower bounds
ub = [8*(2*pi/60),1.5,0.3];%upper bounds

%Add GPML directory to path
mydir = '../gpml-matlab-v3.6-2015-07-07/';
addpath(mydir(1:end-1))
addpath([mydir,'cov'])
addpath([mydir,'doc'])
addpath([mydir,'inf'])
addpath([mydir,'lik'])
addpath([mydir,'mean'])
addpath([mydir,'prior'])
addpath([mydir,'util'])

%% Convergence
T_array = 2:5000;
s = zeros([1,size(T_array,2)]);

for i=T_array
    s(i-1)=standev2(w_nom,r2_nom,a1_nom,i);
end

ave_array = zeros([1,size(T_array,2)]);
ave_array(1) = NaN;
for i=2:size(T_array,2)
    ave_array(i)=std(s(1:i));
end

diff = zeros([1,size(T_array,2)]);
diff(1) = NaN;
for i=2:size(T_array,2)
    diff(i) = 200*abs(ave_array(i)-ave_array(i-1))/(ave_array(i)+ave_array(i-1));
end

figure(Name="Convergence",NumberTitle='off')
yyaxis left
hold on
plot(T_array,s)
plot(T_array,ave_array,'r')
ylabel("\sigma(\phi')")
hold off

yyaxis right
hold on
plot(T_array,diff)
ylabel("% Difference")
ylim([-5,10])
hold off
% legend('','\sigma(\phi')','')
xlabel('T')

T = T_array(find(diff(3:end)<0.001,1)+2);

%% Plot

n=2000;
z_matrix = zeros([n,3]);
for i=1:3
    z_matrix(:,i) = lb(i):(ub(i)-lb(i))/(n-1):ub(i);
end

s_matrix = samples(n);
[w,r2,a1] = dv(s_matrix);
y = zeros([n,1]);
for i=1:n
    y(i)=standev(w(i),r2(i),a1(i),T);
end
figure(Name="Deviation",NumberTitle='off')
hold on
plot(w,y)
ylabel("\sigma(\phi')")
xlabel("\omega")
hold off

%% GPML

covfunc = {@covMaterniso, 1};
hyp.cov = [log(1); log(std(y))];

likfunc = @likGauss;
sn = 0.2; %noise level
hyp.lik = log(sn);

hyp = minimize(hyp, @gp, -100, @infExact, [], covfunc, likfunc, s_matrix, y);

figure(Name="Surrogate",NumberTitle='off')
z = z_matrix;

[m, s2] =  gp(hyp, @infExact, [], covfunc, likfunc, s_matrix, y, z);
hold on
f = [m+sqrt(s2); flip(m-sqrt(s2),1)];
z = z_matrix(:,1);
fill([z; flip(z,1)], f, [7 7 7]/8)
plot(w, y)
plot(z, m)
legend('','Real','Surrogate')
ylabel("\sigma(\phi')")
xlabel("\omega")
hold off

%% Optimize

obj = @(x) -surrogate(s_matrix,y,x,hyp,covfunc,likfunc);

options = optimoptions('fmincon','Algorithm','sqp','OutputFcn',@outfun);
[x_opt,fval] = fmincon(obj,x_nom',[],[],[],[],lb,ub,[],options);
[w_opt,a1_opt,r2_opt] = dv(x_opt);

%Feasibility
fplot = figure(Name='Feasibility',NumberTitle='off');
hold on
iter = 1:size(feashistory);
semilogy(iter,feashistory)
semilogy(iter,optimhistory)
title('Optimization')
xlabel('Iteration') 
legend('Feasibility','First Order Optimality')
hold off

%% Final Values
f_nom = standev(w_nom,r2_nom,a1_nom,T);

fprintf('\n\nNominal Values: \n\tw = %d \n\ta1 = %d \n\tr2 = %d',w_nom,a1_nom,r2_nom)
fprintf('\nNominal Deviation: %d',f_nom)
fprintf('\nOptimal Values: \n\tw = %d \n\ta1 = %d \n\tr2 = %d',w_opt,a1_opt,r2_opt)
fprintf('\nMaximized Standard Deviation: %d',-fval)
fprintf('\nTimes the Nominal: %d\%',-fval/f_nom*100)

%% Functions
function mean = surrogate(x,y,z,hyp,covfunc,likfunc) 
    if size(x,1) < size(x,2)
        x = x';
    end
    [mean, ~] = gp(hyp, @infExact, [], covfunc, likfunc, x, y, z);
end

function [w,r2,a1] = dv(x)
    w = x(:,1);
    r2 = x(:,2);
    a1 = x(:,3);
end

