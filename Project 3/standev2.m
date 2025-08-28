function dev = standev2(w,r2,a1,T) %dphi_dt
%STANDEV Summary of this function goes here
%   Detailed explanation goes here
    a0=0.036;%rads
    r1=4.3;%m
    g=9.81;
    Q0=20;
    gamma = 1/(3*w)*sqrt(g/r2);
    epsilon = r1/(9*r2);
    [t,y] = ode45(@F,[0 T],[0; 0]);
    %std of y(2,:)
    yb = trapz(t,y(:,2))/T;
    dev = 3*w*sqrt(trapz(t,(y(:,2)-yb).^2)/T);
    function y = F(t,y)
        tau = t;%3*w;
        alpha = a0-a1*cos(tau);
        beta = 3*a1*sin(tau);
        %Equation 27
        d2p_dt2 = -(gamma/Q0*y(2) + (epsilon-gamma^2*alpha)*sin(y(1)) + gamma^2*beta*cos(y(1)) );
        y = [y(2); d2p_dt2];
    end
end