% AAE 451 Spring 2026
% Assignment 6
% Team 5
% VERSION 1.3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% u = symunit function all inputs are multiplied by u.unit. With ul(),
% these parameters are then converted to metric and become unsymbolic.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
u = symunit;      % Initialise symbolic units object

% Variables
% This section has all variables used in other Assignment Codes. Variables
% are used in assignment codes that influence this code.
g = 9.81;         % m/s^2

%% Aircraft Dependent Variables

% Assignment 3

loiter_frac = @(sfc, l_d_ratio, endurance) exp(-endurance * sfc / l_d_ratio);
cruise_frac = @(sfc, l_d_ratio, velocity, range) exp(-range * sfc / velocity / l_d_ratio);

Cruise_SFC = g * ul(0.88*u.lbm/(u.lbf*u.hr));  % lb/lbf * hr, F135 engine data
Combat_SFC = g * ul(1.92*u.lbm/(u.lbf*u.hr));  % lb/lbf * hr, F135 engine data
Loiter_SFC = g * ul(0.70*u.lbm/(u.lbf*u.hr));  % lb/lbf * hr, F135 engine data
W_payload = ul(10215 * u.lbm);                 % 2500 lb avionics suite + 7500 lb engines
%W_crew = ul(215 *u.lbm);                      % Given in Assignment 3 Description
Kvs = 1;                                       % 1 for fixed wing sweep
V_Cruise = ul(516 * u.inm/u.hr);               % Nicolai (136), Assumption that Cruise is 0.9 at alt 36000-45000
V_Sup = ul(918 * u.inm/u.hr);                  % Supersonic is 1.6
Wing_loading = ul(93*u.lbm/(u.ft)^2);          % lb/ft^2
Thrust_Weight = 1.2;                           % Chosen Design Parameter

% Assignment 4
h_cruise_sup = ul(40000*u.ft);                 % altitude (FEET)
h_Seroc_Strike_dash = ul(100*u.ft);            % altitude (FEET) at SL
M = 0.9;                                       % Assumed cruise speed, 
% Chosen Design Parameters
AR_w = 3.325;                                  
AR_ht = 1.989699;
AR_vt = AR_ht;
dia_fuselage = ul(2.165*u.m);                  % Fuselage diameter (m)
len_fuselage = ul(18.379*u.m);                 % Fuselage length (m)
b = ul(18.288*u.m);                            % wingspan (ft), Sunfish Specific
S_ref = ul(100.584*u.m^2);                     % reference area (ft^2)



% beta = [1, .78, .6];                           % Weight Fractions From Assignment 4
% UPDATE                             
C_L_max = 1.5;                                 % From Chosen Airfoil

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

% FIX if time, not used so not required
alpha = [.84, 1.28];               % Lapse Rate

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% DO NOT CHANGE BELOW THIS LINE EXCEPT FOR EDITS LOG %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Aircraft Independent Variables

% Assignment 3

b_takeoff = 1;          % Given in Assignment 3 Description
b_combatturn = .78;     % Given in Assignment 3 Description
b_landing = 0.6;        % Given in Assignment 3 Description 
% Configuration: Carrier-based, Fixed Wing (or simple fold), Afterburning Turbofans.
W1_W0 = 0.970;          % Given in Assignment 3 Description
W2_W1 = 0.985;          % Given in Assignment 3 Description
W7_W6 = 0.995;          % Given in Assignment 3 Description
Cruise_Out = ul(700*u.nmile);       % NM, Given in RFP Mission Profile
Combat_Time = ul(2*u.min);        % min Given in RFP Mission Profile
Combat_Speed = 1.6;     % Mach Given in RFP Mission Profile
Cruise_Back = ul(700*u.nmile);      % NM Given in RFP Mission Profile
Loiter_Time = ul(20*u.min);       % minutes Given in RFP Mission Profile
% Raymer Sizing Constraints
A = -0.02;              % Given in Assignment 3
B = 2.16;               % Given in Assignment 3
C1 = -0.1;              % Given in Assignment 3
C2 = 0.2;               % Given in Assignment 3
C3 = 0.04;              % Given in Assignment 3
C4 = -0.10;             % Given in Assignment 3
C5 = 0.08;              % Given in Assignment 3

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
R = Cruise_Out;
C = Cruise_SFC;
V_cruise = V_Cruise;
W3_W2 = exp(-R*C/(V_cruise*Cruise_L_D));

%Combat
E = Combat_Time;
C = Combat_SFC;
W4_W3 = exp(-E*C / Combat_L_D);

%Final Cruise
R = Cruise_Back;
C = Cruise_SFC;
V_cruise = V_Cruise;
W5_W4 = exp(-R*C/(V_cruise*Cruise_L_D));
    
%Loiter
E = Loiter_Time;
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
        We_W0 = (A + B*(W0^C1)*(aircraft_wing.aspect_ratio^C2)*(Thrust_Weight^C3)*(Wing_loading^C4)*(Combat_Speed^C5)*Kvs) + Carrier_Penalty;
        
        % Re-Determine the total weight
        % W0 = (W_crew + W_payload) / (1 - Wf_W0 - We_W0);
        W0 = (W_payload) / (1 - Wf_W0 - We_W0);
    end
end 
disp(" ")
disp("------------------------------")
disp("Calculated Max Takeoff Weight (kg):")
disp(W0)
disp("Calculated Empty Weight (kg):")
disp(We_W0*W0)
disp("Calculated Fuel Weight (kg):")
disp(Wf_W0*W0)
disp("------------------------------")
disp(" ")

%% Assignment 4

aircraft.weight = ul(unitConvert(W0 * u.lbf, u.N));

% Defining component objects


comp_list = {aircraft_wing, tail_h_obj, tail_v_obj};

%% Have Separate Drag Buildup Function

C_L_des = ul(aircraft.weight / (0.5 * Atm.density(40000) * V_cruise^2 * aircraft_wing.reference_area));
M_DD = K_A/cos(aircraft_wing.leading_edge_sweep) - aircraft_wing.thickness_chord_ratio/(cos(aircraft_wing.leading_edge_sweep)^2) - C_L_des / (10 * (cos(aircraft_wing.LE_sweep)^3));
M_crit = M_DD - 0.08;

%% --- 3. DYNAMIC DRAG BUILDUP LOOP ---
Machs = linspace(0.1, 2.5, 53); 
C_D0_total = zeros(size(Machs));
C_D_wakes  = zeros(size(Machs));
Ks         = zeros(size(Machs));
% Matrix to store [Wing_CD0, H_Tail_CD0, V_Tail_CD0] for every Mach
CD0_breakdown = zeros(length(comp_list), length(Machs));

h_analysis = h_cruise_sup; 

for i = 1:length(Machs)
    M = Machs(i);
    
    % --- Step A: Parasitic Drag (CD0) ---
    current_CD0_sum = 0;
    for k = 1:length(comp_list)
        comp = comp_list{k};
        % Local CD0 for this specific component
        comp_local_cd0 = comp.calc_cd0(h_analysis, "mach_number", M);
        
        % Normalize to S_ref and store in breakdown matrix
        scaled_cd0 = comp_local_cd0 * comp.reference_area / S_ref_main_m2;
        CD0_breakdown(k, i) = scaled_cd0;
        
        current_CD0_sum = current_CD0_sum + scaled_cd0;
    end
    C_D0_total(i) = 1.1 * current_CD0_sum; % 10% misc drag
    
    % --- Step B: Induced & Wake Drag Logic ---
    V_M = ul(M * Atm.sonic_speed(h_analysis));
    q_M = 0.5 * Atm.density(h_analysis) * V_M^2;
    C_L_M = ul(aircraft.weight / (q_M * aircraft_wing.reference_area));
    
    K_sub = 1 / (pi * aircraft_wing.aspect_ratio * aircraft_wing.oswald_eff);
    Msq_m1 = max(M^2 - 1, 0.001);
    Mpeak_m1 = max(M_DW_peak^2 - 1, 0.001);
    
    if (M >= M_crit)
        if (M >= M_DW_peak)
            C_D_wake = C_DW_peak * sqrt(Mpeak_m1) / sqrt(Msq_m1);
            K = aircraft_wing.aspect_ratio * Msq_m1 * cos(aircraft_wing.LE_sweep) / (4 * aircraft_wing.aspect_ratio * sqrt(Msq_m1) - 2);
        else
            scal = C_DW_peak / (M_DW_peak - M_crit)^3;
            C_D_wake = scal * (M - M_crit)^3; 
            x = (M - M_crit) / (M_DW_peak - M_crit);
            w = x^2 * (3 - 2*x);
            K_sup_limit = aircraft_wing.aspect_ratio * Mpeak_m1 * cos(aircraft_wing.LE_sweep) / (4 * aircraft_wing.aspect_ratio * sqrt(Mpeak_m1) - 2);
            K = (1-w)*K_sub + w*K_sup_limit;
        end
    else
        C_D_wake = 0;
        K = K_sub;
    end
    
    C_D_wakes(i) = C_D_wake;
    Ks(i) = K;
end

%% --- 4. LIFT & DRAG POLAR CALCULATIONS ---
% Define Alpha Range
AoA_deg = linspace(-5, 30, 100);
AoA_rad = deg2rad(AoA_deg);

% Lift Curve Logic (Linear + Vortex Lift)
% Using Kp and Kv from your original code logic
Kp = (2*pi*aircraft_wing.aspect_ratio) / (2 + sqrt(aircraft_wing.aspect_ratio^2 * (1 + tan(aircraft_wing.MC_sweep)^2) + 4));
Kv = pi * aircraft_wing.aspect_ratio / (2 * cos(aircraft_wing.LE_sweep)); 

CL_linear = Kp * sin(AoA_rad) .* cos(AoA_rad).^2;
CL_vortex = Kv * sin(AoA_rad).^2 .* cos(AoA_rad);
CL_total  = CL_linear + CL_vortex;

% Drag Polar at Cruise Mach (e.g., M = 0.9)
[~, cruise_idx] = min(abs(Machs - 0.9));
CD0_cruise = C_D0_total(cruise_idx);
K_cruise   = Ks(cruise_idx);

% Total Drag: CD = CD0 + K*CL^2
CD_polar = CD0_cruise + K_cruise * (CL_total.^2);

%% --- 5. FINAL PLOTTING SUITE ---
% Indices for Mach-specific plots
[~, idx_sub] = min(abs(Machs - 0.9));
[~, idx_sup] = min(abs(Machs - 1.6));
comp_labels = {'Wing', 'H-Tail', 'V-Tail'};

% PLOT 1: Total Zero-Lift Drag Rise
figure('Name', 'CD_ZL vs Mach');
plot(Machs, C_D0_total + C_D_wakes, 'LineWidth', 2);
title('Total Zero-Lift Drag Rise (C_{D,0} + C_{D,wake})');
xlabel('Mach Number'); ylabel('C_{D,ZL}'); grid on;

% PLOT 2: Maximum Lift-to-Drag Ratio
LDMax_vec = 1 ./ sqrt(4 .* C_D0_total .* Ks);
figure('Name', 'LD_Max vs Mach');
plot(Machs, LDMax_vec, 'r', 'LineWidth', 2);
title('Maximum Lift-to-Drag Ratio vs Mach');
xlabel('Mach Number'); ylabel('(L/D)_{max}'); grid on;

% PLOT 3: Cruise Efficiency Index
figure('Name', 'Efficiency Index');
plot(Machs, Machs .* LDMax_vec, 'g', 'LineWidth', 2);
title('Cruise Efficiency Index (M \times L/D_{max})');
xlabel('Mach Number'); ylabel('M \cdot (L/D)_{max}'); grid on;

% PLOT 4: Subsonic CD0 Breakdown (M=0.9)
figure('Name', 'Subsonic Breakdown');
bar(CD0_breakdown(:, idx_sub));
set(gca, 'XTickLabel', comp_labels);
ylabel('C_{D,0} Contribution');
title('Zero-Lift Drag Breakdown: Subsonic (M=0.9)'); grid on;

% PLOT 5: Supersonic CD0 Breakdown (M=1.6)
figure('Name', 'Supersonic Breakdown');
bar(CD0_breakdown(:, idx_sup));
set(gca, 'XTickLabel', comp_labels);
ylabel('C_{D,0} Contribution');
title('Zero-Lift Drag Breakdown: Supersonic (M=1.6)'); grid on;

% PLOT 6: Lift Curve (CL vs Alpha)
figure('Name', 'Lift Curve');
plot(AoA_deg, CL_linear, '--b', 'LineWidth', 1.5); hold on;
plot(AoA_deg, CL_total, 'b', 'LineWidth', 2);
title('Lift Curve: Linear vs. Total (Vortex Lift Effect)');
xlabel('Angle of Attack \alpha (deg)'); ylabel('C_L');
legend('Linear Lift', 'Total Lift (Incl. Vortex)', 'Location', 'best'); grid on;

% PLOT 7: Drag Polar (CD vs CL)
figure('Name', 'Drag Polar');
plot(CD_polar, CL_total, 'k', 'LineWidth', 2);
title(['Drag Polar at M = ', num2str(Machs(cruise_idx))]);
xlabel('Total Drag Coefficient C_D'); ylabel('Lift Coefficient C_L');
grid on;

% Additional graphs

% Find index for M=0.9 (Cruise)
[~, cruise_idx] = min(abs(Machs - 0.9));

% New CD0 breakdown calculation using Class-based results
% CD0_breakdown rows are [Wing, H-Tail, V-Tail]
CD0_components = CD0_breakdown(:, cruise_idx); 

% Labels updated for your actual components
labels = {'Wing', 'H Tail', 'V Tail'};
figure;
bar(CD0_components)
set(gca,'XTickLabel',labels)
ylabel('C_{D0} Contribution')
title('Zero-Lift Drag Breakdown by Component (M=0.9)')
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

% --- Mapping Class Results to Assignment 5 Tasks ---

% Find indices for specific Mach numbers
[~, idx_16]  = min(abs(Machs - 1.6));
[~, idx_085] = min(abs(Machs - 0.85));
[~, idx_07]  = min(abs(Machs - 0.7));
[~, idx_08]  = min(abs(Machs - 0.8));
[~, idx_09]  = min(abs(Machs - 0.9));

% Task B-1: Supersonic Dash (M1.6)
p_supersonic = FlightPhase(h_cruise_sup * u.ft, b_combatturn, "Low-bypass turbofan, wet thrust", mach_number=1.6);
twr_supersonic = p_supersonic.twr(wing_loading_range, C_D0_total(idx_16), Ks(idx_16));

% Task B-2: Strike Dash (M0.85 @ SL)
% Note: Using CD0 from loop (which was at altitude). 
% For better accuracy, you could re-run calc_cd0(0, 0.85) here.
p_strike = FlightPhase(0, b_combatturn, "Low-bypass turbofan, dry thrust", mach_number=0.85);
twr_strike = p_strike.twr(wing_loading_range, C_D0_total(idx_085), Ks(idx_085));

% Task B-3: Sustained Turn (M0.7, 0.8, 0.9)
turn_indices = [idx_07, idx_08, idx_09];
turn_machs = [0.7, 0.8, 0.9];

for i = 1:length(turn_machs)
    p_turn(i,:) = FlightPhase(20000 * u.ft, b_combatturn, "Low-bypass turbofan, wet thrust", mach_number=turn_machs(i));
    % Pull dynamic CD0 and K from your loop results
    twr_turn(i,:) = p_turn(i).twr(wing_loading_range, C_D0_total(turn_indices(i)), Ks(turn_indices(i)));
end

% Task B-4: SEROC (Subsonic K)
p_seroc = FlightPhase(0, b_landing, "Low-bypass turbofan, wet thrust", velocity=v_approach, dh_dt=500*u.ft/u.min);
twr_seroc = p_seroc.twr(wing_loading_range, C_D0_total(idx_sub), Ks(idx_sub));
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

%% --- REFINED ASSIGNMENT 5: CONSTRAINT ANALYSIS ---

% 1. Calculate Engine Lapse for Key Phases
%alpha_supersonic = calc_lapse_rate(h_cruise_sup, 1.6, 1.04, 2);
%alpha_strike     = calc_lapse_rate(0, 0.85, 1.04, 2); % SL Strike
alpha_sl_static  = 1.0; % Sea level static for takeoff

% 2. Calculate Available T/W (The "Installed" Limit)
% This is the maximum T/W the engine can provide at that specific altitude/speed
T_SL_max = 43000 * 2 * 0.97; % Total Max Wet Thrust at SL (lbs) converted to N usually
T_avail_sup = (T_SL_max * .84) / aircraft.weight;
T_avail_sub = (T_SL_max * 1.28) / aircraft.weight;

% 3. Update the Plotting logic for Figure 8
figure; hold on;

% Plot the required T/W for each phase (from previous steps)
plot(wing_loading_range, twr_supersonic, 'b', 'LineWidth', 2);
plot(wing_loading_range, twr_strike, 'g', 'LineWidth', 2);
plot(wing_loading_range, twr_turn(1,:), Linewidth = 2)
plot(wing_loading_range, twr_turn(2,:), Linewidth = 2)
plot(wing_loading_range, twr_turn(3,:), Linewidth = 2)
plot(wing_loading_range, twr_seroc, Linewidth = 2)
xline(max_loading_takeoff, "m", Linewidth = 2);
xline(max_loading_approach, Linewidth = 2)

% Add the "AVAILABLE" Thrust lines (The limits)
yline(T_avail_sup, '--b', 'Supersonic Engine Limit', 'LineWidth', 1.5);
yline(T_avail_sub, '--g', 'Subsonic Engine Limit', 'LineWidth', 1.5);

% Plot your chosen design point (The intersection)
% e.g., if you chose W/S = 4000 Pa and T/W = 0.8
plot(ul(90*u.lbm/(u.ft)^2), Thrust_Weight, 'pk', 'MarkerSize', 15, 'MarkerFaceColor', 'y');

title('Team 5 Refined Constraint Diagram');
legend('Supersonic Reqd', 'Subsonic Reqd', 'Turn 1', "Turn 2", "Turn 3", ...
    'SEROC',"Takeoff", "Landing", 'Max Supersonic Avail', 'Max Subsonic Avail', 'Chosen Design Point');
%yline(installedthrust/W0, 'c', Linewidth = 2)
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