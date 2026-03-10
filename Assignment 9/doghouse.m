function doghouse(C_L_max,S,C_D0,AR,W,Swp_w,t_c_w)

    u = symunit; % Initialise symbolic units object
    function output = ul(input)
        output = double(separateUnits(input));
    end

    function output = iul(input, unit, unit2)
        if nargin == 1  % Symbolic input, simple unit conversion
            output = double(separateUnits(unitConvert(input,'US')));
        elseif nargin == 2  % Symbolic input, complicated unit conversion
            output = double(separateUnits(unitConvert(input, unit)));
        else    % double input (undesired)
            output = double(separateUnits(unitConvert(input*unit, unit2)));
        end
    end

    %% initialization
    num_it = 50;
    v_sound = Atm.sonic_speed(20000*u.ft);
    rho = Atm.density(20000*u.ft);
    
    mach = linspace(0.1,2.3,num_it);
    v_sound = v_sound * u.m / u.s;

    rho = rho * u.kg / (u.m^3);
    g = 9.81 * u.m / u.s^2;
    
    %% Basic computation
    V = mach .* v_sound;    % Velocity ranging from mach 0.3 to 2.3 in metric units
    q = rho .* V.^2 / 2;    % Dynamic pressure for given V range
    C_L_max = 1.5; % This change will be formally introduced to the parameters.copy (definite change), temporary fix for git convenience 
    L = 1/2 * rho .* V.^2 * S * C_L_max;    % Maximum lift for given V range
    R = [2500 4500 8000 13000] .* u.m;  % Turn radius in m
    K = K_find_matrix(mach,ul(AR),ul(Swp_w),ul(t_c_w),ul(W),ul(unitConvert(20000*u.ft,'SI')),ul(S));
    C_D = C_D0 + C_L_max^2.*K;
    T = 2 * 191E3 * (Atm.density(20000*u.ft)/Atm.density(0))^0.7 * (1 - 0.35 .* mach) * u.kg * u.m / u.s^2;%191E3 * u.kg * u.m / u.s^2; %1/2 * rho .* V.^2 * S .* C_D;    % Assumed Ps = 0
    
    W_new = W * g;  % n equations treat W as weight(N)
    
    %% n (load factor) for different constraints
    n =  L/W_new; %% LOAD FACTOR, DON'T OVERWRITE
    n_sust = sqrt((T./q./S- C_D0) ./ K) .* (q*S) / W_new;
    n_max = 7.5; %max(n); % Apparently from the RFP %q*C_L_max/(W/S);
    n_var = [1.5 3 5 7.5];
    n(ul(n)>ul(n_max)) = n_max;
    
    V_corner = sqrt(2*n_max*g*W/(rho*S*C_L_max));   % Denoted as V* in the slides
    
    %% Turn rate computation
    w_load = g * sqrt(n.^2-1) ./ V; % main rate
    w_corner = g * sqrt(n_max^2-1) / V_corner;  % marker
    w_sust = g * sqrt(n_sust.^2-1) ./ V;
    w_struct = g * sqrt(n_max.^2-1) ./ V;

    max_w = 25;

    w_range = linspace(0,max_w,num_it); % row vector

    q_m = repmat(ul(q)',1,num_it);
    V_m = repmat(ul(V)',1,num_it);
    T_m = repmat(ul(T)',1,num_it);
    K_m = repmat(K',1,num_it);

    n_2 = ul(1 + (deg2rad(w_range) .* V_m ./ ul(g)) .^2);
    T_Ps = T_m; %2* 191E3 * ones(num_it, num_it);
    CL_base = ul(W_new) ./ (q_m .* ul(S));
    CL_2 = n_2 .* (CL_base.^2);
    D = q_m .* ul(S) .* (C_D0 + K_m .* CL_2);
    %D = ul(S) * q_m .* (C_D0 + n_2 .* K_m * (ul(W_new) ./ (q_m * ul(S))).^2);
    Ps = V_m .* (T_Ps - D) ./ ul(W_new);

    for machNo = 1:1:num_it
        Ps_sp = Ps(machNo,:);
        w_range_invalid = w_range > rad2deg(ul(w_load(machNo)));
        Ps_sp(w_range_invalid) = NaN;
        Ps(machNo,:) = Ps_sp;
    end

    Ps = iul(Ps, u.m, u.ft);

    sust_range = find(ul(n_sust)<ul(n),1,'first');
    
    %% Plots
    figure()
    hold on
    area(mach,rad2deg(real(ul(w_load))),'EdgeColor','none','FaceColor',[0.95 0.9 0.95])
    plot(mach, rad2deg(real(ul(w_load))), "LineWidth",2)   % Inst. turn feasible value
    plot(mach(sust_range:num_it), rad2deg(ul(w_sust(sust_range:num_it))), "LineWidth",2,"LineStyle","--")         % Sustained limit"
    plot(ul(V_corner/v_sound),  rad2deg(ul(w_corner)), 'LineStyle','none','Marker','.')     % corner velocity 
    text(ul(V_corner/v_sound), rad2deg(ul(w_corner)), "\leftarrow "+string(rad2deg(ul(w_corner)))+" deg/s")
    plot(mach, rad2deg(ul(w_struct)), "LineWidth",2,"LineStyle","-.")       % Stuctural limit
    text(mach(sust_range),rad2deg(ul(w_sust(sust_range))) , "\leftarrow "+string(rad2deg(ul(w_sust(sust_range))))+" deg/s")
    for var = n_var
        w_var = rad2deg(ul(g * sqrt(var.^2-1) ./ V));
        plot(mach, w_var, 'LineStyle',':','color', [0.7 0.7 0.7])
        text(mach(20), w_var(20),'n = '+string(var)+'g','Color',[0.7 0.7 0.7])
    end
    for r = R
        w_radius = rad2deg(ul(V ./ r));  
        plot(mach, w_radius, 'LineStyle','--','color', [0.7 0.7 0.7])
        text(mach(num_it), w_radius(num_it),'R = '+string(ul(r))+' m','Color',[0.7 0.7 0.7])
    end
    contour(mach, w_range, Ps', [-600 -400 -200 100 200 400], "ShowText","on","labelformat","%.0f FPS", 'LineStyle','--', 'EdgeColor', 'k')
    ylim([0 40])
    lgd = legend("Instantaneous turn feasible value","Inst. turn feasible value","Sustained limit","corner velocity","Stuctural limit",'','','','','','','','Location','bestoutside');
    title("Advanced Doghouse plot with afterburner at altitude 20,000ft")
    xlabel("Mach number (M)")
    ylabel("Turn rate (deg/s)")
    grid on 
    grid minor
    hold off
end