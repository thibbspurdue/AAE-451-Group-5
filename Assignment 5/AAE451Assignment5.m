% AAE 451 Spring 2026
% Assignment 5
% Team 5

%% Initialisation

% Unit setup
u = symunit; % Initialise symbolic units object

function output = ul(input)
    output = double(separateUnits(input));
end

% Constants (add units please!)
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

% Weight Fractions

% Propulsion

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
twr_supersonic = twr(wing_loading_range, alpha(1), beta(1), rho(1), V(1), C_D0(1), C_L(1), K(1), g, dh_dt(1), dv_dt(1));

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