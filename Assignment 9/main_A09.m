%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assignment 9
% AAE 45100 Aircraft design
% Team 05
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Tasks that must be done in order for this assignment

% Thrust function
% accepts input parameters as vectors
% velocity altitude 

%% Variables needed for calculation (please alter this section later on)

% Work on T - Min

%% Basic setup
% Remove after merging branch
u = symunit; % Initialise symbolic units object

% Remove after merging branch
function output = ul(input)
    output = double(separateUnits(input));
end

spreadsheet = 'Parameters_copy.xlsx';
aircraft = 'Grinch';
airfoil = 'Airfoil';

Parameter_Import(spreadsheet, aircraft, airfoil);
[l_t, l_h, l_v, S_h, S_t] = Parameters_rebalance(l_t, l_v, x_ac, S_t, S_v);
Q = [Qf Qw Qht Qvt Qn];
QCS_w = Swp_w;
QCS_ht = Swp_ht;
QCS_vt = Swp_vt;
S_ref = S;
C_D0 = Drag_Complex(Q, l_f, d_f, l_N, d_N, QCS_w, QCS_ht, QCS_vt, t_c_w, t_c_ht, t_c_vt, c_bar, c_r, c_ht, c_vt, S_ref, S_w, S_t, S_v);

%% Task 1. Carrier Takeoff Performance
task1

%% Task 2. Maneuvering Performance

[temp,v_sound,p,rho,nu,mu] = atmosisa(separateUnits(unitConvert(20000*u.ft),'SI')); 

v_sound = v_sound * u.m / u.s;
p = p * u.pa;
rho = rho * u.kg / (u.m^3);

mach = linspace(0,1.6,1000);
V = mach .* v_sound;
V_stall = sqrt(2*W/(rho*S*C_L_max));
L = 1/2 * rho .* V.^2 * S * C_L;
R = [300 500 1000 2000] .* u.m;

n =  L/W; %% LOAD FACTOR, DON'T OVERWRITE
n_lift = 1/2 * rho * V_stall.^2 * S * C_L_max / W;
n_sust = sqrt((T/q/S- C_D0) ./ K);
n_max = 7.5; % Apparently from the RFP %q*C_L_max/(W/S);

n(n>n_max) = n_max;

V_corner = sqrt(2*n_max*W/(rho*S*C_L_max));

w_radius = V ./ R;
w_load = g * sqrt(n.^2-1) ./ V;
w_corner = V_stall / R;
% Doghouse plotting


%% Task 3. Flight Envelope and Specific Excess Power - Tabitha

%% Task 4. Impact of External Stores

%% Task 5. Carrier Landing and Arrestment
app_coef = 1.1; % range from 1.1 ~ 1.15
V_app = app_coef * v_stall;
V_eng = 1.05 * v_app - v_wod;
V_eng_range = unitConvert(linspace(100,160).*u.knot, 'SI');
k_E_eng = 1/2*m*v_eng^2;
C2 = unitConvert(40000 * u.lbs * (145 * u.knot)^2, 'SI');
W_arrest_limit = C2 ./ (V_eng_range^2);

figure()
plot(V_eng_range, W_arrest_limit)
hold on
plot(V_eng, k_E_eng,'Marker','.')
%% Task 6. Single Engine Rate of Climb (SEROC)
D = 1/2 * rho .* V.^2 * S * C_D;
SEROC = V * (T/2 - D);

%% Task 7. Climb Performance: Rate and Angle of Climb
a_climb = asin((T-D)/W);
ROC = V * sin(a_climb);

%% Task 8. Payload-Range Envelope