function task2(C_L_max,S,C_D0,AR,e,W)
    %% Will be deleted in the future
    u = symunit; % Initialise symbolic units object

    function output = ul(input) % I think there is a difference between ul(global) and ul(local), as the code behaves very differently when commented out. Might want to look into that.
        output = double(separateUnits(input));
    end
    %% initialization
    % PLEASE TELL ME HOW ATM WORKS I CAN'T FIND WHERE THE FUNCTION IS IN
    % DIRECTORY ;_;
    [~,v_sound,p,rho,~,~] = atmosisa(ul(20000*u.ft)); 
    [~,~,p_sl,~,~,~] = atmosisa(0);
    num_it = 100;
    
    mach = linspace(0.3,2.3,100);
    p_sl_st = p_sl * (1 + 0.4/2 .* mach.^2) .^ (1.4/0.4);
    p_st = p * (1 + 0.4/2 .* mach.^2) .^ (1.4/0.4);
    a = 0.6 * p_st ./ p_sl_st;
    
    v_sound = v_sound * u.m / u.s;
    p = p * u.pa;
    rho = rho * u.kg / (u.m^3);
    g = 9.81 * u.m / u.s^2;
    
    %% Basic computation
    V = mach .* v_sound;    % Velocity ranging from mach 0.3 to 2.3 in metric units
    q = rho .* V.^2 / 2;    % Dynamic pressure for given V range
    L = 1/2 * rho .* V.^2 * S * C_L_max;    % Maximum lift for given V range
    R = [2500 4500 8000 13000] .* u.m;  % Turn radius in m
    C_D = C_D0 + C_L_max/(pi*AR*e); % Coefficient of drag as f(C_L(V)) <- since it is well above subsonic range, I might need second person to look over this
    T = 1/2 * rho .* V.^2 * S * C_D;    % Assumed Ps = 0
    K = 1 / (pi * AR * e);  % Derived from assignment 8 (further references unknown)
    
    W_new = W * g;  % n equations treat W as weight(N)
    
    %% n (load factor) for different constraints
    n =  L/W_new; %% LOAD FACTOR, DON'T OVERWRITE
    n_sust = sqrt((T./q./S- C_D0) ./ K);
    n_max = 7.5; %max(n); % Apparently from the RFP %q*C_L_max/(W/S);
    n_var = [1.5 3 5 7.5];
    n(ul(n)>ul(n_max)) = n_max;
    
    V_corner = sqrt(2*n_max*g*W/(rho*S*C_L_max));   % Denoted as V* in the slides
    
    %% Turn rate computation
    w_load = g * sqrt(n.^2-1) ./ V; % main rate
    w_corner = g * sqrt(n_max^2-1) / V_corner;  % marker
    w_sust = g * sqrt(n_sust.^2-1) ./ V;
    w_struct = g * sqrt(n_max.^2-1) ./ V;
    
    %% Plots
    figure()
    hold on
    area(mach,rad2deg(real(ul(w_load))),'EdgeColor','none','FaceColor',[0.95 0.9 0.95])
    plot(mach, rad2deg(real(ul(w_load))))   % Inst. turn feasible value
    plot(mach, rad2deg(ul(w_sust)))         % Sustained limit"
    plot(ul(V_corner/v_sound),  rad2deg(ul(w_corner)), 'LineStyle','none','Marker','.')     % corner velocity 
    text(ul(V_corner/v_sound), rad2deg(ul(w_corner)), "\leftarrow "+string(rad2deg(ul(w_corner)))+" deg/s")
    plot(mach, rad2deg(ul(w_struct)))       % Stuctural limit
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
    ylim([0 15])
    lgd = legend("Instantaneous turn feasible value","Inst. turn feasible value","Sustained limit","corner velocity",'',"Stuctural limit",'','','','','','','Location','bestoutside');
    title("Advanced Doghouse plot with afterburner at altitude 20,000ft")
    xlabel("Mach number (M)")
    ylabel("Turn rate (deg/s)")
    grid on 
    grid minor
    hold off
    
    % Current issues
    
    % extremely low n, may want to look into lift coefficient validity <- we
    % never reach n_max, either better airfoil or smth else
    % extremely low T, given Ps = 0, T=D; which means either D is too low, qS
    % is too high, C_D0 is too high, K is too high, etc etc...
end