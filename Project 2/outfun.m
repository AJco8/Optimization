function stop = outfun(x,optimValues,state)
%Saves the feasibility and first order optimality from fmincon function
    stop=false;
    persistent optimality feasibility;
    switch state
        case 'init'
            try
                optimality;
                feasibility;
            catch
                optimality = [];
                feasibility = [];
            end
        case 'iter'
            optimality = [optimality; optimValues.firstorderopt];
            feasibility = [feasibility; optimValues.constrviolation];
        case 'done'
            assignin('base','optimhistory',optimality);
            assignin('base','feashistory',feasibility);
        otherwise
    end
end