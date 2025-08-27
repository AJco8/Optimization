%% Mesh Convergence Study
load run_opt rho DV
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