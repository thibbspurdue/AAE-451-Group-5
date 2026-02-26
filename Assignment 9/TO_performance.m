function TO_performance(W,S,C_L_max,C_D0,AR,e,g)
    u = symunit; % Initialise symbolic units object

    [~,~,~,rho,~,visc] = atmosisa(0); 
    tspan = [0 2.5];
    IC = 0;
    v_wod = 0;   % Refer to RFP 
    rho = rho * u.kg / u.m^3;

    E_cat = 60.5E6 * u.ft * u.lbf;
    L_cat = 310 * u.ft;
    F_cat = unitConvert(E_cat / L_cat,'SI');

    pass = struct;
    varlist = {'W','S', 'C_L_max', 'C_D0', 'AR', 'e', 'g','v_wod','visc', 'rho', 'F_cat'};
    for i = 1:length(varlist)
        pass.(varlist{i}) = double(separateUnits(eval(varlist{i})));
    end
    [t, vg] = ode45(@(t,vg) toFunc(t,vg,pass), tspan, IC);
    va = vg + v_wod;
    V_stall = sqrt(2*W*g/(rho*S*C_L_max));
    d = cumtrapz(t, va);
    
    % Work on plotting later on
    figure()
    plot(d, va)
    yline(1.2*V_stall)
    xline(double(separateUnits(unitConvert(L_cat, 'SI'))))
    
    clear dvdt

    function dvgdt = toFunc(~, vg, pass)
        persistent dvdt
        if isempty(dvdt)
            dvdt = 0;
        end
        W = pass.W; rho = pass.rho; S = pass.S; C_L_max = pass.C_L_max; C_D0 = pass.C_D0; v_wod = pass.v_wod; AR = pass.AR; e = pass.e; visc = pass.visc; g = pass.g; F_cat = pass.F_cat;
        va = vg + v_wod;
        C_D = 0.2427; % From assignment 6
        eta_TO = C_D - visc * C_L_max;
        
        T = 2 * W * g * (eta_TO * 1/2 * rho * va^2 * S / W + visc + dvdt / g); % From mattingly 
        if T > 2 * 191E3
            T = 2 * 191E3;
        end

        L = 1/2 * rho * va^2 * S * C_L_max; % Is C_L going to be function of something? Do I need to call a function for this?
        D = 1/2 * rho * va^2 * S * C_D;

        mu = 0.03;  % friction coefficient, from Raymer p. 672
        Fr = mu* (W*g-L);
    
        dvgdt = double(separateUnits(1/W*(T + F_cat - D - Fr)));
        dvdt = dvgdt;
    end
end