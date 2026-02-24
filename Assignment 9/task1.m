function task1
    u = symunit; % Initialise symbolic units object

    function output = ul(input)
        output = double(separateUnits(input));
    end

    tspan = linspace(0,100,1000);
    IC = 0;
    v_wod = 0;   % Refer to RFP
    
    [t vg] = ode45(@toFunc, tspan, IC);
    
    va = vg + v_wod;
    d = vg .* t;
    
    % Work on plotting later on
    figure()
    plot(d, va)

    function dvgdt = toFunc(t, vg)
        varsToImport = {'T', 'm', 'W', 'rho', 'S', 'C_L_max', 'C_D0', 'v_wod', 'AR', 'e'};  % e will ACT OUT. figure out what to do with it. either run A8 or just derive constant value and hard-code it in.
        for i = 1:length(varsToImport)
            varName = varsToImport{i};
            assignin('caller', varName, evalin('base', varName));
        end
        va = vg + v_wod;
        C_D = C_d0 + C_L_max/(pi*AR*e);

        L = 1/2 * rho * va^2 * S * C_L_max; % Is C_L going to be function of something? Do I need to call a function for this?
        D = 1/2 * rho * va^2 * S * C_D;
        Fcat = Unitconvert(60.5E6 * u.ft * u.lbf, 'SI');
        mu = ;  % friction coefficient
        Fr = mu* (W-L);
    
        dvgdt = 1/m*(T + Fcat - D - Fr);
    end
end