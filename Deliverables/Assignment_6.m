% AAE 451 Spring 2026
% Assignment 6
% Team 5
% VERSION 1.2

% Variables
% This section has all variables used in other Assignment Codes. Variables
% are used in assignment codes that influence this code.

g = 9.81;         % m/s^2 
ft_NM = 6076.12;  % 1 Nautical Mile = 6076 feet
ft_Mi = 5280;     % 1 Mile = 5280 feet

%% Aircraft Dependent Variables

% Assignment 3

Cruise_SFC = 0.80;         % lb/lbf * hr, currently from propulsion system choice
Combat_SFC = 1.9;          % lb/lbf * hr, currently from propulsion system choice
Loiter_SFC = 0.80;         % lb/lbf * hr, currently from propulsion system choice
W_payload = 10000;         % 2500 lb avionics suite + 7500 lb engines
W_crew = 215;              % lbs, Given in Assignment 3 Description
Kvs = 1;                   % 1 for fixed wing sweep
V_Cruise = 516 * ft_NM;    % Nicolai (136), Assumption that Cruise is 0.9 at alt 36000-45000
V_Sup = 918*ft_NM;         % Supersonic is 1.6
Wing_loading = 90;         % lb/ft^2
Thrust_Weight = 1.15;      % Chosen Design Parameter

% Assignment 4

h_cruise_sup = 40000;       % altitude (FEET)
h_Seroc_Strike_dash = 100;  % altitude (FEET) at SL
M = 0.9;                    % Assumed cruise speed, 
% Chosen Design Parameters
AR = 2.215;                % Aspect Ratio (chosen)
dia_fuselage = 2.165;      % Fuselage diameter (m)
len_fuselage = 18.379;     % Fuselage length (m)
b = 44.9;                  % wingspan (ft)
S_ref = 842.8142;          % reference area (ft^2)
% All following are based on Assignment 1 and measurements of online aircraft model
% Wing Geometry
t_c_w = 0.12;                      % thickness over chord wing, u/l
MCS_w = deg2rad(19.52);            % Wing midchord sweep, rad
QCS_w = deg2rad(25);               % Wing quarter chord sweep, rad
LES_w = deg2rad(30);               % Wing leading edge sweep, rad
c_r = 4.611;                       % Wing root chord, m
c_t = 1.5;                         % Wingtip chord, ft -> m
ch_w = (c_r + c_t)/2;              % Wing mean chord, ft -> m
S = S_ref;                         % Wing reference area, ft^2
S_w = S;                           % Wing area, ft^2, (should subtract fuselage overlap)
% Horizontal Tail Geometry
t_c_ht = .12;                      % thickness over chord (dimensionless)
MCS_ht = 31.943;                   % Mid chord sweep (deg)
QCS_ht = 48.28571;                 % Quarter chord sweep (deg)
LES_ht = 53.12;                    % Leading edge sweep (deg)
ch_ht = 2.8;                       % Chord length of the horizontal tail (m)
% Vertical Tail Geometry
t_c_vt = .12;                      % thickness over chord (dimensionless)
MCS_vt = 36.3239;                  % Mid chord sweep (deg)
QCS_vt = 42.52679;                 % Quarter chord sweep (deg)
LES_vt = 47.69;                    % Leading edge sweep (deg)
ch_vt = 3.168;                     % Chord length of the vertical tail (m)
S_ht = (2 * 3.56067 * 0.5 * (4.10919 + 1.112)); % Area of Horizontal tail
S_vt = (2 * 3.7 * 0.5 * (4.51 + 1.82));
% Nacelle Geometry
l_N = 29.9367;                     % Nacelle length (ft) --> 8.2103 m
d_N = 3.02057;                     % Nacelle diameter (ft) --> .92067 m
beta = [1, .78, .6];               % Weight Fractions From Assignment 4
CD_w = .0190;                      % From Assignment 4
C_L_max = 2.5;                     % From Chosen Airfoil

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% L/D VALUES BELOW: These initial L/D values are based on historical data 
% and must be assumed for the sizing code to work. Since Assignment 3 uses 
% these values, and Assignment 4 (where the actual L/D values are 
% calculated) depends on Assignment 3, this is a fundamental assumption 
% that keeps us out of an infinite design loop.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cruise_L_D = 9.2;                  % Assignment 4
Combat_L_D = 4.5;                  % Assignment 4
Loiter_L_D = 11;                   % Assignment 4

% Assignment 5
% Calculated in Assignment 5 using Calc_lapse_rate subfunction
alpha = [.84, 1.28];               % Lapse Rate


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% DO NOT CHANGE BELOW THIS LINE EXCEPT FOR EDITS LOG %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Aircraft Independent Variables

% Assignment 3

b_takeoff = 1;      % Given in Assignment 3 Description
b_combatturn = .78; % Given in Assignment 3 Description
b_landing = 0.6;    % Given in Assignment 3 Description 
% Configuration: Carrier-based, Fixed Wing (or simple fold), Afterburning Turbofans.
W1_W0 = 0.970;      % Given in Assignment 3 Description
W2_W1 = 0.985;      % Given in Assignment 3 Description
W7_W6 = 0.995;      % Given in Assignment 3 Description
Cruise_Out = 700;   % NM, Given in RFP Mission Profile
Combat_Time = 2;    % min Given in RFP Mission Profile
Combat_Speed = 1.6; % Mach Given in RFP Mission Profile
Cruise_Back = 700;  % NM Given in RFP Mission Profile
Loiter_Time = 20;   % minutes Given in RFP Mission Profile
% Raymer Sizing Constraints
A = -0.02;          % Given in Assignment 3
B = 2.16;           % Given in Assignment 3
C1 = -0.1;          % Given in Assignment 3
C2 = 0.2;           % Given in Assignment 3
C3 = 0.04;          % Given in Assignment 3
C4 = -0.10;         % Given in Assignment 3
C5 = 0.08;          % Given in Assignment 3

% Assignment 4

K_A = 0.95;               % From Slide 10 of Drag Polar Notes
C_DW_peak = .058;         % peak CDW, Assumed Wake Drag Conditions
M_DW_peak = 1.25;         % Mach at peak CDW, Assumed Wake Drag Conditions
Qf = 1;                   % From Raymer ch 12
Qn = 1.3;                 % From Raymer ch 12
Qw = 1;                   % From Raymer ch 12
Qvt = 1.03;               % From Raymer ch 12
Qht = 1.08;               % From Raymer ch 12
K_approach = 1.15;        % from Mattingly p.34
K_takeoff = 1.1;          % from slide 19 and Mattingly p.34


%% Calculations (Integration of Assignments 3, 4, 5)
%% Assignment 3
% Fuel Fraction Method

% Initial Cruise
R = Cruise_Out * ft_NM;
C = Cruise_SFC;
V_cruise = V_Cruise;
W3_W2 = exp(-R*C/(V_cruise*Cruise_L_D));

%Combat
E = Combat_Time / 60;
C = Combat_SFC;
W4_W3 = exp(-E*C / Combat_L_D);

%Final Cruise
R = Cruise_Back * ft_NM;
C = Cruise_SFC;
V_cruise = V_Cruise;
W5_W4 = exp(-R*C/(V_cruise*Cruise_L_D));
    
%Loiter
E = Loiter_Time / 60;
C = Loiter_SFC;
W6_W5 = exp(-E*C / Loiter_L_D);

% Determine the Fuel Fraction
k = 0.05 + 0.01; %Coefficent of trapped and reserve fuel, given in the lecture slides
Wf_W0 = (1 + k)*(1 - W7_W6 * W6_W5 * W5_W4 * W4_W3 * W3_W2 * W2_W1 * W1_W0);

for Carrier_Penalty = [0.031]
    W0 = 50000; % Initial guess
    W0i = 0;    
    W0_history = [W0]; % Array to store convergence history
    iter = 0;
    
    while abs(W0 - W0i) > 0.1
        W0i = W0; 
        iter = iter + 1;
       
        % Determine Empty Weight Fraction
        We_W0 = (A + B*(W0^C1)*(AR^C2)*(Thrust_Weight^C3)*(Wing_loading^C4)*(Combat_Speed^C5)*Kvs) + Carrier_Penalty;
        
        % Re-Determine the total weight
        W0 = (W_crew + W_payload) / (1 - Wf_W0 - We_W0);
    end
end 

disp(" ")
disp("------------------------------")
disp("Calculated Max Takeoff Weight (lbs):")
disp(W0)
disp("Calculated Empty Weight (lbs):")
disp(We_W0*W0)
disp("Calculated Fuel Weight (lbs):")
disp(Wf_W0*W0)
disp("------------------------------")
disp(" ")

%% Assignment 4

% Unit setup
u = symunit; % Initialise symbolic units object

aircraft.weight = unitConvert(W0 * u.lbf, u.N);

components_structs = {'fslg','wing','tail_h','tail_v','nacelle'};
for i = 1:length(components_structs)
    eval([components_structs{i} '.ff = struct();']);
end

% Moving Variables around

%fuselage = Fuselage();
fslg.len.diam = dia_fuselage * u.m;
fslg.len.length = len_fuselage * u.m;

% Wing Geometry
wing.span = b * u.ft;
wing.len.chord_root = c_r * u.m;
wing.len.chord_tip = c_t * u.m;
wing.len.chord_mean = (wing.len.chord_root + wing.len.chord_tip) / 2;
wing.area.ref = S_ref * u.ft^2;
wing.thickness_over_chord = t_c_w;
wing.aspect_ratio = AR;
wing.sweep.LE = LES_w;
wing.sweep.QC = QCS_w;
wing.sweep.MC = MCS_w;
tail_h.len.chord_mean = ch_ht * u.m;
tail_h.area_ref = S_ht * u.m^2;
tail_h.thickness_over_chord = t_c_ht;
tail_h.sweep.LE = deg2rad(LES_ht);
tail_h.sweep.QC = deg2rad(QCS_ht);
tail_h.sweep.MC = deg2rad(MCS_ht);
tail_v.area_ref = S_vt * u.m^2; % rewrite as w/ vtail
tail_v.len.chord_mean = ch_vt * u.m;
tail_v.thickness_over_chord = t_c_vt;
tail_v.sweep.LE = deg2rad(LES_vt);
tail_v.sweep.QC = deg2rad(QCS_vt);
tail_v.sweep.MC = deg2rad(MCS_vt);
nacelle.len.length = unitConvert(l_N * u.ft, u.m);
nacelle.len.diameter = unitConvert(d_N * u.ft, u.m);
components = {fslg, wing, tail_h, tail_v, nacelle};
altitude_cruise_sup = h_cruise_sup * u.ft;
altitude_SL = h_Seroc_Strike_dash * u.ft;

% Getting ISA Values for mission parts

t = Atm.temp(altitude_cruise_sup);
rho = Atm.density(altitude_cruise_sup) * u.kg / u.m^3;
a = Atm.sonic_speed(altitude_cruise_sup) * u.m / u.s;
mu = Atm.viscosity_dyn(altitude_cruise_sup) * u.kg / u.m / u.s;

t_SL = Atm.temp(altitude_SL);
rho_SL = Atm.density(altitude_SL) * u.kg / u.m^3;
a_SL = Atm.sonic_speed(altitude_SL) * u.m / u.s;
mu_SL = Atm.viscosity_dyn(altitude_SL) * u.kg / u.m / u.s;

% Part 0.5 
% Oswald effciency factor
e_oswald = 4.61 * (1 - 0.045 * wing.aspect_ratio^0.68) * (cos(wing.sweep.LE)^0.15) - 3.1; % Raymer eq. 12.49

AoA = linspace(-pi/12, pi/3, 251);
% ASSUMING MCS_W 
Kp = (2*pi*wing.aspect_ratio) / (2 + sqrt(wing.aspect_ratio^2 * (1 + tan(wing.sweep.MC)) + 4));

% ASSUMING LES_W 
Kv = pi * wing.aspect_ratio / 2 / cos(wing.sweep.LE); 
C_Lp = Kp * sin(AoA).*(cos(AoA).^2);
C_Lv = Kv * (sin(AoA).^2).*cos(AoA);
C_L = C_Lp + C_Lv;
C_L_noVortex = C_Lp;

% Calculating Form Drag (FF) Factors for Drag Buildup
Z_w = (2 - M^2)*cos(wing.sweep.QC) / sqrt(1 - (M*cos(wing.sweep.QC))^2); % Sweep correction factor from Shevell, slide 15
wing.ff.form = 1 + Z_w*(wing.thickness_over_chord) + 100*(wing.thickness_over_chord)^4;
Z_ht = (2 - M^2)*cos(tail_h.sweep.QC) / sqrt(1 - (M*cos(tail_h.sweep.QC))^2);
tail_h.ff.form = 1 + Z_ht*(tail_h.thickness_over_chord) + 100*(tail_h.thickness_over_chord)^4;
Z_vt = (2 - M^2)*cos(tail_v.sweep.QC) / sqrt(1 - (M*cos(tail_v.sweep.QC))^2);
tail_v.ff.form = 1 + Z_vt*(tail_v.thickness_over_chord) + 100*(tail_v.thickness_over_chord)^4;
nacelle.ff.form = 1 + 0.35 / (nacelle.len.length / nacelle.len.diameter);
fslg.ff.form = 0.9+5/(fslg.len.length/fslg.len.diam)^1.5+(fslg.len.length/fslg.len.diam)/400;
FF = ul([fslg.ff.form wing.ff.form tail_h.ff.form tail_v.ff.form nacelle.ff.form]);

% Interference factors (From Nicolai)
fslg.ff.interference = 1;           % The nacelles are more than Dn away from the fuselage
wing.ff.interference = 1;
tail_v.ff.interference = 1.03;      % Seems both V and conventional
tail_h.ff.interference = 1.08;      % Horizontal stabilizer separate component
nacelle.ff.interference = 1.3;      % Seems less than Dn away from wing
Q = ul([fslg.ff.interference wing.ff.interference tail_h.ff.interference tail_v.ff.interference nacelle.ff.interference]);

%% Have Separate Drag Buildup Function

% Skin friction (Cf) factors for subsonic
fslg.reynolds = separateUnits(fslg.len.length * (V_cruise * rho / mu));
fslg.ff.skin = 0.455 / (log10(fslg.reynolds)^2.58);
wing.reynolds = separateUnits(wing.len.chord_mean * (V_cruise * rho / mu));
wing.ff.skin = 0.455 / (log10(wing.reynolds)^2.58);
tail_h.reynolds = separateUnits(tail_h.len.chord_mean * (V_cruise * rho / mu));
tail_h.ff.skin = 0.455 / ( log10(tail_h.reynolds)^2.58);
tail_v.reynolds = separateUnits(tail_v.len.chord_mean * (V_cruise * rho / mu));
tail_v.ff.skin = 0.455 / ( log10(tail_v.reynolds)^2.58);
nacelle.reynolds = separateUnits(nacelle.len.length * (V_cruise * rho / mu));
nacelle.ff.skin = 0.455 / ( log10(nacelle.reynolds)^2.58);
C_f = ul([fslg.ff.skin wing.ff.skin tail_h.ff.skin tail_v.ff.skin nacelle.ff.skin]);

% Skin friction (Cf) factors for supersonic
fslg.reynolds_sup = separateUnits(fslg.len.length * (V_Sup * rho / mu));
fslg.ff.skin_sup = 0.455 / (log10(fslg.reynolds_sup)^2.58);
wing.reynolds_sup = separateUnits(wing.len.chord_mean * (V_Sup * rho / mu));
wing.ff.skin_sup = 0.455 / (log10(wing.reynolds_sup)^2.58);
tail_h.reynolds_sup = separateUnits(tail_h.len.chord_mean * (V_Sup * rho / mu));
tail_h.ff.skin_sup = 0.455 / ( log10(tail_h.reynolds_sup)^2.58);
tail_v.reynolds_sup = separateUnits(tail_v.len.chord_mean * (V_Sup * rho / mu));
tail_v.ff.skin_sup = 0.455 / ( log10(tail_v.reynolds_sup)^2.58);
nacelle.reynolds_sup = separateUnits(nacelle.len.length * (V_Sup * rho / mu));
nacelle.ff.skin_sup = 0.455 / ( log10(nacelle.reynolds_sup)^2.58);
C_f_sup = ul([fslg.ff.skin_sup wing.ff.skin_sup tail_h.ff.skin_sup tail_v.ff.skin_sup nacelle.ff.skin_sup]);


% Converting to numeric (from symbolic with units)
fslg.len.diam   = dia_fuselage;      % already numeric in meters
fslg.len.length = len_fuselage;      % numeric in meters
wing.len.chord_root = c_r;           % numeric in meters
wing.len.chord_tip  = c_t;           % numeric in meters
wing.area.ref      = S_ref/3.281^2;  % numeric in m^2
tail_h.area_ref    = S_ht;           % numeric in m^2
tail_v.area_ref    = S_vt;           % numeric in m^2
nacelle.len.diameter = d_N/3.281;    % numeric in meters
nacelle.len.length   = l_N/3.281;    % numeric in meters

fslg.fineness_ratio = fslg.len.length/fslg.len.diam;

fslg.area.wet    = pi * fslg.len.diam * fslg.len.length * ((1 - 2/fslg.fineness_ratio)^(2/3)) * (1 + 1/fslg.fineness_ratio^2);
wing.area.wet    = (wing.area.ref - wing.len.chord_root * fslg.len.diam) * 2;
tail_h.area.wet  = tail_h.area_ref * 2;
tail_v.area.wet  = tail_v.area_ref * 2;
nacelle.area.wet = pi * nacelle.len.diameter * nacelle.len.length;

% Combine into numeric array
S_wet = [fslg.area.wet, wing.area.wet, tail_h.area.wet, tail_v.area.wet, nacelle.area.wet];

% component build up for both sub and super sonic
C_D0_sub = sum((FF .* Q .* C_f .* S_wet), 'all')/wing.area.ref;
C_D0_Sup = sum((FF .* Q .* C_f_sup .* S_wet), 'all')/wing.area.ref;
% Add misc drag
C_D0_misc_sub = 0.1 * C_D0_sub;  % estimation from drag pred pg 25
C_D0_sub = C_D0_sub + C_D0_misc_sub; % add the misc values in
C_D0_Sup = 1.1*C_D0_Sup;

% Calculate M_DD
SWP = wing.sweep.QC;  % assuming that the sweep angle given in the eqn is quarter chord sweep for the wing

% Cdwake for both sub and super sonic
C_L_des = ul(aircraft.weight / (0.5 * rho * V_cruise^2 * wing.area.ref));
M_DD = K_A/cos(SWP) - wing.thickness_over_chord/(cos(SWP)^2) - C_L_des / (10 * (cos(SWP)^3));
M_crit = M_DD - 0.08;
% c_dc has something to do with speed in mach
K_sub = 1 / (pi * wing.aspect_ratio * e_oswald);
K_sup = wing.aspect_ratio * (M^2 - 1) * cos(wing.sweep.LE) / (4 * wing.aspect_ratio * sqrt(M^2 - 1) - 2);
C_Di = K_sub * (C_L.^2);
C_Di_noVortex = K_sub * (C_L_noVortex.^2);
C_D = C_D0_sub + C_Di;
C_D_noVortex = C_D0_sub + C_Di_noVortex;

% Part 3: Supersonic Effects and Cruise Efficiency
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
            % Supersonic Region (decay; continuous at M_DW_peak)
            C_D_wake = C_DW_peak * sqrt(Msqpk_minus_1) / sqrt(Msq_minus_1);
            K = wing.aspect_ratio * Msq_minus_1 * cos(wing.sweep.LE) / (4 * wing.aspect_ratio * sqrt(Msq_minus_1) - 2);
        else
            % Transonic Region (Gundlach cubic ramp to the peak)
            scal = C_DW_peak/(M_DW_peak - M_crit)^3;
            C_D_wake = scal * (M - M_crit)^3; % Gundlach Ch. 5 (5.46)
            % Smooth blend 
            x = (M - M_crit) / (M_DW_peak - M_crit);
            x = max(0, min(1, x));
            w = x^2 * (3 - 2*x);  % smoothstep
            K = (1-w)*K_sub_thresh + w*K_sup_thresh;
        end
    else
        % Subsonic Region
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
C_D_ZL = C_D0_sub + C_D_wakes;
figure;
plot(Machs, C_D_ZL)
title('Total Zero-Lift Drag Rise with Mach Number');
xlabel("Mach")
ylabel("C_{DZL}")
grid on;

% Plot 2
LDMax = 1./sqrt(4.*C_D0_sub.*Ks);
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

% Additional graphs

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

%% Assignment 5

wing_loading_range = ul(unitConvert([40 140] * u.lbf / (u.ft^2), u.N / (u.m^2)));
fprintf("Wing loading range: %d - %d Pa\n", wing_loading_range);
wing_loading_range = linspace(wing_loading_range(1), wing_loading_range(2), 511);

% Section 2: Requirements Extraction
% Carrier landing, RFP 3.2.2
v_approach = 140 * u.kts + 0 * u.kts; % typical V_eng from Mattingly p.34, RFP limits approach < 145kn. Should calculate better minimum approach speed from stall margin

% Carrier takeoff, RFP 3.2.1
v_takeoff = 120 * u.kts + 0 * u.kts; % 20 kn WoD from slide 19, 0kn from RFP
min_accel = 0.3 * g; % typical minimum value from Mattingly p.34

% Supersonic Dash, 3.4.1.e
M_supersonic = 1.6;
% Strike Dash, 3.4.2.c
M_strike = 0.85;
% Sustained Turn, 3.4.1.d
turn_rate = 8 * u.deg / u.s;
% SEROC, 3.5.f
seroc_rate = 500 * u.ft / u.min; % at approach config

% Section 4: Analysis Tasks

% 4A: Carrier Limits
% Task A-1: Landing Constraint
p_approach = FlightPhase(0, b_landing, "Low-bypass turbofan, dry thrust", velocity=v_approach);
max_loading_approach = p_approach.wing_loading(C_L_max, K_approach);

% Task A-2: Takeoff Constraint
p_takeoff = FlightPhase(0, b_takeoff, "Low-bypass turbofan, wet thrust", velocity=v_takeoff, dv_dt=min_accel);
max_loading_takeoff = p_takeoff.wing_loading(C_L_max, K_takeoff);

% Hardcoded C_D0 and K values from assignment 4, to be refactored/corrected later
% 4B: Performance Limits
% Task B
% Task B-1: Supersonic Dash, Mach 1.6 @ 35kft, wet thrust
p_supersonic = FlightPhase(h_cruise_sup * u.ft, b_combatturn, "Low-bypass turbofan, wet thrust", mach_number=M_supersonic);
twr_supersonic = p_supersonic.twr(wing_loading_range, C_D0_Sup, K_sup);

% Task B-2: Strike Dash, Mach 0.85 @ SL, dry thrust
p_strike = FlightPhase(0, b_combatturn, "Low-bypass turbofan, dry thrust", mach_number=M_strike);
twr_strike = p_strike.twr(wing_loading_range, C_D0_sub, K_sub);

% Task B-3: Sustained Turn, 8 deg/s @ 20k ft, M0.7, 0.8, 0.9, wet thrust
% Mattingly eq. 2.2.3
turn_speeds = [0.7 0.8 0.9];
C_D0_turn = [0.0193 0.0193 0.0195];
K_turn = [0.0894 0.0894 0.0955];
for i = 1:length(turn_speeds)
    p_turn(i,:) = FlightPhase(20000 * u.ft, b_combatturn, "Low-bypass turbofan, wet thrust", mach_number=turn_speeds(i));
    twr_turn(i,:) = p_turn(i).twr(wing_loading_range, C_D0_turn(i), K_turn(i));
end

% Task B-4: SEROC, 500 ft/min single-engine in approach config, wet thrust?
p_seroc = FlightPhase(0, b_landing, "Low-bypass turbofan, wet thrust", velocity=v_approach, dh_dt=500*u.ft/u.min);
twr_seroc = p_seroc.twr(wing_loading_range, 0.0195, K_sub);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WHY ARE THESE CD0 AND K VALUES DIFFERENT/THE SAME?!?!?!??!??!??!?!??!???
% example: twr = p.twr(wing_loading_range, CDO, K);
%
% twr_supersonic = p_supersonic.twr(wing_loading_range, 0.0541, 0.3005);
% twr_strike = p_strike.twr(wing_loading_range, 0.0195, 0.0955);
% twr_seroc = p_seroc.twr(wing_loading_range, 0.0195, 0.0955);

% Numbers work for strike phase, fix for supersonic and SEROC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

installedthrust = 43000*.97*2;

figure(8)
hold on
plot(wing_loading_range, twr_supersonic, Linewidth = 2)
plot(wing_loading_range, twr_strike, Linewidth = 2)
plot(wing_loading_range, twr_turn(1,:), Linewidth = 2)
plot(wing_loading_range, twr_turn(2,:), Linewidth = 2)
plot(wing_loading_range, twr_turn(3,:), Linewidth = 2)
plot(wing_loading_range, twr_seroc, Linewidth = 2)
xline(max_loading_takeoff, "m", Linewidth = 2);
xline(max_loading_approach, Linewidth = 2)
yline(installedthrust/W0, 'c', Linewidth = 2)
legend("supersonic", "subsonic", "turn1", "turn2", "turn3", "SEROC", "Take-Off Limit", "Landing Limit", "Propulsion System Thrust", Location="best")
title("Team 5 Constraint Diagram")
xlabel("W/S (Pa)")
ylabel("T/W")
grid on
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change Log:
% 2/8/2026:     Version 1.0
% Original Creation
%
% 2/16-18/2026: Version 1.1 
% Reworked Code, began working in chosen design parameters from Assignment 7
%
% 2/23/2026:    Version 1.2
% Checked Variables, noted important assumptions, formatted                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%