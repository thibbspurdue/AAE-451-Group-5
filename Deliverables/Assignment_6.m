% AAE 451 Spring 2026
% Assignment 6
% Team 5
% VERSION 1.0

%% Variables
% This section has all variables used in other Assignment Codes. Variables
% are used in assignment codes that influence this code.

%% Assignment 3

% Given in Assignment Description
% W_payload = 6000; %lbs
% W_crew = 215; %lbs
% % Configuration: Carrier-based, Fixed Wing (or simple fold), Afterburning Turbofans.
% W1_W0 = 0.970;
% W2_W1 = 0.985;

% Given in RFP Mission Profile
% Cruise_Out = 700; %NM
% Combat_Time = 2; %min
% Combat_Speed = 1.6; %Mach
% Cruise_Back = 700; %NM

% Loiter optional, possibility of removal
% Loiter_Time = 20; %minutes

% Given in Assignment 3 Description
% W7_W6 = 0.995;
% Cruise_SFC = 0.82; %lb/lbf * hr
% Combat_SFC = 1.844; %lb/lbf * hr
% Loiter_SFC = 0.80; %lb/lbf * hr

% Calculated in Assignment 4
% %Cruise_L_D = 9.2;
% %Combat_L_D = 4.5;
% Cruise_L_D = 7.279;
% Combat_L_D = 8.41;
% Loiter_L_D = 11;

% Given in Assignment 3
% Raymer Sizing Constraints
% A = -0.02;
% B = 2.16;
% C1 = -0.1;
% C2 = 0.2;
% C3 = 0.04;
% C4 = -0.10;
% C5 = 0.08;
% Kvs = 1;  % 1 for fixed wing sweep

%% Assignment 4:
% W = 58068.58;
% K_A = 0.95                         % Supercritical airfoild number thing slide 10

% Calculated Based off of chosen Airfoil
% AR = 4;                            % Aspect Ratio
% dia_fuselage = 2.165;              % Fuselage diameter
% len_fuselage = 60.299;             % Fuselage length
% b = 58.1;                           % wingspan (ft)
% S_ref = 842.8142;                           % not super sure if this is S or not

% Based on Assignment 1 and measurements of online aircraft model
% % Wing Geometry
% t_c_w = 0.04;                      % thickness over chord wing, u/l
% MCS_w = deg2rad(19.52);            % Wing midchord sweep, rad
% QCS_w = deg2rad(25);               % Wing quarter chord sweep, rad
% LES_w = deg2rad(30);               % Wing leading edge sweep, rad
% c_r = 4.611 * 3.2808399;           % Wing root chord, ft -> m
% c_t = 1.5 * 3.2808399;             % Wingtip chord, ft -> m
% %ch_w = (c_r + c_t)/2;              % Wing mean chord, ft -> m
% ch_w = 15.5;                    % Chord length of the wing (ft) --> 4.58325 m
% S = S_ref;                           % Wing reference area, ft^2
% S_w = S;                           % Wing area, ft^2, (should subtract fuselage overlap)
% % Horizontal Tail Geometry
% t_c_ht = .04;                      % thickness over chord (dimensionless)
% MCS_ht = 31.943 * (pi/180);        % Mid chord sweep (deg)
% QCS_ht = 48.28571 * (pi/180);      % Quarter chord sweep (deg)
% LES_ht = 53.12 * (pi/180);         % Leading edge sweep (deg)
% ch_ht = 9.18635;                   % Chord length of the horizontal tail (ft) --> 2.8 m
% % Vertical Tail Geometry
% t_c_vt = .04;             % thickness over chord (dimensionless)
% MCS_vt = 36.3239 * (pi/180);         % Mid chord sweep (deg)
% QCS_vt = 42.52679 * (pi/180);        % Quarter chord sweep (deg)
% LES_vt = 47.69 * (pi/180);           % Leading edge sweep (deg)
% ch_vt = 10.3937;          % Chord length of the vertical tail (ft) --> 3.168 m
% S_ht = (2 * 3.56067 * 0.5 * (4.10919 + 1.112)) * 10.7639; % 10.7639 is m2 to ft2 conversion
% S_vt = (2 * 3.7 * 0.5 * (4.51 + 1.82)) * 10.7639;
% % Nacelle Geometry
% l_N = 29.9367;            % Nacelle length (ft) --> 8.2103 m
% d_N = 3.02057;            % Nacelle diameter (ft) --> .92067 m

% From ISA tables
% %V = 516;                  % flight velocity 
% h = 40000;                % altitude (FEET)
% p = 5.87*10^-4;           % air density (Slugs/ft^3)
% a = 659.8 * 1.4667;                % speed of sound (mph --> ft / s)
% M = 0.9;
% V = M * a;
% %q = 100691.89;            % dynamic pressure (Pa)
% mu = 2.969*10^-7;         % kinematic viscosity (slug/(ft s))

% Assumed Wake Drag Conditions
% C_DW_peak = .058;         % peak CDW
% M_DW_peak = 1.25;         % Mach at peak CDW

% From Raymer ch 12
% Qf = 1;          % The nacelles seem more than Dn away from the fuselage
% Qn = 1.3;        % Seems less than Dn away from wing
% Qw = 1;
% Qvt = 1.03;      % Seems both V and conventional
% Qht = 1.08;      % Horizontal stabilizer separate component

%% Calculations
% Unit setup
u = symunit; % Initialise symbolic units object

function output = ul(input)
    output = double(separateUnits(input));
end

% Constants (dimensionless), given in Assignment 3
b_takeoff = 1;
b_combatturn = .78;
b_landing = 0.6;

g = 9.81; % m/s^2 

%% Section 2: Requirements Extraction

% Carrier landing, RFP 3.2.2
v_approach_max = 0;

% Carrier takeoff, RFP 3.2.1
v_end = 0;
v_wod = 0;
% Supersonic Dash, 3.4.1.e
M_supersonic = 1.6;
% Strike Dash, 3.4.2.c
M_strike = 0.85;
% Sustained Turn, 3.4.1.d
turn_rate = 8 * u.deg / u.s;
% SEROC, 3.5.f
seroc_rate = 500 * u.ft / u.min; % at approach config

%% Section 3: Engineering Assumptions

% Aerodynamics
% Pulled from Assignment 4
C_D0 = .0193;
CD_w = .0190;
C_L = 2;
K = .3005;

% Weight Fractions
% Pulled from Assignment 4
beta = [1, .78, .6];

% Propulsion
% Pulled from Assignment 5
alpha = [.84, 1.28];

%% Section 4: Analysis Tasks
%%% 4A: Carrier Limits
% Task A-1: Landing Constraint
load_factor = 0.6;

% Task A-2: Takeoff Constraint
load_factor = 1;

%%% 4B: Performance Limits
function twr = twr(wing_loading, alpha, beta, rho, V, C_D0, C_L, K, g, dh_dt, dv_dt)
    twr = rho * V^2 .* (C_D0 + K * C_L^2) / beta / wing_loading;
    twr = twr + dh_dt / V + dv_dt / g;
    twr = twr * beta / alpha;
end

altitudes = ul(unitConvert(u.ft * [30000 0 20000 0], u.m));
[~, speed_M1, ~, rho] = atmosisa(altitudes); % retain speed of sound and density, m/s; kg*m^-3

wing_loading_range = ul(unitConvert([40 140] * u.lbf / (u.ft^2), u.N / (u.m^2)));
wing_loading_range = linspace(wing_loading_range(1), wing_loading_range(2), 511);

% Task B-1: Supersonic Dash, Mach 1.6 @ 30kft, wet thrust
% W_TO_S__min_TWR_supersonic = q / beta * sqrt((C_D0 + C_DR) / K_1);
% TWR_min_supersonic = beta / alpha * (2 * sqrt(K_1 * (C_D0 + C_DR)) + K_2);
weight_fraction(1) = 0.78; % Assignment 5-3B
load_factor(1) = 1; % g, level flight
dh_dt(1) = 0; % climb component
dv_dt(1) = 0; % acceleration component
V(1) = speed_M1(1) * M_supersonic; % airspeed, m/s
%twr_supersonic = twr(wing_loading_range, alpha(1), beta(1), rho(1), V(1), C_D0(1), C_L(1), K(1), g, dh_dt(1), dv_dt(1));
p_supersonic = FlightPhase(30000 * u.ft, b_combatturn, "Low-bypass turbofan, wet thrust", mach_number=M_supersonic);
twr_supersonic = p_supersonic.twr(wing_loading_range, 0.0541, 0.3005);

% Task B-2: Strike Dash, Mach 0.85 @ SL, dry thrust
% W_TO_S__min_TWR_strike = q / beta * sqrt((C_D0 + C_DR) / K_1);
% TWR_min_strike = beta / alpha * (2 * sqrt(K_1 * (C_D0 + C_DR)) + K_2);
weight_fraction(2) = 0.78; % Assignment 5-3B
load_factor(2) = 0; % g, level flight
dh_dt(2) = 0;
dv_dt(2) = 0;
V(2) = speed_M1(2) * M_strike; % m/s

% Task B-3: Sustained Turn, 8 deg/s @ 20k ft, M0.7, 0.8, 0.9, wet thrust
% Mattingly eq. 2.2.3
% W_TO_S__min_TWR_turn = q / n / beta * sqrt((C_D0 + C_DR) / K_1);
% TWR_min_turn = n * beta / alpha * (2 * sqrt(K_1 * (C_D0 + C_DR)) + K_2);
weight_fraction(3) = 0.78; % Assignment 5-3B
dh_dt(3) = 0;
dv_dt(3) = 0;
for i = [0.7 0.8 0.9]
    V(3) = speed_M1(3) * i;
    load_factor = sqrt(1 + (V(3) *  ul(unitConvert(turn_rate, u.rad / u.s)) / g)^2);
end

% Task B-4: SEROC, 500 ft/min single-engine in approach config, wet thrust?
% Mattingly eq. 2.14
% W_TO_S__min_TWR_SEROC = q / beta * sqrt((C_D0 + C_DR) / K_1);
% TWR_min_SEROC = beta / alpha * (2 * sqrt(K1 * (C_D0 + C_DR)) + K_2);
weight_fraction(4) = 0.78; % Assignment 5-3B
load_factor(4) = 1; % g, n >= 1 for steady climb
dh_dt(4) = ul(unitConvert(seroc_rate, u.m / u.s));
dv_dt(4) = 0;
V(4) = ul(unitConvert(145 * u.kts, u.m / u.s)); % Maximum approach speed from RFP