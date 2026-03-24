% AAE 451 Spring 2026
% Assignment 6
% Team 5
% VERSION 1.2

close all;
clear all;

% Variables
% This section has all variables used in other Assignment Codes. Variables
% are used in assignment codes that influence this code.

g = 9.81;         % m/s^2 
ft_NM = 6076.12;  % 1 Nautical Mile = 6076 feet
ft_Mi = 5280;     % 1 Mile = 5280 feet
u = symunit;      % Initialise symbolic units object

%% Aircraft Dependent Variables

% Assignment 3
Cruise_SFC = ul(0.88*u.lbm/(u.lbf*u.hr));      % lbm/lbf/hr → 1/s via ul(), then *g for correct Breguet units
Cruise_SFC = Cruise_SFC * g;
Combat_SFC = ul(1.9*u.lbm/(u.lbf*u.hr));
Combat_SFC = Combat_SFC * g;
Loiter_SFC = ul(0.7*u.lbm/(u.lbf*u.hr));
Loiter_SFC = Loiter_SFC * g;

% W_payload: fixed useful load excluding engines (captured in We_W0)
% Includes: avionics (2500 lb) + missiles (2512 lb) + crew (215 lb)

%W_payload = 2500 + 2512 + 215;                  % lb — kept imperial for Raymer sizing loop
W_payload = 7031;
Kvs = 1;                                        % 1 for fixed wing sweep
V_Cruise = ul(516 * ft_NM*u.ft/u.hr);           % m/s — Mach 0.9 at cruise altitude
V_Sup    = ul(918 * ft_NM*u.ft/u.hr);           % m/s — Mach 1.6 supersonic

Wing_loading  = 60;                              % lb/ft² (≈ 2750 Pa), Chosen Design Parameter
Thrust_Weight = 1.1;                             % Chosen Design Parameter

% Assignment 4
h_cruise_sup        = ul(30000*u.ft);            % m, cruise altitude
h_Seroc_Strike_dash = ul(100*u.ft);              % m, SL strike dash altitude
M = 0.9;                                         % Assumed cruise Mach

% Chosen Design Parameters
AR_w = 2.865;                                    % Wing aspect ratio
AR_ht = 1.989699;                                % H-tail aspect ratio
AR_vt = AR_ht;                                   % V-tail aspect ratio
%dia_fuselage = ul(2.165*u.m);                    % Fuselage diameter (m)
%len_fuselage = ul(18.379*u.m);                   % Fuselage length (m)
b    = ul(17.2*u.m);                           % Wingspan (m)
S_ref = ul(111.8*u.m^2);                       % Reference area (m²)

% Wing Geometry
t_c_w  = 0.15;                                   % Thickness/chord ratio
MCS_w  = ul(0.663225116*u.rad);                     % Mid-chord sweep (rad)
QCS_w  = ul(0.663225116*u.rad);                     % Quarter-chord sweep (rad)
LES_w  = ul(0.663225116*u.rad);                     % Leading-edge sweep (rad)
c_r    = ul(12*u.m);                             % Root chord (m)
c_t    = ul(1*u.m);                              % Tip chord (m)

% FIX 1: S_ref already in m² after ul() — do not re-apply unit conversions
S   = S_ref;                                     % Wing reference area (m²)
S_w = S_ref;                                     % Wing area (m²)

% FIX 1 (cont): c_r and c_t already in metres — do not re-apply u.m
ch_w = (c_r + c_t) / 2;                          % Mean chord (m)

% Horizontal Tail Geometry
t_c_ht = 0.06;
MCS_ht = ul(0*u.deg);
QCS_ht = ul(0*u.deg);
LES_ht = ul(0*u.deg);
ch_ht  = ul(0.762*u.m);
ct_ht  = ul(2.5*u.m);
cr_ht  = ul(2.5*u.m);
S_ht   = ul(12.37437*u.m^2);
b_ht   = ul(4.94*u.m);

% Vertical Tail Geometry
t_c_vt = 0.06;
MCS_vt = ul(0*u.deg);
QCS_vt = ul(0*u.deg);
LES_vt = ul(0*u.deg);
ch_vt  = ul(0.762*u.m);
S_vt   = ul(12.37437*u.m^2);
b_vt   = ul(4.9497*u.m);
ct_vt  = ul(2.5*u.m);
cr_vt  = ul(2.5*u.m);

C_L_max = 1.5;                                   % From chosen airfoil

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% L/D VALUES: Based on historical data. Required assumption to avoid
% circular dependency between Assignments 3 and 4.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Cruise_L_D = 9;
Combat_L_D = 3.4;
Loiter_L_D = 9;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% DO NOT CHANGE BELOW THIS LINE EXCEPT FOR EDITS LOG %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Aircraft Independent Variables

% Assignment 3
b_takeoff    = 1;      % Given in Assignment 3 Description
b_combatturn = 0.78;   % Given in Assignment 3 Description
b_landing    = 0.6;    % Given in Assignment 3 Description

W1_W0 = 0.970;         % Warmup/taxi
W2_W1 = 0.985;         % Takeoff
W7_W6 = 0.995;         % Landing/recovery

Cruise_Out  = ul(700*u.nmile);    % m
Combat_Time = ul(2*u.min);        % s
Combat_Speed = 1.6;               % Mach
Cruise_Back  = ul(700*u.nmile);   % m
Loiter_Time  = ul(20*u.min);      % s

% Raymer Sizing Constraints (all-imperial correlation)
A  = -0.02;
B  =  2.16;
C1 = -0.1;
C2 =  0.2;
C3 =  0.04;
C4 = -0.10;
C5 =  0.08;

% Assignment 4
K_A       = 0.95;    % From drag polar notes
C_DW_peak = 0.058;   % Peak wave drag coefficient
M_DW_peak = 1.25;    % Mach at peak wave drag
Qf   = 1;            % Raymer ch 12 interference factors
Qn   = 1.3;
Qw   = 1;
Qvt  = 1.03;
Qht  = 1.08;
K_approach = 1.15;   % Mattingly p.34
K_takeoff  = 1.1;    % Mattingly p.34 / slide 19


%% Calculations (Integration of Assignments 3, 4, 5)
%% Assignment 3 — Fuel Fraction Method

% Initial Cruise (Breguet range)
W3_W2 = exp(-Cruise_Out  * Cruise_SFC / (V_Cruise * Cruise_L_D));

% Combat (Breguet endurance)
W4_W3 = exp(-Combat_Time * Combat_SFC / Combat_L_D);

% Final Cruise
W5_W4 = exp(-Cruise_Back * Cruise_SFC / (V_Cruise * Cruise_L_D));

% Loiter
W6_W5 = exp(-Loiter_Time * Loiter_SFC / Loiter_L_D);

% Overall fuel fraction (k = trapped + reserve fuel coefficient)
k = 0.05 + 0.01;
Wf_W0 = (1 + k) * (1 - W7_W6 * W6_W5 * W5_W4 * W4_W3 * W3_W2 * W2_W1 * W1_W0);

% FIX 4: Sizing loop kept entirely in imperial (lb, lb/ft²) to match
% Raymer correlation. W0 converted to kg only after convergence.
max_iter = 500;   % FIX 4: convergence guard

for Carrier_Penalty = [0.031]
    W0  = 50000;   % lb, initial guess
    W0i = 0;
    iter = 0;
    while abs(W0 - W0i) > 0.1
        W0i  = W0;
        iter = iter + 1;
        if iter > max_iter
            warning('W0 sizing loop did not converge after %d iterations. Last W0 = %.2f lb', max_iter, W0);
            break
        end
        % Raymer empty weight fraction — W0 in lb, Wing_loading in lb/ft²
        We_W0 = (A + B*(W0^C1)*(AR_w^C2)*(Thrust_Weight^C3) * ...
                 (Wing_loading^C4)*(Combat_Speed^C5)*Kvs) + Carrier_Penalty;
        W0 = W_payload / (1 - Wf_W0 - We_W0);
    end
end

% Display results in imperial (loop units)
disp(" ")
disp("------------------------------")
disp("Calculated Max Takeoff Weight (lb):")
disp(W0)
disp("Calculated Empty Weight (lb):")
disp(We_W0 * W0)
disp("Calculated Fuel Weight (lb):")
disp(Wf_W0 * W0)
disp("------------------------------")
disp(" ")

%% --- We_W0 RECONCILIATION (Statistical + Component Buildup Average) ---
% The Raymer statistical equation (B-term) overestimates We_W0 for this
% flying wing configuration — regression was built on conventional fighters
% and is invalid at W/S = 57.5 lb/ft² with a blended wing body.
%
% Statistical result:  We_W0_stat    = 0.6327  → W0 = ~78,000 lb (too high)
% Component buildup:   We_W0_buildup = 0.5425  → W0 = ~32,000 lb
% Averaged:            We_W0_avg     = 0.5876
%
% W0 is re-converged below using We_W0_avg as a fixed empty weight fraction.

We_W0_stat    = We_W0;       % save statistical value for reference
We_W0_buildup = 0.5425;      % from Ch.15 component buildup (closed to 1.72 lb)
We_W0_avg     = (We_W0_stat + We_W0_buildup) / 2;

fprintf('\n--- We_W0 Reconciliation ---\n');
fprintf('Statistical We_W0 : %.4f\n', We_W0_stat);
fprintf('Buildup     We_W0 : %.4f\n', We_W0_buildup);
fprintf('Averaged    We_W0 : %.4f\n', We_W0_avg);

% Re-converge W0 with averaged We_W0 (fixed — no longer iterated)
W0  = 50000;   % lb, reset initial guess
W0i = 0;
iter = 0;
while abs(W0 - W0i) > 0.1
    W0i  = W0;
    iter = iter + 1;
    if iter > max_iter
        warning('Reconciled W0 loop did not converge after %d iterations.', max_iter);
        break
    end
    W0 = W_payload / (1 - Wf_W0 - We_W0_avg);  % We_W0_avg is fixed, not re-computed
end
We_W0 = We_W0_avg;   % update We_W0 for all downstream use

fprintf('Reconciled W0 (lb): %.2f\n', W0);

% Convert to SI for all downstream calculations
W0_kg = W0 * 0.453592;   % kg
fprintf('Reconciled W0 (kg): %.2f\n', W0_kg);

fprintf('--- We_W0 Sensitivity ---\n');
fprintf('Wing_loading^C4  = %.4f  (%.2f^%.2f)\n', Wing_loading^C4, Wing_loading, C4);
fprintf('W0^C1            = %.4f  (%.2f^%.2f)\n', W0^C1, W0, C1);
fprintf('AR_w^C2          = %.4f  (%.2f^%.2f)\n', AR_w^C2, AR_w, C2);
fprintf('TW^C3            = %.4f  (%.2f^%.2f)\n', Thrust_Weight^C3, Thrust_Weight, C3);
fprintf('Mach^C5          = %.4f  (%.2f^%.2f)\n', Combat_Speed^C5, Combat_Speed, C5);
fprintf('B term product   = %.4f\n', B*(W0^C1)*(AR_w^C2)*(Thrust_Weight^C3)*(Wing_loading^C4)*(Combat_Speed^C5)*Kvs);
fprintf('We_W0            = %.4f\n', We_W0);
fprintf('1 - Wf - We      = %.4f\n', 1 - Wf_W0 - We_W0);
fprintf('W_payload / denom= %.2f lb\n', W_payload / (1 - Wf_W0 - We_W0));

%% Assignment 4

% FIX 1: aircraft.weight in Newtons — W0_kg is in kg, multiply by g
aircraft.weight = W0_kg * g;                     % N

% Defining component objects
aircraft_wing = Wing(b, AR_w, t_c_w, c_r, c_t, 1.0);
aircraft_wing.QC_sweep = QCS_w;
aircraft_wing.LE_sweep = LES_w;

tail_h_obj = Wing(b_ht, AR_ht, t_c_ht, cr_ht, ct_ht, 1.08);
tail_h_obj.QC_sweep = deg2rad(QCS_ht);
tail_h_obj.LE_sweep = deg2rad(LES_ht);

tail_v_obj = Wing(b_vt, AR_vt, t_c_vt, cr_vt, ct_vt, 1.03);
tail_v_obj.QC_sweep = deg2rad(QCS_vt);
tail_v_obj.LE_sweep = deg2rad(LES_vt);

comp_list = {aircraft_wing, tail_h_obj, tail_v_obj};
e_oswald  = aircraft_wing.oswald_eff;
SWP       = aircraft_wing.QC_sweep;

S_ref_main_m2 = aircraft_wing.reference_area;

%% Drag Buildup

V_cruise = V_Cruise;   % alias used below

C_L_des = aircraft.weight / (0.5 * Atm.density(30000) * V_cruise^2 * S_ref_main_m2);
M_DD    = K_A/cos(SWP) - aircraft_wing.thickness_chord_ratio/(cos(SWP)^2) - C_L_des/(10*(cos(SWP)^3));
M_crit  = M_DD - 0.08;

%% --- 3. DYNAMIC DRAG BUILDUP LOOP ---
Machs         = linspace(0.1, 2.5, 300);
C_D0_total    = zeros(size(Machs));
C_D_wakes     = zeros(size(Machs));
Ks            = zeros(size(Machs));
CD0_breakdown = zeros(length(comp_list), length(Machs));

h_analysis = h_cruise_sup;

for i = 1:length(Machs)
    M    = Machs(i);
    beta = sqrt(max(M^2 - 1, 0.01));

    % Step A: Parasitic Drag
    current_CD0_sum = 0;
    for k = 1:length(comp_list)
        comp          = comp_list{k};
        comp_local_cd0 = comp.calc_cd0(h_analysis, M);
        scaled_cd0    = comp_local_cd0 * comp.reference_area / S_ref_main_m2;
        CD0_breakdown(k, i) = scaled_cd0;
        current_CD0_sum = current_CD0_sum + scaled_cd0;
    end
    C_D0_total(i) = 1.1 * current_CD0_sum;   % 10% misc drag

    % Step B: Induced & Wave Drag
    K_sub = 1 / (pi * aircraft_wing.aspect_ratio * e_oswald);

    if M >= M_crit
        if M >= M_DW_peak
            C_D_wake_theoretical = C_DW_peak * (M_DW_peak / M);
            C_D_wakes(i) = max(C_D_wake_theoretical, 0.3 * C_DW_peak);
            K_supersonic = beta / 4;
            Ks(i) = max(K_sub, K_supersonic);
        else
            scal         = C_DW_peak / (M_DW_peak - M_crit)^3;
            C_D_wakes(i) = scal * (M - M_crit)^3;
            x            = (M - M_crit) / (M_DW_peak - M_crit);
            w            = x^2 * (3 - 2*x);
            Mpeak_m1     = max(M_DW_peak^2 - 1, 0.001);
            K_sup_limit  = aircraft_wing.aspect_ratio * Mpeak_m1 * ...
                           cos(aircraft_wing.LE_sweep) / ...
                           (4 * aircraft_wing.aspect_ratio * sqrt(Mpeak_m1) - 2);
            Ks(i) = (1-w)*K_sub + w*K_sup_limit;
        end
    else
        C_D_wakes(i) = 0;
        Ks(i)        = K_sub;
    end
end

%% --- 4. LIFT & DRAG POLAR CALCULATIONS ---
AoA_deg = linspace(0, 25, 300);
AoA_rad = deg2rad(AoA_deg);

% Polhamus Suction Analogy
Kp = (2*pi*AR_w) / (2 + sqrt(AR_w^2 * (1 + tan(MCS_w)^2) + 4));
Kv = pi * AR_w / (2 * cos(LES_w));

CL_linear = Kp * sin(AoA_rad) .* cos(AoA_rad).^2;
CL_vortex = Kv * sin(AoA_rad).^2 .* cos(AoA_rad);
CL_total  = CL_linear + CL_vortex;

K_sub    = 1 / (pi * AR_w * e_oswald);
K_vortex = 1 / Kp;

[~, cruise_idx] = min(abs(Machs - 0.9));
CD0_cruise      = C_D0_total(cruise_idx) + C_D_wakes(cruise_idx);

CD_vortex_effect = CL_total .* tan(AoA_rad);
CD_polar         = CD0_cruise + CD_vortex_effect;
LD_ratio         = CL_total ./ CD_polar;

%% --- 5. PLOTTING SUITE ---
[~, idx_sub] = min(abs(Machs - 0.9));
[~, idx_sup] = min(abs(Machs - 1.6));
comp_labels  = {'Wing', 'H-Tail', 'V-Tail'};

% Plot 1: Total Zero-Lift Drag Rise
figure('Name', 'CD_{ZL} vs Mach');
plot(Machs, C_D0_total + C_D_wakes, 'LineWidth', 2);
title('Total Zero-Lift Drag Rise (C_{D0} + C_{D wake})');
xlabel('Mach Number'); ylabel('C_{DZL}'); grid on;
xlim([0, 2.1])

% Plot 2: L/D vs Mach
C_D_ZL_total = C_D0_total + C_D_wakes;
figure('Name', 'LD_Max vs Mach');
plot(Machs, LD_ratio, 'r', 'LineWidth', 2);
xline(1.0, '--k', 'Mach 1.0');
title('Lift-to-Drag Ratio vs Mach');
xlabel('Mach Number'); ylabel('(L/D)_{max}'); grid on;

% Plot 6: Lift Curve
figure('Name', 'Lift Curve');
plot(AoA_deg, CL_linear, '--b', 'LineWidth', 1.5); hold on;
plot(AoA_deg, CL_total,  'b',   'LineWidth', 2);
title('Lift Curve: Linear vs. Total (Vortex Lift Effect)');
xlabel('Angle of Attack \alpha (deg)'); ylabel('C_L');
legend('Linear Lift', 'Total Lift (Incl. Vortex)', 'Location', 'best'); grid on;

% Plot 7: Drag Polar and L/D vs Alpha
figure('Name', 'Sunfish Aerodynamic Efficiency');
subplot(2,1,1)
plot(CD_polar, CL_total, 'k', 'LineWidth', 2);
title(['Drag Polar at M = ', num2str(Machs(cruise_idx))]);
xlabel('C_D'); ylabel('C_L'); grid on;

subplot(2,1,2)
plot(AoA_deg, LD_ratio, 'r', 'LineWidth', 2);
title('L/D Ratio vs Angle of Attack');
xlabel('\alpha (deg)'); ylabel('L/D'); grid on;

[~, cruise_idx]  = min(abs(Machs - 0.9));
CD0_components   = CD0_breakdown(:, cruise_idx);

%% Assignment 5

wing_loading_range = ul(unitConvert([0 140] * u.lbf / (u.ft^2), u.N / (u.m^2)));
fprintf("Wing loading range: %d - %d Pa\n", wing_loading_range);
wing_loading_range = linspace(wing_loading_range(1), wing_loading_range(2), 511);

% Requirements
v_approach = 140 * u.kts;
v_takeoff  = 120 * u.kts;
min_accel  = 0.3 * g;

% Carrier Limits
p_approach        = FlightPhase(0, b_landing, "Low-bypass turbofan, dry thrust", velocity=v_approach);
max_loading_approach = p_approach.wing_loading(C_L_max, K_approach);

p_takeoff         = FlightPhase(0, b_takeoff, "Low-bypass turbofan, wet thrust", velocity=v_takeoff, dv_dt=min_accel);
max_loading_takeoff = p_takeoff.wing_loading(C_L_max, K_takeoff);

% Mach indices
[~, idx_16]  = min(abs(Machs - 1.6));
[~, idx_085] = min(abs(Machs - 0.85));
[~, idx_07]  = min(abs(Machs - 0.7));
[~, idx_08]  = min(abs(Machs - 0.8));
[~, idx_09]  = min(abs(Machs - 0.9));

% Task B-1: Supersonic Dash (M1.6)
% FIX 7: h_cruise_sup already in metres after ul() — do not re-apply u.ft
p_supersonic   = FlightPhase(h_cruise_sup, b_combatturn, "Low-bypass turbofan, wet thrust", mach_number=1.6);
twr_supersonic = p_supersonic.twr(wing_loading_range, C_D0_total(idx_16), Ks(idx_16));

% Task B-2: Strike Dash (M0.85 @ SL)
p_strike   = FlightPhase(0, b_combatturn, "Low-bypass turbofan, dry thrust", mach_number=0.85);
twr_strike = p_strike.twr(wing_loading_range, C_D0_total(idx_085), Ks(idx_085));

% FIX 2: Single authoritative sustained turn block (Mattingly validated values)
% Task B-3: Sustained Turn, 8 deg/s @ 20k ft, M0.7/0.8/0.9, wet thrust
% turn_speeds = [0.7,    0.8,    0.9   ];
% C_D0_turn   = [0.0193, 0.0193, 0.0195];
% K_turn      = [0.0894, 0.0894, 0.0955];
% for i = 1:length(turn_speeds)
%     p_turn(i,:)   = FlightPhase(20000*u.ft, b_combatturn, "Low-bypass turbofan, wet thrust", mach_number=turn_speeds(i));
%     twr_turn(i,:) = p_turn(i).twr(wing_loading_range, C_D0_turn(i), K_turn(i));
% end

turn_speeds = [0.7,  0.8,  0.9 ];

for i = 1:length(turn_speeds)
    [~, idx_turn] = min(abs(Machs - turn_speeds(i)));
    p_turn(i,:)   = FlightPhase(20000*u.ft, b_combatturn, "Low-bypass turbofan, wet thrust", mach_number=turn_speeds(i));
    twr_turn(i,:) = p_turn(i).twr(wing_loading_range, C_D0_total(idx_turn), Ks(idx_turn));
end

% Task B-4: SEROC, 500 ft/min single-engine, approach config, wet thrust
% FIX 2: Single authoritative SEROC block
p_seroc   = FlightPhase(0, b_landing, "Low-bypass turbofan, wet thrust", velocity=v_approach, dh_dt=500*u.ft/u.min);
twr_seroc = p_seroc.twr(wing_loading_range, 0.0195, K_sub);

%% --- REFINED CONSTRAINT DIAGRAM ---

alpha_sl_static = 1.0;
T_SL_max    = 43000 * 2 * 0.97;
T_avail_sup = (T_SL_max * 0.84) / aircraft.weight;
T_avail_sub = (T_SL_max * 1.0)  / aircraft.weight;

figure; hold on;

wing_loading_range   = wing_loading_range   * 0.020885;
max_loading_approach = max_loading_approach * 0.020885;
max_loading_takeoff  = max_loading_takeoff  * 0.020885;

% ── Define x-axis limits ──────────────────────────────────────────────────
x_min = 0;
x_max = 90;
y_min = 0;
y_max = 1.5;

% ── Build the lower bound of the feasible region ──────────────────────────
% The feasible region is ABOVE all curved constraints AND left of the
% two vertical lines.  We only shade up to the leftmost vertical line.
x_fence = min(max_loading_takeoff, max_loading_approach);

% Crop wing_loading_range to [x_min, x_fence]
x_shade = wing_loading_range(wing_loading_range <= x_fence);
if isempty(x_shade) || x_shade(end) < x_fence
    x_shade(end+1) = x_fence;          % make sure the boundary is included
end

% Interpolate every constraint curve at the shading x-values
interp_sup  = interp1(wing_loading_range, twr_supersonic, x_shade, 'linear', 'extrap');
interp_sub  = interp1(wing_loading_range, twr_strike,     x_shade, 'linear', 'extrap');
interp_t1   = interp1(wing_loading_range, twr_turn(1,:),  x_shade, 'linear', 'extrap');
interp_t2   = interp1(wing_loading_range, twr_turn(2,:),  x_shade, 'linear', 'extrap');
interp_t3   = interp1(wing_loading_range, twr_turn(3,:),  x_shade, 'linear', 'extrap');
interp_ser  = interp1(wing_loading_range, twr_seroc,      x_shade, 'linear', 'extrap');

% Element-wise maximum → the tightest (highest) lower bound at each x
lower_bound = max([interp_sup; interp_sub; interp_t1; interp_t2; interp_t3; interp_ser], [], 1);

% Clamp to plot limits
lower_bound = max(lower_bound, y_min);
lower_bound = min(lower_bound, y_max);

% Upper bound of the shaded patch = y_max everywhere
upper_bound = y_max * ones(size(x_shade));

% ── Draw the shaded patch BEFORE the curves so it sits behind them ────────
patch_x = [x_shade, fliplr(x_shade)];
patch_y = [upper_bound, fliplr(lower_bound)];
fill(patch_x, patch_y, [0.6 1.0 0.6], ...   % light green
    'FaceAlpha', 0.25, ...
    'EdgeColor', 'none', ...
    'DisplayName', 'Feasible Region');

% ── Plot constraint curves ────────────────────────────────────────────────
plot(wing_loading_range, twr_supersonic, 'b',  'LineWidth', 2);
plot(wing_loading_range, twr_strike,     'g',  'LineWidth', 2);
plot(wing_loading_range, twr_turn(1,:),        'LineWidth', 2);
plot(wing_loading_range, twr_turn(2,:),        'LineWidth', 2);
plot(wing_loading_range, twr_turn(3,:),        'LineWidth', 2);
plot(wing_loading_range, twr_seroc,            'LineWidth', 2);
xline(max_loading_takeoff,  'm', 'LineWidth', 2);
xline(max_loading_approach,      'LineWidth', 2);

ylim([y_min, y_max]);
xlim([x_min, x_max]);

plot(60, 1.1, 'pk', 'MarkerSize', 15, 'MarkerFaceColor', 'y');
plot(3750 * 0.020885, 1.3, 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3);

title('Team 5 Constraint Diagram');
legend('Feasible Region', 'Supersonic Reqd', 'Subsonic Reqd', 'Turn 1', 'Turn 2', 'Turn 3', ...
    'SEROC', 'Takeoff', 'Landing', 'Chosen Design Point', 'Original Design Point', ...
    'Location', 'best');
xlabel('Wing Loading (lb/ft^2)');
ylabel('Thrust to Weight Ratio (T/W)');
grid on; hold off;

%% --- QUANTITATIVE TRADE: RADIUS VS PAYLOAD WEIGHT ---
% FIX 3: Trade study uses local named payload variables to avoid
% overwriting the global W_payload design variable.

sweep_lb   = linspace(0, 10000, 100);
R_line_ext = zeros(size(sweep_lb));
R_line_int = zeros(size(sweep_lb));

% Parasite drag model
CD0_clean            = CD0_cruise;
CD0_external_penalty = 0.0132;

% FIX 3 (bay penalty): Reduced from 0.05 to 0.02 (5% MTOW was too aggressive;
% 2% is more representative of a structural weapons bay weight penalty)
bay_penalty = 0.05;

W_fuel = Wf_W0 * W0_kg;

for k = 1:length(sweep_lb)
    W_ord_kg = sweep_lb(k) * 0.453592;

    % External
    CD0_ext      = CD0_clean + CD0_external_penalty;
    LD_ext       = 0.5 * sqrt(pi * AR_w * e_oswald / CD0_ext);
    Wf_W0_ext    = max(0, (W_fuel - W_ord_kg) / W0_kg);
    R_line_ext(k)= max(0, (V_Cruise * LD_ext / Cruise_SFC) * log(1 / (1 - Wf_W0_ext)));

    % Internal
    W_bay_kg     = 0.02 * W0_kg;
    LD_int       = 0.5 * sqrt(pi * AR_w * e_oswald / CD0_clean);
    Wf_W0_int    = max(0, (W_fuel - W_ord_kg - W_bay_kg) / W0_kg);
    R_line_int(k)= max(0, (V_Cruise * LD_int / Cruise_SFC) * log(1 / (1 - Wf_W0_int)));
end

% Plot trade
figure('Name', 'Radius vs Payload Weight Trade');
plot(sweep_lb, R_line_ext/1852, 'r--', 'LineWidth', 2); hold on;
plot(sweep_lb, R_line_int/1852, 'b-',  'LineWidth', 2);

% RFP payload markers
W_payload_A2A    = 5227;
W_payload_Strike = 7031;

idx_A2A    = find(sweep_lb >= W_payload_A2A,    1);
idx_Strike = find(sweep_lb >= W_payload_Strike, 1);

xline(sweep_lb(idx_A2A),    'k', 'LineWidth', 2);
text(sweep_lb(idx_A2A)    -1500, R_line_ext(idx_A2A)/1852+1200, 'RFP Air-to-Air');
xline(sweep_lb(idx_Strike), 'k', 'LineWidth', 2);
text(sweep_lb(idx_Strike)  + 200, R_line_ext(idx_Strike)/1852+1200, 'RFP Strike');

grid on;
xlabel('Ordnance Payload Weight (lb)');
ylabel('Combat Radius (nmi)');
title('Quantitative Trade: Internal vs External Ordnance Carriage');
legend('External', 'Internal', 'Location', 'northeast');

fprintf('\n--- RFP Mission Performance Analysis ---\n');
fprintf('Air-to-Air (5227 lb): Ext = %.1f nmi, Int = %.1f nmi\n', ...
        R_line_ext(idx_A2A)   /1852, R_line_int(idx_A2A)   /1852);
fprintf('Strike (7031 lb):   Ext = %.1f nmi, Int = %.1f nmi\n', ...
        R_line_ext(idx_Strike)/1852, R_line_int(idx_Strike)/1852);

figure;
plot(Machs, C_D_wakes);
xlabel('\alpha (deg)'); ylabel('C_D'); title('C_D vs Angle of Attack'); grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change Log:
% 2/8/2026:  v1.0 — Original creation
% 2/16/2026: v1.1 — Reworked code, began working in chosen design parameters
% 2/23/2026: v1.2 — Checked variables, noted assumptions, formatted
% 3/8/2026:  v1.3 — Bug fixes (see below)
%   FIX 1: Corrected unit errors on S, S_w (re-applying ft² to SI values)
%          and ch_w (re-applying u.m to already-metric values)
%   FIX 2: Removed duplicate sustained turn and SEROC constraint blocks
%   FIX 3: Renamed trade study payload vars to W_payload_A2A / W_payload_Strike
%          to prevent overwriting global W_payload; reduced bay_penalty 0.05→0.02
%   FIX 4: Sizing loop kept fully imperial (lb, lb/ft²) to match Raymer
%          correlation; W0 converted to kg after convergence as W0_kg;
%          max_iter = 500 convergence guard added; display labels corrected to lb
%   FIX 5: aircraft.weight corrected to W0_kg * g (Newtons) — was incorrectly
%          treating kg as lbf via unitConvert
%   FIX 6: Breguet payload sweep uses W_ord_kg vs W0_kg (consistent SI)
%   FIX 7: h_cruise_sup passed to FlightPhase without re-applying u.ft
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('Name', 'CD0 Breakdown vs Mach');
plot(Machs, C_D_wakes,  'r', 'LineWidth', 2); hold on;
plot(Machs, C_D0_total + C_D_wakes, 'k--', 'LineWidth', 2);
xline(1.0, '--k', 'Mach 1.0');
xline(M_crit, '--g', 'M_{crit}');
title('Drag Coefficient Breakdown vs Mach');
xlabel('Mach Number'); ylabel('C_D');
legend('Wave Drag (C_{D,wave})', ...
       'Total Zero-Lift (C_{D0} + C_{D,wave})', 'Location', 'best');
grid on; hold off;
