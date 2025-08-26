function f = MeshConverge(x,a,L,Nx,K,T_air,T_water)
    obj = @(a) objective(height_array(x,a,L),L,Nx,K,T_air,T_water);
    for i = 1:5
        [a_opt, fval] = fmincon(obj,a_0,Aineq,bineq,[],[],[],[],[],options);
    end
end