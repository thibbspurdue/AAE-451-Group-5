function TO_performance(W,S,C_L_max,C_D0,AR,e,g)
    u = symunit; % Initialise symbolic units object

    function output = iul(input, unit, unit2)
        if nargin == 1  % Symbolic input, simple unit conversion
            output = double(separateUnits(unitConvert(input,'US')));
        elseif nargin == 2  % Symbolic input, complicated unit conversion
            output = double(separateUnits(unitConvert(input, unit)));
        else    % double input (undesired)
            output = double(separateUnits(unitConvert(input*unit, unit2)));
        end
    end

    [~,~,~,rho,~,visc] = atmosisa(0); 
    tspan = [0 4];
    IC = [0 0];
    v_wod = 0;   % Refer to RFP 
    rho = rho * u.kg / u.m^3;

    E_cat = 60.5E6 * u.ft * u.lbf;
    L_cat = 310 * u.ft;
    F_cat = unitConvert(E_cat / L_cat,'SI');

    pass = struct;
    varlist = {'W','S', 'C_L_max', 'C_D0', 'AR', 'e', 'g','v_wod','visc', ...
               'rho', 'F_cat'};
    for i = 1:length(varlist)
        pass.(varlist{i}) = ul(eval(varlist{i}));
    end
    [t, vg] = ode45(@(t,vg) toFunc(t,vg,pass), tspan, IC);
    va = vg + v_wod;
    V_stall = sqrt(2*W*g/(rho*S*C_L_max));
    va_thrust = va(:,1);
    va_cat = va(:,2);
    d_thrust = cumtrapz(t, va_thrust);
    d_cat = cumtrapz(t, va_cat);
    
    figure()
    hold on
    plot(iul(d_thrust*u.m, u.ft), iul(va_thrust*u.m/u.s, u.knot), 'LineWidth',1.5)
    plot(iul(d_cat*u.m,u.ft), iul(va_cat*u.m/u.s,u.knot),'LineWidth',1.5)
    yline(1.2*iul(V_stall*u.m/u.s,u.knot), 'LineStyle','--','Color','r', 'LineWidth',1)
    xline(iul(L_cat), 'LineStyle','--', 'LineWidth',1)
    cutoff_i = find(d_thrust < double(separateUnits(unitConvert(310*u.ft,'SI'))),1,'last');
    d_cutoff = iul(d_thrust(cutoff_i)*u.m);
    va_cutoff = iul(va_thrust(cutoff_i)*u.m/u.s,u.knot);
    plot(d_cutoff, va_cutoff, 'LineStyle','none','Marker','.','MarkerSize',15)
    xlim([0, iul(L_cat)+10])
    grid on
    grid minor
    title("Carrier Aircraft takeoff performance","FontSize",15)
    ylabel("Airspeed (knot)")
    xlabel("Distance along the deck (ft)")
    lgd = legend('Airspeed with engine thrust in knots',...
        'Airspeed with one engine thrust in knots', ...
        'Takeoff velocity in knots', 'Catapult cutoff', ...
        "Airspeed at Catapult cutoff = "+num2str(va_cutoff)+" knots",...
        "Location","best");
    lgd.FontSize = 12;
    hold off
    
    clear dvdt

    function dvgdt = toFunc(~, vg, pass)
        persistent dvdt dvdt_2
        if isempty(dvdt)
            dvdt = 0;
        end
        if isempty(dvdt_2)
            dvdt_2 = 0;
        end
        vg_thrust = vg(1);
        vg_cat = vg(2);
        W = pass.W; rho = pass.rho; S = pass.S; C_L_max = pass.C_L_max * 0.9; 
        C_D0 = pass.C_D0; v_wod = pass.v_wod; AR = pass.AR; e = pass.e; 
        visc = pass.visc; g = pass.g; F_cat = pass.F_cat;

        va_thrust = vg_thrust + v_wod;
        va_cat = vg_cat + v_wod;

        C_D = 0.2427; % From assignment 6
        eta_TO = C_D - visc * C_L_max;
        
        T_thrust = 2 * W * g * (eta_TO * 1/2 * rho * va_thrust^2 * S / W ...
            + visc + dvdt / g); % From mattingly 
        if T_thrust > 2 * 191E3
            T_thrust = 2 * 191E3;
        end
        T_cat = 2 * W * g * (eta_TO * 1/2 * rho * va_thrust^2 * S / W ...
            + visc + dvdt_2 / g); %0;
        if T_cat >  191E3
            T_cat = 191E3;
        end


        L_thrust = 1/2 * rho * va_thrust^2 * S * C_L_max / 1.21;
        D_thrust = 1/2 * rho * va_thrust^2 * S * C_D;

        L_catapult = 1/2 * rho * va_cat^2 * S * C_L_max / 1.21;
        D_catapult = 1/2 * rho * va_cat^2 * S * C_D;

        mu = 0.03;  % friction coefficient, from Raymer p. 672
        Fr_thrust = mu* (W*g-L_thrust);
        Fr_cat = mu* (W*g - L_catapult);
    
        dvgdt = double(separateUnits(1/W.*([T_thrust T_cat]' + F_cat .* ...
            ones(2,1)  - [D_thrust D_catapult]' - [Fr_thrust Fr_cat]')));
        dvdt = dvgdt(1);
        dvdt_2 = dvgdt(2);
    end
end