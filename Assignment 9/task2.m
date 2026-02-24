function task2
    u = symunit; % Initialise symbolic units object

    function output = ul(input)
        output = double(separateUnits(input));
    end
    varsToImport = {'C_L_max'};  % e will ACT OUT. figure out what to do with it. either run A8 or just derive constant value and hard-code it in.
    for i = 1:length(varsToImport)
        varName = varsToImport{i};
        assignin('caller', varName, evalin('base', varName));
    end

    % Atm.() integrated in future date
    [temp,v_sound,p,rho,nu,mu] = atmosisa(separateUnits(unitConvert(20000*u.ft),'SI')); 
    
    v_sound = v_sound * u.m / u.s;
    p = p * u.pa;
    rho = rho * u.kg / (u.m^3);
    
    mach = linspace(0,1.6,1000);
    V = mach .* v_sound;
    V_stall = sqrt(2*W/(rho*S*C_L_max));
    L = 1/2 * rho .* V.^2 * S * C_L_max;
    R = [300 500 1000 2000] .* u.m;
    
    n =  L/W; %% LOAD FACTOR, DON'T OVERWRITE
    n_lift = 1/2 * rho * V_stall.^2 * S * C_L_max / W;
    n_sust = sqrt((T/q/S- C_D0) ./ K);
    n_max = 7.5; % Apparently from the RFP %q*C_L_max/(W/S);
    
    n(n>n_max) = n_max;
    
    V_corner = sqrt(2*n_max*W/(rho*S*C_L_max));
    
    w_radius = V ./ R;
    w_load = g * sqrt(n.^2-1) ./ V;
    w_corner = V_stall / R(1);
end