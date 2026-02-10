% AAE 451 
% Assignment 4
%%%%%%%%%%%%%%%%%%%%%%%%% THINGS THAT NEED FIXED %%%%%%%%%%%%%%%%%%%%%%%%%
% 2) Area of the tails, horizontal AND vertical need to be calculated
% (Lines 52-55) <- Resolved(Min), moved to line 67~68
% 5) Verify assumptions that M_DD and k_sup use t/c and LES of the WING,
% respectively (Lines 203 and 210)
% 7) Note: Everything has been converted to FEET and DEGREES 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Variable definitions
% Weight and Geometry
W = 66000;                % Weight, lb
KA = 0.95;                % Supercritical airfoild number thing slide 10
AR = 4;                   % Aspect Ratio
d_f = 2.165*3.2808399;    % Fuselage diameter, converted from m to ft
l_f = 60.299;             % Fuselage length (ft) from excel --> 18.379 m
b = 44.9;                 % wingspan (ft)
S_ref = 500;              % not super sure if this is S or not
  
% Wing Geometry
t_c_w = 0.04;             % thickness over chord wing (dimensionless)
MCS_w = 19.52 * (pi/180); % Mid chord sweep (deg)
QCS_w = 25 * (pi/180);    % Quarter chord sweep (deg)
LES_w = 30 * (pi/180);    % Leading edge sweep (deg)
c_r = 4.611 * 3.2808399;  % the root chord
c_t = 1.5 * 3.2808399;
ch_w = (c_r + c_t)/2;
%ch_w = 15.0369;           % Chord length of the wing (ft) --> 4.58325 m
S = 500;                  % Wing reference area, ft^2
S_w = S;                  % Wing area, ft^2, (should subtract fuselage overlap)
% Horizontal Tail Geometry
t_c_ht = .04;             % thickness over chord (dimensionless)
MCS_ht = 31.943 * (pi/180);          % Mid chord sweep (deg)
QCS_ht = 48.28571 * (pi/180);        % Quarter chord sweep (deg)
LES_ht = 53.12 * (pi/180);           % Leading edge sweep (deg)
ch_ht = 9.18635;          % Chord length of the horizontal tail (ft) --> 2.8 m
% Vertical Tail Geometry
t_c_vt = .04;             % thickness over chord (dimensionless)
MCS_vt = 36.3239 * (pi/180);         % Mid chord sweep (deg)
QCS_vt = 42.52679 * (pi/180);        % Quarter chord sweep (deg)
LES_vt = 47.69 * (pi/180);           % Leading edge sweep (deg)
ch_vt = 10.3937;          % Chord length of the vertical tail (ft) --> 3.168 m
%% NEED S_HT AND S_VT%%%%%%%%%%%%
S_ht = (2 * 3.56067 * 0.5 * (4.10919 + 1.112)) * 10.7639; % 10.7639 is m2 to ft2 conversion
S_vt = (2 * 3.7 * 0.5 * (4.51 + 1.82)) * 10.7639;
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
%e = 0.98 * (1 - (d_f/b)^2); 
e = 4.61 * (1 - 0.045*AR^0.68) * (cos(LES_w)^0.15) - 3.1;
%% Part 1: Subsonic Analysis & Vortex Lift
%AoA = linspace(-5, 30, 251);
AoA = linspace(-pi/12, pi/3, 251);
Kp = (2*pi*AR) / (2 + sqrt(AR^2 * (1 + tan(MCS_w)) + 4)); %% ASSUMING MCS_W %%
Kv = pi * AR / 2 / cos(LES_w); %% ASSUMING LES_W %%
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
lamf = l_f/d_f;                             % fineness ratio for fuselage
FFf = 0.9 + 5 / (lamf^(1.5)) + lamf / 400;  % Raymer 6th ed
% Wings
Z_w = (2 - M^2)*cos(QCS_w) / sqrt(1 - (M*cos(QCS_w))^2);
FFw = 1 + Z_w*(t_c_w) + 100*(t_c_w)^4;
% Horizontal Tail
Z_ht = (2 - M^2)*cos(QCS_ht) / sqrt(1 - (M*cos(QCS_ht))^2);
FFht = 1 + Z_ht*(t_c_ht) + 100*(t_c_ht)^4;
  
% Vertical Tail
Z_vt = (2 - M^2)*cos(QCS_vt) / sqrt(1 - (M*cos(QCS_vt))^2);
FFvt = 1 + Z_vt*(t_c_vt) + 100*(t_c_vt)^4;
% Nacelle
FFn = 1 + 0.35 / (l_N / d_N);
% Order is: fuselage, wings, h tail, v tail, nacelles
FF = [FFf FFw FFht FFvt FFn];        % add in these for all the components
% Interferance factors
Qf = 1;          % The nacelles seem more than Dn away from the fuselage
Qn = 1.3;        % Seems less than Dn away from wing
Qw = 1;
Qvt = 1.03;      % Seems both V and conventional
Qht = 1.08;      % Horizontal stabilizer separate component
Q = [Qf Qw Qht Qvt Qn];
% Skin friction factors
% Order is: fuselage, wings, h tail, v tail, nacelles
  
% Fuselage
Re_f = l_f * (V * p / mu);
C_f_f = 0.455 / ( log10(Re_f)^2.58);
% Wings
Re_w = ch_w * (V * p / mu);
C_f_w = 0.455 / ( log10(Re_w)^2.58);
% Horizontal Tail
Re_ht = ch_ht * (V * p / mu);
C_f_ht = 0.455 / ( log10(Re_ht)^2.58);
% Vertical Tail
Re_vt = ch_vt * (V * p / mu);
C_f_vt = 0.455 / ( log10(Re_vt)^2.58);
% Nacelles
Re_n = l_N * (V * p / mu);
C_f_n = 0.455 / ( log10(Re_n)^2.58);
C_f = [C_f_f C_f_w C_f_ht C_f_vt C_f_n];
% Wetted area of the different components
% Order is: fuselage, wings, h tail, v tail, nacelles
% Fuselage
S_wet_f = pi * d_f * l_f * ( (1 - 2/lamf)^(2/3) ) * (1 + 1/lamf^2);
% Wings
S_wet_w = (S_w - c_r * d_f) * 2 * 1.02; %removing the area also covered by the fuselage
% Horizontal tail
S_wet_ht = S_ht * 2 * 1.02;
% Vertical tail
S_wet_vt = S_vt * 2 * 1.02;
% Nacelles 
S_wet_n = pi * d_N * l_N;
S_wet = [S_wet_f S_wet_w S_wet_ht S_wet_vt S_wet_n];
% component build up
C_D0 = sum(FF .* Q .* C_f .* S_wet, 'all') / S_ref;
%Add misc drag
C_D0_misc = 0.1 * C_D0; %estimation from drag pred pg 25
C_D0 = C_D0 + C_D0_misc; %add the misc values in
% Calculate M_DD
SWP = QCS_w;  % assuming that the sweep angle given in the eqn is quarter chord sweep for the wing
% Cdwake
%%%%%%%%%%ASSUMED t/c OF THE WING%%%%%%%%%%%%%%%%%%%%
C_L_des = W / (0.5 * p * V^2 * S_w);
M_DD = KA/cos(SWP) - t_c_w/(cos(SWP)^2) - C_L_des / (10 * (cos(SWP)^3));
M_crit = M_DD - 0.08;
% c_dc has something to do with speed in mach
K_sub = 1 / (pi * AR * e);
%%%%%%%%%%ASSUMED LES OF THE WING%%%%%%%%%%%%%%%%%%%%
K_sup = AR * (M^2 - 1) * cos(LES_w) / (4 * AR * sqrt(M^2 - 1) - 2);
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
    C_L_M = W / (q_M * S_w);
    K_sub_thresh = 1 / (pi * AR * e);
    Msq_minus_1 = max(M^2 - 1, 1e-9);
    Msqpk_minus_1 = max(M_DW_peak^2 - 1, 1e-9);
    K_sup_thresh = AR * Msqpk_minus_1 * cos(LES_w) / (4 * AR * sqrt(Msqpk_minus_1) - 2);
    % ---- Wake drag + K in regions ----
    if (M >= M_crit)
        if (M >= M_DW_peak)
            %% Supersonic Region (decay; continuous at M_DW_peak)
            C_D_wake = C_DW_peak * sqrt(Msqpk_minus_1) / sqrt(Msq_minus_1);
            K = AR * Msq_minus_1 * cos(LES_w) / (4 * AR * sqrt(Msq_minus_1) - 2);
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
CD0_components = (FF .* Q .* C_f .* S_wet) / S_ref;
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