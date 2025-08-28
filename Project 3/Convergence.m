T_array = 2:5000;
s = zeros([1,size(T_array,2)]);

for i=T_array
    s(i-1)=standev2(w_nom,r2_nom,a1_nom,i);
end
ave = mean(s)

figure(Name="Convergence",NumberTitle='off')
yyaxis left
plot(T_array,s)
ylabel("\sigma(\phi')")

yyaxis right
plot(T_array,diff)
ylabel("% Difference")
xlabel('T')