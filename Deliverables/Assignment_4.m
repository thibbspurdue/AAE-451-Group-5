% AAE 451 
% Assignment 4

%% Variable definitions
u = symunit;              % MATLAB trig functions work with symbolic units

% Weight and Geometry
W = 66000 * u.lb;         % Weight, lb
KA = 0.95;                % Supercritical airfoild number thing slide 10
AR = 4;                   % Aspect Ratio

fslg.diam = 2.165 * u.m;
fslg.len = 18.379 * u.m;

% Wing Geometry
wing.span = 44.9 * u.ft;
wing.len.chord_root = 4.611 * u.m;
wing.len.chord_tip = 1.5 * u.m;
wing.len.chord_mean = (wing.len.chord_root + wing.len.chord_tip) / 2;

wing.area.ref = 500 * u.ft^2;
wing.area.wet = wing.area.ref - 0 * u.ft^2;

wing.thickness_over_chord = 0.04;
wing.sweep.LE = 30 * u.deg;
wing.sweep.QC = 25 * u.deg;
wing.sweep.MC = 19.52 * u.deg;

% Horizontal Tail Geometry
tail_h.len.chord_mean = 2.8 * u.m;
tail_h.area_ref = (2 * 3.56067 * 0.5 * (4.10919 + 1.112)) * 10.7639; % 10.7639 is m2 to ft2 conversion

tail_h.thickness_over_chord = 0.04;
tail_h.sweep.LE = 53.12 * u.deg;
tail_h.sweep.QC = 48.28571 * u.deg;
tail_h.sweep.MC = 31.943 * u.deg;

% Vertical Tail Geometry
tail_v.area_ref = (2 * 3.7 * 0.5 * (4.51 + 1.82)) * 10.7639; % rewrite as w/ vtail
tail_v.len.chord_mean = 3.168 * u.m;

tail_v.thickness_over_chord = .04;
tail_v.sweep.LE = 47.69 * u.deg;
tail_v.sweep.QC = 42.52679 * u.deg;
tail_v.sweep.MC = 36.3239 * u.deg;

%% NEED S_HT AND S_VT%%%%%%%%%%%%
% Nacelle Geometry
l_N = 29.9367;            % Nacelle length (ft) --> 8.2103 m
d_N = 3.02057;            % Nacelle diameter (ft) --> .92067 m
%Flight conditions
%V = 516;                  % flight velocity (from Assignment 3, not sure units)
h = 40000;                % altitude (FEET)
p = 5.87*10^-4;           % air density (Slugs/ft^3)
a = 659.8 * 1.4667;                % speed of sound (mph --> ft / s)
M = 0.9;
V = M * a;
%q = 100691.89;            % dynamic pressure (Pa)
mu = 2.969*10^-7;         % kinematic viscosity (slug/(ft s))
% Wake Drag Conditions
C_DW_peak = .058;         % peak CDW
M_DW_peak = 1.25;         % Mach at peak CDW

%% Part 0.5 
% Oswald effciency factor
%e = 0.98 * (1 - (fslg.diam/b)^2); 
e = 4.61 * (1 - 0.045*AR^0.68) * (cos(wing.sweep.LE)^0.15) - 3.1;

%% Part 1: Subsonic Analysis & Vortex Lift
%AoA = linspace(-5, 30, 251);
AoA = linspace(-pi/12, pi/3, 251);
Kp = (2*pi*AR) / (2 + sqrt(AR^2 * (1 + tan(wing.sweep.MC)) + 4)); %% ASSUMING MCS_W %%
Kv = pi * AR / 2 / cos(wing.sweep.LE); %% ASSUMING LES_W %%
C_Lp = Kp * sin(AoA).*(cos(AoA).^2);
C_Lv = Kv * (sin(AoA).^2).*cos(AoA);
C_L = C_Lp + C_Lv;
C_L_noVortex = C_Lp;
%disp("Lift Coefficient")
%disp(C_L)

%% Part 2: Parasitic Drag Estimation
%M = V/a; % We are using the mach of the flight conditions given
%Form Factor

% Fuselage
lamf = fslg.len/fslg.diam;                             % fineness ratio for fuselage
FFf = 0.9 + 5 / (lamf^(1.5)) + lamf / 400;  % Raymer 6th ed
% Wings
Z_w = (2 - M^2)*cos(wing.sweep.QC) / sqrt(1 - (M*cos(wing.sweep.QC))^2);
FFw = 1 + Z_w*(wing.thickness_over_chord) + 100*(wing.thickness_over_chord)^4;
% Horizontal Tail
Z_ht = (2 - M^2)*cos(tail_h.sweep.QC) / sqrt(1 - (M*cos(tail_h.sweep.QC))^2);
FFht = 1 + Z_ht*(tail_h.thickness_over_chord) + 100*(tail_h.thickness_over_chord)^4;
  
% Vertical Tail
Z_vt = (2 - M^2)*cos(tail_v.sweep.QC) / sqrt(1 - (M*cos(tail_v.sweep.QC))^2);
FFvt = 1 + Z_vt*(tail_v.thickness_over_chord) + 100*(tail_v.thickness_over_chord)^4;
% Nacelle
FFn = 1 + 0.35 / (l_N / d_N);
% Order is: fuselage, wings, h tail, v tail, nacelles
FF = [FFf FFw FFht FFvt FFn];        % add in these for all the components
% Interference factors
Qf = 1;          % The nacelles seem more than Dn away from the fuselage
Qn = 1.3;        % Seems less than Dn away from wing
Qw = 1;
Qvt = 1.03;      % Seems both V and conventional
Qht = 1.08;      % Horizontal stabilizer separate component
Q = [Qf Qw Qht Qvt Qn];
% Skin friction factors
% Order is: fuselage, wings, h tail, v tail, nacelles
  
% Fuselage
Re_f = fslg.len * (V * p / mu);
C_f_f = 0.455 / ( log10(Re_f)^2.58);
% Wings
Re_w = wing.len.chord_mean * (V * p / mu);
C_f_w = 0.455 / ( log10(Re_w)^2.58);
% Horizontal Tail
Re_ht = tail_h.len.chord_mean * (V * p / mu);
C_f_ht = 0.455 / ( log10(Re_ht)^2.58);
% Vertical Tail
Re_vt = tail_v.len.chord_mean * (V * p / mu);
C_f_vt = 0.455 / ( log10(Re_vt)^2.58);
% Nacelles
Re_n = l_N * (V * p / mu);
C_f_n = 0.455 / ( log10(Re_n)^2.58);
C_f = [C_f_f C_f_w C_f_ht C_f_vt C_f_n];
% Wetted area of the different components
% Order is: fuselage, wings, h tail, v tail, nacelles
% Fuselage
fuselage.area_wetted = pi * fslg.diam * fslg.len * ( (1 - 2/lamf)^(2/3) ) * (1 + 1/lamf^2);
% Wings
wing.area.wet = (wing.area.wet - wing.len.chord_root * fslg.diam) * 2 * 1.02; %removing the area also covered by the fuselage
% Horizontal tail
tail_h.area_wetted = tail_h.area_ref * 2 * 1.02;
% Vertical tail
tail_v.area_wetted = tail_v.area_ref * 2 * 1.02;
% Nacelles 
nacelle.area_wetted = pi * d_N * l_N;
S_wet = [fuselage.area_wetted wing.area.wet tail_h.area_wetted tail_v.area_wetted nacelle.area_wetted];
% component build up
C_D0 = sum(FF .* Q .* C_f .* S_wet, 'all') / wing.area.ref;
%Add misc drag
C_D0_misc = 0.1 * C_D0; %estimation from drag pred pg 25
C_D0 = C_D0 + C_D0_misc; %add the misc values in
% Calculate M_DD
SWP = wing.sweep.QC;  % assuming that the sweep angle given in the eqn is quarter chord sweep for the wing
% Cdwake
%%%%%%%%%%ASSUMED t/c OF THE WING%%%%%%%%%%%%%%%%%%%%
C_L_des = W / (0.5 * p * V^2 * wing.area.wet);
M_DD = KA/cos(SWP) - wing.thickness_over_chord/(cos(SWP)^2) - C_L_des / (10 * (cos(SWP)^3));
M_crit = M_DD - 0.08;
% c_dc has something to do with speed in mach
K_sub = 1 / (pi * AR * e);
%%%%%%%%%%ASSUMED LES OF THE WING%%%%%%%%%%%%%%%%%%%%
K_sup = AR * (M^2 - 1) * cos(wing.sweep.LE) / (4 * AR * sqrt(M^2 - 1) - 2);
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
    V_M = M * a;                         % ft/s (since you fixed a)
    q_M = 0.5 * p * V_M^2;               % consistent with slug/ft^3 and ft/s
    C_L_M = W / (q_M * wing.area.wet);
    K_sub_thresh = 1 / (pi * AR * e);
    Msq_minus_1 = max(M^2 - 1, 1e-9);
    Msqpk_minus_1 = max(M_DW_peak^2 - 1, 1e-9);
    K_sup_thresh = AR * Msqpk_minus_1 * cos(wing.sweep.LE) / (4 * AR * sqrt(Msqpk_minus_1) - 2);
    % ---- Wake drag + K in regions ----
    if (M >= M_crit)
        if (M >= M_DW_peak)
            %% Supersonic Region (decay; continuous at M_DW_peak)
            C_D_wake = C_DW_peak * sqrt(Msqpk_minus_1) / sqrt(Msq_minus_1);
            K = AR * Msq_minus_1 * cos(wing.sweep.LE) / (4 * AR * sqrt(Msq_minus_1) - 2);
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
legend('Without Vortex Lift', 'With Vortex Lift', 'Location','Best');
xlabel("CD")
ylabel("CL")
grid on;
%% Additional graphs
CD0_components = (FF .* Q .* C_f .* S_wet) / wing.area.ref;
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