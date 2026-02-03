% AAE 451 Spring 2026
% Assignment 5
% Team 5

%% Initialisation

% Unit setup
u = symunit; % Initialise symbolic units object

% Constants (add units please!)
b_takeoff = 1;
b_combatturn = .78;
b_landing = 0.6;

%% Section 2: Requirements Extraction

% Carrier landing, RFP 3.2.2
v_approach_max = 0;

% Carrier takeoff, RFP 3.2.1
v_end = 0;
v_wod = 0;
% Supersonic Dash, 3.4.1.e

% Strike Dash, 3.4.2.c

% Sustained Turn, 3.4.1.d

% SEROC, 3.5.f
seroc_rate = 500 * u.ft / u.min; % at approach config(?)

%% Section 3: Engineering Assumptions

% Aerodynamics

% Weight Fractions

% Propulsion

%% Section 4: Analysis Tasks
%%% 4A: Carrier Limits
% Task A-1: Landing Constraint

% Task A-2: Takeoff Constraint


%%% 4B: Performance Limits

function twr = twr(beta, alpha, q, S, W_TO, n, K_1, K_2, C_D0, C_DR, P_s, V) % Mattingly eq. 2.11
    twr = K_1 .* (n .* beta .* W_TO ./ q ./ S).^2 + K_2 .* (n .* beta .* W_TO ./ q ./ S) + C_D0 + C_DR;
    twr = (twr .* ((q .* S) / (beta .* W_TO))) + (P_s ./ V);
    twr = twr .* beta / alpha;
end

% Task B-1: Supersonic Dash

% Task B-2: Strike Dash

% Task B-3: Sustained Turn

% Task B-4: SEROC
