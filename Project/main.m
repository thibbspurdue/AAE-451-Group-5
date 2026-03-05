% AAE 451 Spring 2026
% Assignment 6
% Team 5
% VERSION 1.3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% u = symunit function all inputs are multiplied by u.unit. With ul(),
% these parameters are then converted to metric and become unsymbolic.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Global variables
u = symunit;
g = 9.81 * u.m / u.s^2;

% Aircraft geometric parameters
wing = Wing( ...
    "wingspan", 18.288 * u.m, ...                  Sunfish specific
    "thickness_chord_ratio", 0.15, ...             Sunfish specific
    "aspect_ratio", 3.325, ...                     Sunfish specific
    "root_chord", 11 * u.m, ...                    Sunfish specific
    "leading_edge_sweep", 33.8 * u.deg, ...        Sunfish specific
    "interference_factor", 1 ...                                                               From Week 3 AAE451_04_Drag_Prediction
    );

tail = Stabilizer( ...
    "length", 4.95 * u.m, ...                      Sunfish specific
    "thickness_chord_ratio", 0.06, ...             Sunfish specific
    "aspect_ratio", 2, ...                         Sunfish specific
    "root_chord", 2.5 * u.m, ...                   Sunfish specific
    "leading_edge_sweep", 0, ...                   Sunfish specific
    "interference_factor", 1.08 ...                                                            From Week 3 AAE451_04_Drag_Prediction
    );

engine = Engine( ...
    "intermediate_SFC", 0.88 * u.lbm/(u.lbf*u.hr), ...                                         F135 engine data
    "wet_SFC", 1.92 * u.lbm/(u.lbf*u.hr), ...                                                  F135 engine data
    "loiter_sfc", 0.70 * u.lbm/(u.lbf*u.hr), ...                                               F135 engine data
    "max_thrust", 43000 * u.lbf ...                                                            F135 engine data
    );

molamola = Aircraft( ...
    wing = wing, ...
    stabilizer = tail, ...
    engine = engine, ...
    wing_location = 0 * u.m, ...                   Sunfish specific, distance of wing aerodynamic centre from nose
    stabilizer_qty = 2, ...                        Sunfish specific
    stabilizer_location = 8 * u.m, ...             Sunfish specific, distance of tail aerodynamic centre from nose
    engine_qty = 2, ...                            Sunfish specific
    mass = 60000 * u.lbm ...                       Sunfish specific estimate
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial weight sizing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ideally run this for both combat and strike mission profiles
init.cruise.alt = 40000 * u.ft;                  % iterative param
init.cruise.mach = 0.9;                          % iterative param
init.cruise.range = 1000 * u.inm;                                                            % RFP 3.4.1a
init.cruise.l_d = 1 / (2 * sqrt(molamola.calc_cd0(init.cruise.alt, init.cruise.mach) * init.K)); % Raymer eq. 5.4

init.combat.alt = 10000 * u.ft;                                                              % RFP 3.4.1b
init.combat.mach = 1.2;                          % Estimated value, RFP 3.4.1b requires max thrust
init.combat.duration = 2 * u.min;                                                            % RFP 3.4.1b
init.combat.l_d = 1 / (2 * sqrt(molamola.calc_cd0(init.combat.alt, init.combat.mach) * init.K)); % Raymer eq. 5.4

int.loiter.alt = 20000 * u.ft;                                                               % RFP 3.2.2c

init.K = 1 / (pi * molamola.aspect_ratio * molamola.wing.oswald_eff);                                % Raymer eq. 5.5
init.weight_fracs = [ ...
    0.970, ...                                                                                 Warm-up & takeoff fraction, from A03
    0.985, ...                                                                                 Climb fraction, from A03
    0.995 ...                                                                                  Raymer landing fraction, from A03
    ];

init.weight_fracs(end+1) = engine.cruise_frac(init.cruise.range, init.cruise.vel, init.cruise.l_d) ^ 2; % Squared for round-trip fraction, RFP 3.4.1
init.weight_fracs(end+1) = engine.combat_frac(init.combat.duration, init.combat.l_d);        % Combat fraction, RFP 3.4.1
init.weight_fracs(end+1) = engine.combat_frac(init.combat.duration, init.combat.l_d);        % Combat fraction, RFP 3.4.1

init.reserve_margin = 0.05;                                                                  % Raymer 5.4
init.trapped_margin = 0.01;                                                                  % Raymer 5.4

init.fixed_mass = ...
    2 * 6422 * u.lbm + ...                       % 2x F135-PW-100/400 mass
    2500 * u.lbm + ...                                                                       % Internal avionics/sensor weight, RFP 3.3.1a
    6000 * u.lbm;                                                                            % Payload weight (2x ea. GBU-31/AIM-20/AIM-9x + ammo), A03

% Calculation

init.final_weight_frac = prod(init.weight_fracs);
init.fuel_weight = (1 + init.reserve_margin + init.trapped_margin) * (1 - init.final_weight_frac);
