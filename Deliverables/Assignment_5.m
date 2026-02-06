% AAE 451 Spring 2026
% Assignment 5
% Team 5


%% Initialisation

% Unit setup
u = symunit; % Initialise symbolic units object
g = 9.81; % m*s^-2

wing_loading_range = ul(unitConvert([40 140] * u.lbf / (u.ft^2), u.N / (u.m^2)));
fprintf("Wing loading range: %d - %d Pa\n", wing_loading_range);
wing_loading_range = linspace(wing_loading_range(1), wing_loading_range(2), 511);

% Constants
beta_takeoff = 1;
beta_combat = .78;
beta_landing = 0.6;

% Function calls
% mach_numbers = linspace(0,2,201);
% [C_L, C_D0, Ks] = assignment4(mach_numbers); % Deprecated until
% assignment 4 is refactored/fixed?

% Section 2: Requirements Extraction

K_approach = 1.15; % from Mattingly p.34
K_takeoff = 1.1; % from slide 19 and Mattingly p.34

% Carrier landing, RFP 3.2.2
v_approach = 140 * u.kts + 0 * u.kts; % typical V_eng from Mattingly p.34, RFP limits approach < 145kn. Should calculate better minimum approach speed from stall margin(?)
C_L_max = 2; % assignment 4 needs to be fixed, temporarily borrwing value from Mattingly p.43

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


%% Section 4: Analysis Tasks

%%% 4A: Carrier Limits
% Task A-1: Landing Constraint
p_approach = FlightPhase(0, beta_landing, "Low-bypass turbofan, dry thrust", velocity=v_approach);
max_loading_approach = p_approach.wing_loading(C_L_max, K_approach);

% Task A-2: Takeoff Constraint
p_takeoff = FlightPhase(0, beta_takeoff, "Low-bypass turbofan, wet thrust", velocity=v_takeoff, dv_dt=min_accel);
max_loading_takeoff = p_takeoff.wing_loading(C_L_max, K_takeoff);


% Hardcoded C_D0 and K values from assignment 4, to be refactored/corrected later
%%% 4B: Performance Limits
% Task B
% Task B-1: Supersonic Dash, Mach 1.6 @ 30kft, wet thrust
p_supersonic = FlightPhase(30000 * u.ft, beta_combat, "Low-bypass turbofan, wet thrust", mach_number=M_supersonic);
twr_supersonic = p_supersonic.twr(wing_loading_range, 0.0541, 0.3005);

% Task B-2: Strike Dash, Mach 0.85 @ SL, dry thrust
p_strike = FlightPhase(0, beta_combat, "Low-bypass turbofan, dry thrust", mach_number=M_strike);
twr_strike = p_strike.twr(wing_loading_range, 0.0195, 0.0955);

% Task B-3: Sustained Turn, 8 deg/s @ 20k ft, M0.7, 0.8, 0.9, wet thrust
% Mattingly eq. 2.2.3
turn_speeds = [0.7 0.8 0.9];
C_D0_turn = [0.0193 0.0193 0.0195];
K_turn = [0.0894 0.0894 0.0955];
for i = 1:length(turn_speeds)
    p_turn(i,:) = FlightPhase(20000 * u.ft, beta_combat, "Low-bypass turbofan, wet thrust", mach_number=turn_speeds(i));
    twr_turn(i,:) = p_turn(i).twr(wing_loading_range, C_D0_turn(i), K_turn(i));
end

% Task B-4: SEROC, 500 ft/min single-engine in approach config, wet thrust?
p_seroc = FlightPhase(0, beta_landing, "Low-bypass turbofan, wet thrust", velocity=v_approach, dh_dt=500*u.ft/u.min);
twr_seroc = p_seroc.twr(wing_loading_range, 0.0195, 0.0955);

figure(1)
hold on
plot(wing_loading_range, twr_supersonic)
plot(wing_loading_range, twr_strike)
plot(wing_loading_range, twr_turn(1,:))
plot(wing_loading_range, twr_turn(2,:))
plot(wing_loading_range, twr_turn(3,:))
plot(wing_loading_range, twr_seroc)

xline(max_loading_takeoff);
xline(max_loading_approach)

legend("supersonic", "subsonic", "turn1", "turn2", "turn3", "SEROC", "Take-Off Limit", "Landing Limit")
hold off