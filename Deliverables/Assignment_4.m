% AAE 451 
% Assignment 4

%% Variable definitions
u = symunit;              % MATLAB trig functions work with symbolic units

% Atmospheric properties

% Overall Aircraft
aircraft.weight = unitConvert(66000 * u.lbf, u.N);
KA = 0.95;                % Supercritical airfoild number thing slide 10

fuselage = Fuselage()
fslg.len.diam = 2.165 * u.m;
fslg.len.length = 18.379 * u.m;

% Wing Geometry
wing.span = 44.9 * u.ft;
wing.len.chord_root = 4.611 * u.m;
wing.len.chord_tip = 1.5 * u.m;
wing.len.chord_mean = (wing.len.chord_root + wing.len.chord_tip) / 2;
wing.area.ref = 500 * u.ft^2;

wing.thickness_over_chord = 0.04;
wing.aspect_ratio = 4;
wing.sweep.LE = deg2rad(30);
wing.sweep.QC = deg2rad(25);
wing.sweep.MC = deg2rad(19.52);

% Horizontal Tail Geometry
tail_h.len.chord_mean = 2.8 * u.m;
tail_h.area_ref = (2 * 3.56067 * 0.5 * (4.10919 + 1.112)) * u.m; % 10.7639 is m2 to ft2 conversion

tail_h.thickness_over_chord = 0.04;
tail_h.sweep.LE = deg2rad(53.12);
tail_h.sweep.QC = deg2rad(48.28571);
tail_h.sweep.MC = deg2rad(31.943);

% Vertical Tail Geometry
tail_v.area_ref = (2 * 3.7 * 0.5 * (4.51 + 1.82)) * u.m; % rewrite as w/ vtail
tail_v.len.chord_mean = 3.168 * u.m;

tail_v.thickness_over_chord = .04;
tail_v.sweep.LE = deg2rad(47.69);
tail_v.sweep.QC = deg2rad(42.52679);
tail_v.sweep.MC = deg2rad(36.3239);

% Nacelle Geometry
nacelle.len.length = unitConvert(29.9367 * u.ft, u.m);
nacelle.len.diameter = unitConvert(3.02057 * u.ft, u.m);

components = {fslg, wing, tail_h, tail_v, nacelle};

%Flight conditions
altitude = 40000 * u.ft;
t = Atm.temp(altitude);
rho = Atm.density(altitude) * u.kg * u.m^-3;
a = Atm.sonic_speed(altitude) * u.m / u.s;
mu = Atm.viscosity_kin(altitude) * u.kg / u.m / u.s;
M = 0.9;
V = M * a;
% Wake Drag Conditions
C_DW_peak = .058;         % peak CDW
M_DW_peak = 1.25;         % Mach at peak CDW

%% Part 0.5 
% Oswald effciency factor
e_oswald = 4.61 * (1 - 0.045 * wing.aspect_ratio^0.68) * (cos(wing.sweep.LE)^0.15) - 3.1; % Raymer eq. 12.49

%% Part 1: Subsonic Analysis & Vortex Lift
%AoA = linspace(-5, 30, 251);
AoA = linspace(-pi/12, pi/3, 251);
Kp = (2*pi*wing.aspect_ratio) / (2 + sqrt(wing.aspect_ratio^2 * (1 + tan(wing.sweep.MC)) + 4)); %% ASSUMING MCS_W %%
Kv = pi * wing.aspect_ratio / 2 / cos(wing.sweep.LE); %% ASSUMING LES_W %%
C_Lp = Kp * sin(AoA).*(cos(AoA).^2);
C_Lv = Kv * (sin(AoA).^2).*cos(AoA);
C_L = C_Lp + C_Lv;
C_L_noVortex = C_Lp;
%disp("Lift Coefficient")
%disp(C_L)

%% Part 2: Parasitic Drag Estimation
% Turns out this refactored format is not very useful since MATLAB arrays
% cannot hold structs with different elements

Z_w = (2 - M^2)*cos(wing.sweep.QC) / sqrt(1 - (M*cos(wing.sweep.QC))^2); % Sweep correction factor from Shevell, slide 15
wing.ff.form = 1 + Z_w*(wing.thickness_over_chord) + 100*(wing.thickness_over_chord)^4;
Z_ht = (2 - M^2)*cos(tail_h.sweep.QC) / sqrt(1 - (M*cos(tail_h.sweep.QC))^2);
tail_h.ff.form = 1 + Z_ht*(tail_h.thickness_over_chord) + 100*(tail_h.thickness_over_chord)^4;
Z_vt = (2 - M^2)*cos(tail_v.sweep.QC) / sqrt(1 - (M*cos(tail_v.sweep.QC))^2);
tail_v.ff.form = 1 + Z_vt*(tail_v.thickness_over_chord) + 100*(tail_v.thickness_over_chord)^4;
nacelle.ff.form = 1 + 0.35 / (nacelle.len.length / nacelle.len.diameter);
FF = ul([fslg.ff.form wing.ff.form tail_h.ff.form tail_v.ff.form nacelle.ff.form]);

% Interference factors
fslg.ff.interference = 1;          % The nacelles seem more than Dn away from the fuselage
wing.ff.interference = 1;
tail_v.ff.interference = 1.03;      % Seems both V and conventional
tail_h.ff.interference = 1.08;      % Horizontal stabilizer separate component
nacelle.ff.interference = 1.3;        % Seems less than Dn away from wing
Q = ul([fslg.ff.interference wing.ff.interference tail_h.ff.interference tail_v.ff.interference nacelle.ff.interference]);

% Skin friction factors  
fslg.reynolds = fslg.len.length * (V * rho / mu);
fslg.ff.skin = 0.455 / ( log10(fslg.reynolds)^2.58);
wing.reynolds = wing.len.chord_mean * (V * rho / mu);
wing.ff.skin = 0.455 / ( log10(wing.reynolds)^2.58);
tail_h.reynolds = tail_h.len.chord_mean * (V * rho / mu);
tail_h.ff.skin = 0.455 / ( log10(tail_h.reynolds)^2.58);
tail_v.reynolds = tail_v.len.chord_mean * (V * rho / mu);
tail_v.ff.skin = 0.455 / ( log10(tail_v.reynolds)^2.58);
nacelle.reynolds = nacelle.len.length * (V * rho / mu);
nacelle.ff.skin = 0.455 / ( log10(nacelle.reynolds)^2.58);
C_f = ul([fslg.ff.skin wing.ff.skin tail_h.ff.skin tail_v.ff.skin nacelle.ff.skin]);

% Wetted area of the different components
fslg.area.wet = pi * fslg.len.diam * fslg.len.length * ( (1 - 2/fslg.fineness_ratio)^(2/3) ) * (1 + 1/fslg.fineness_ratio^2);
wing.area.wet = (wing.area.ref - wing.len.chord_root * fslg.len.diam) * 2 * 1.02; %removing the area also covered by the fuselage
tail_h.area.wet = tail_h.area_ref * 2 * 1.02;
tail_v.area.wet = tail_v.area_ref * 2 * 1.02;
nacelle.area.wet = pi * nacelle.len.diameter * nacelle.len.length;
S_wet = rewrite([fslg.area.wet wing.area.wet tail_h.area.wet tail_v.area.wet nacelle.area.wet], u.m^2);

% component build up
% Unfortunately it seems OOP is needed since MATLAB does not allow for the following:
% C_D0 = arrayfun(@(c) c.ff.form * c.ff.interference * c.ff.skin * c.ff.area.wet);

C_D0 = sum(ul(FF .* Q .* C_f .* S_wet), 'all') / ul(wing.area.ref);
%Add misc drag
C_D0_misc = 0.1 * C_D0; % estimation from drag pred pg 25
C_D0 = C_D0 + C_D0_misc; %add the misc values in
% Calculate M_DD
SWP = wing.sweep.QC;  % assuming that the sweep angle given in the eqn is quarter chord sweep for the wing

% Cdwake
C_L_des = ul(aircraft.weight / (0.5 * rho * V^2 * wing.area.wet));
M_DD = KA/cos(SWP) - wing.thickness_over_chord/(cos(SWP)^2) - C_L_des / (10 * (cos(SWP)^3));
M_crit = M_DD - 0.08;
% c_dc has something to do with speed in mach
K_sub = 1 / (pi * wing.aspect_ratio * e_oswald);
K_sup = wing.aspect_ratio * (M^2 - 1) * cos(wing.sweep.LE) / (4 * wing.aspect_ratio * sqrt(M^2 - 1) - 2);
C_Di = K_sub * (C_L.^2);
C_Di_noVortex = K_sub * (C_L_noVortex.^2);
C_D = C_D0 + C_Di;
C_D_noVortex = C_D0 + C_Di_noVortex;

%% Part 3: Supersonic Effects and Cruise Efficiency
% Iteration Variables
Machs = linspace(0, 2.5, 53);
C_D_wakes = Machs * 0;
C_D_is = Machs * 0;
Ks = Machs * 0;
for i = 1:length(Machs)
    M = Machs(i);
    % ---- Required CL at this Mach for level flight ----
    V_M = ul(M * a);
    q_M = 0.5 * rho * V_M^2;               % consistent with slug/ft^3 and ft/s
    C_L_M = ul(aircraft.weight / (q_M * wing.area.wet));
    K_sub_thresh = 1 / (pi * wing.aspect_ratio * e_oswald);
    Msq_minus_1 = max(M^2 - 1, 1e-9);
    Msqpk_minus_1 = max(M_DW_peak^2 - 1, 1e-9);
    K_sup_thresh = wing.aspect_ratio * Msqpk_minus_1 * cos(wing.sweep.LE) / (4 * wing.aspect_ratio * sqrt(Msqpk_minus_1) - 2);
    % ---- Wake drag + K in regions ----
    if (M >= M_crit)
        if (M >= M_DW_peak)
            %% Supersonic Region (decay; continuous at M_DW_peak)
            C_D_wake = C_DW_peak * sqrt(Msqpk_minus_1) / sqrt(Msq_minus_1);
            K = wing.aspect_ratio * Msq_minus_1 * cos(wing.sweep.LE) / (4 * wing.aspect_ratio * sqrt(Msq_minus_1) - 2);
        else
            %% Transonic Region (Gundlach cubic ramp to the peak)
            scal = C_DW_peak/(M_DW_peak - M_crit)^3;
            C_D_wake = scal * (M - M_crit)^3; % Gundlach Ch. 5 (5.46)
            % Smooth blend 
            x = (M - M_crit) / (M_DW_peak - M_crit);
            x = max(0, min(1, x));
            w = x^2 * (3 - 2*x);  % smoothstep
            K = (1-w)*K_sub_thresh + w*K_sup_thresh;
        end
    else
        %% Subsonic Region
        C_D_wake = 0;
        K = K_sub_thresh;
    end
    % ---- Save values ----
    C_D_wakes(i) = C_D_wake;
    Ks(i) = K;
    % ---- Induced drag at this Mach (this was missing) ----
    C_D_is(i) = K * (C_L_M^2);
end
% Plotting the required graphs
% Plot 1
C_D_ZL = C_D0 + C_D_wakes;
figure;
plot(Machs, C_D_ZL)
title('Total Zero-Lift Drag Rise with Mach Number');
xlabel("Mach")
ylabel("C_{DZL}")
grid on;
% Plot 2
LDMax = 1./sqrt(4.*C_D0.*Ks);
figure;
plot(Machs, LDMax);
xlabel("Mach")
ylabel('(L/D)_{max}');
title('Maximum Lift-to-Drag Ratio vs Mach');
grid on;
% Plot 3
Effic_Index = Machs.*LDMax;
figure;
plot(Machs, Effic_Index)
xlabel('Mach');
ylabel('Mach × (L/D)_{max}');
title('Cruise Efficiency Index vs Mach');
grid on;
% %debugging plot
% LDMax1 = 1./sqrt(C_D_ZL + Ks);
% LDMax2 = 1./sqrt(C_D0 + Ks);
% LDMax3 = 1./sqrt(4.*C_D_ZL.*Ks);
% LDMax4 = 1./sqrt(4.*C_D0.*Ks);
% figure;
% plot(Machs, LDMax1); hold on; 
% plot(Machs, LDMax2);
% plot(Machs, LDMax3);
% plot(Machs, LDMax4);
% legend('1./sqrt(C_D_ZL + Ks)', '1./sqrt(C_D0 + Ks)', '1./sqrt(4*C_D_ZL*Ks)', '1./sqrt(4*C_D0*Ks)')
% title("Variations of the ldmax equation")
% figure;
% plot(Machs,  Machs.*LDMax1); hold on; 
% plot(Machs,  Machs.*LDMax2);
% plot(Machs,  Machs.*LDMax3);
% plot(Machs,  Machs.*LDMax4);
% legend('1./sqrt(C_D_ZL + Ks)', '1./sqrt(C_D0 + Ks)', '1./sqrt(4*C_D_ZL*Ks)', '1./sqrt(4*C_D0*Ks)')
% title("Efficency")
%CL vs Alpha
figure;
plot(AoA*180/pi, C_L_noVortex); 
hold on;
plot(AoA*180/pi, C_L);
xlabel('Angle of Attack (deg)');
ylabel('CL');
title('Lift Curve: Linear vs Vortex Lift (LEX Effect)');
legend('Linear Lift Only', 'With Leading Edge Vortex', 'Location','Best');
grid on;
%Subsonic Drag polar
figure;
plot(C_D, C_L)
hold on;
plot(C_D_noVortex, C_L_noVortex)
title('Subsonic Drag Polar: Effect of Leading Edge Vortex');
legend('With Vortex Lift', 'Without Vortex Lift', 'Location','Best');
xlabel("CD")
ylabel("CL")
grid on;

%% Additional graphs

CD0_components = ul(FF .* Q .* C_f .* S_wet) / ul(wing.area.ref);
labels = {'Fuselage','Wing','H Tail','V Tail','Nacelles'};
figure;
bar(CD0_components)
set(gca,'XTickLabel',labels)
ylabel('C_{D0} Contribution')
title('Zero-Lift Drag Breakdown by Component')
grid on;
figure;
plot(Machs, Ks, 'LineWidth', 2);
xlabel('Mach Number');
ylabel('Induced Drag Factor, K');
title('Induced Drag Factor as a Function of Mach Number');
grid on;