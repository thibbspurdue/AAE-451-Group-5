% AAE 451 
% Assignment 4

%% Add Project folder to path to access OOP objects
script_dir = fileparts(mfilename('fullpath'));
project_dir = fullfile(script_dir, '..', 'Project');
if ~contains(path, project_dir)
    addpath(project_dir, '-begin');
end

% Unit conversions from SI object properties to imperial assignment units
m_to_ft = 3.280839895;
m2_to_ft2 = m_to_ft^2;

%% Variable definitions

% Instantiate aircraft components using the OOP model
comp_cfg = instantiate_aircraft_components(0, profile="deliverables", tailless=true);
design = comp_cfg.design;

%% Aircraft Dependent Parameters
% Weight and Geometry
W = 59198;                  % Weight, From Assignment 3
wing = comp_cfg.wing;
b = wing.wingspan * m_to_ft;      % wingspan (ft)
AR = wing.aspect_ratio;    % Aspect Ratio
S_w = wing.reference_area * m2_to_ft2;      % Wing area, ft^2
S_ref = S_w;               % Reference wing area

% Extract wing geometry from object
t_c_w = wing.thickness_chord_ratio;
LES_w = wing.leading_edge_sweep;      % in radians
QCS_w = wing.quarter_chord_sweep;     % in radians
MCS_w = wing.mid_chord_sweep;         % in radians
c_r = wing.root_chord * m_to_ft;      % root chord (ft)
c_t = wing.tip_chord * m_to_ft;       % tip chord (ft)
ch_w = (c_r + c_t)/2;      % Average chord

%% Fixed Parameters
fuselage = comp_cfg.fuselage;
KA = design.K_A;                       % Supercritical airfoil number
d_f = fuselage.width * m_to_ft;        % Fuselage diameter (ft)
l_f = fuselage.length * m_to_ft;       % Fuselage length (ft)

% Nacelle Geometry
l_N = 29.9367;            % Nacelle length (ft) --> 8.2103 m
d_N = 3.02057;            % Nacelle diameter (ft) --> .92067 m

%Flight conditions
h = design.h_cruise_sup * m_to_ft;    % altitude (ft)
p = 5.87*10^-4;           % air density (Slugs/ft^3)
a = 659.8 * 1.4667;       % speed of sound (mph --> ft/s)
M = design.M;
V = M * a;

%q = 100691.89;            % dynamic pressure (Pa)
mu = 2.969*10^-7;         % kinematic viscosity (slug/(ft s))

% Wake Drag Conditions - from design defaults
C_DW_peak = design.C_DW_peak;  % peak CDW
M_DW_peak = design.M_DW_peak;  % Mach at peak CDW

%% Part 0.5 
% Oswald efficiency factor from Wing object
e = wing.oswald_eff;

%% Part 1: Subsonic Analysis & Vortex Lift
%AoA = linspace(-5, 30, 251);
AoA = linspace(-pi/12, pi/3, 251);
Kp = (2*pi*AR) / (2 + sqrt(AR^2 * (1 + tan(MCS_w)) + 4)); %% ASSUMING MCS_W %%
Kv = pi * AR / 2 / cos(LES_w); %% ASSUMING LES_W %%
C_Lp = Kp * sin(AoA).*(cos(AoA).^2);
C_Lv = Kv * (sin(AoA).^2).*cos(AoA);
C_L = C_Lp + C_Lv;
C_L_noVortex = C_Lp;


%% Part 2: Parasitic Drag Estimation
% M = V/a; % We are using the mach of the flight conditions given
% Form Factor

% Fuselage
lamf = l_f/d_f;                             % fineness ratio for fuselage
FFf = 0.9 + 5 / (lamf^(1.5)) + lamf / 400;  % Raymer 6th ed

% Wings
Z_w = (2 - M^2)*cos(QCS_w) / sqrt(1 - (M*cos(QCS_w))^2);
FFw = 1 + Z_w*(t_c_w) + 100*(t_c_w)^4;

% Nacelle
FFn = 1 + 0.35 / (l_N / d_N);

% Order is: fuselage, wings, nacelles (tailless configuration)
FF = [FFf FFw FFn];        % add in these for all the components

% Interferance factors
Qf = 1;          % The nacelles seem more than Dn away from the fuselage
Qn = 1.3;        % Seems less than Dn away from wing
Qw = 1;
Q = [Qf Qw Qn];

% Skin friction factors
% Order is: fuselage, wings, nacelles
  
% Fuselage
Re_f = l_f * (V * p / mu);
C_f_f = 0.455 / ( log10(Re_f)^2.58);
% Wings
Re_w = ch_w * (V * p / mu);
C_f_w = 0.455 / ( log10(Re_w)^2.58);
% Nacelles
Re_n = l_N * (V * p / mu);
C_f_n = 0.455 / ( log10(Re_n)^2.58);
C_f = [C_f_f C_f_w C_f_n];

% Wetted area of the different components
% Order is: fuselage, wings, nacelles (tailless configuration)
% Fuselage
S_wet_f = pi * d_f * l_f * ( (1 - 2/lamf)^(2/3) ) * (1 + 1/lamf^2);
% Wings
S_wet_w = (S_w - c_r * d_f) * 2 * 1.02; %removing the area also covered by the fuselage
% Nacelles 
S_wet_n = pi * d_N * l_N;
S_wet = [S_wet_f S_wet_w S_wet_n];
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
xline(M_crit, '--r', 'Critical Mach', 'LineWidth', 1.5);
xline(M_DW_peak, '--m', 'Drag Divergence Mach', 'LineWidth', 1.5);
legend('C_{DZL}', 'Critical Mach', 'Drag Divergence Mach', 'Location', 'Best');
hold off
% Plot 2
LDMax = 1./sqrt(4.*C_D0.*Ks);
figure;
plot(Machs, LDMax);
xlabel("Mach")
ylabel('(L/D)_{max}');
title('Maximum Lift-to-Drag Ratio vs Mach');
hold on
xline(M_crit, '--r', 'Critical Mach', 'LineWidth', 1.5);
xline(M_DW_peak, '--m', 'Drag Divergence Mach', 'LineWidth', 1.5);
legend('Max L/D', 'Critical Mach', 'Drag Divergence Mach', 'Location', 'Best');
grid on;
hold off
% Plot 3
Effic_Index = Machs.*LDMax;
figure;
plot(Machs, Effic_Index)
xlabel('Mach');
ylabel('Mach × (L/D)_{max}');
title('Cruise Efficiency Index vs Mach');
grid on;
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
labels = {'Fuselage','Wing','Nacelles'};
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
