function [x,fval] = Optimize(inputArg1,inputArg2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    Nnode = Nelem+1;
    Nvar = 2*(Nnode);
    r = zeros([Nvar 1]);
    for i=1:2:Nvar
        r(i) = r_min;
        r(i+1) = R_max;
    end

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

    obj=@(r)Objective(L,r,rho,Nelem);
    options = optimoptions('fmincon','Display','iter','Algorithm','sqp','OutputFcn',@outfun);
    [x,fval] = fmincon(obj,r,Aineq,bineq,[],[],lb,ub,@(r) nonlin(r,Su,L,E,force,Nelem),options);
    
end