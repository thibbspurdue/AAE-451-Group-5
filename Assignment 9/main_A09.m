%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assignment 9
% AAE 45100 Aircraft design
% Team 05
% Code overview:
%
% Subfunctions required to compile:
% task1.m (to be renamed)
% task2.m (to be renamed)
% Drag_Complex.m
% Parameter_Import
% Parameters_rebalance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Tasks that must be done in order for this assignment to work

% Thrust function
% accepts input parameters as vectors
% velocity altitude 
% Need the weights generally

%% Unit stuff?
function output = ul(input)
    output = double(separateUnits(input));
end

%% Parameters derivation
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

%% Variables needed for calculation (please alter this section later on)
MTOW = ;
W_E = ;%empty weight
W_Fuel_Limit = ;%we dont know this yet, def in kg
W_payload = ul(10215* u.lbm); 
W_payload = unitConvert(W_payload, u.kg);
V_Cruise = ;%Need to find optimal cruising speed?

Cruise_L_D = 9.2;                  % Assignment 4
Combat_L_D = 4.5;                  % Assignment 4
Loiter_L_D = 11;                   % Assignment 4

%dummy values used for testing the range
% MTOW = 90000 * 0.45359237 * u.kg;
% W_E = 50000* 0.45359237 * u.kg;%empty weight
% W_Fuel_Limit = 35000* 0.45359237 * u.kg;%we dont know this yet, def in kg
% V_Cruise = 400 * u.m/u.s;
%% Code iteration from previous assignments
C_D0 = Drag_Complex(Q, l_f, d_f, l_N, d_N, QCS_w, QCS_ht, QCS_vt, t_c_w, t_c_ht, t_c_vt, c_bar, c_r, c_ht, c_vt, S_ref, S_w, S_t, S_v); 
e = 4.61 * (1 - 0.045*AR^0.68) * (cos(Swp_w)^0.15) - 3.1;

%% Task 1. Carrier Takeoff Performance
task1(W,S,C_L_max,C_D0,AR,e,g)

%% Task 2. Maneuvering Performance
task2(C_L_max,S,C_D0,AR,e,W)

%% Task 3 + 4. Flight Envelope and Specific Excess Power
%C_D0L is the 0 Lift Coefficent of Drag when th eplane is loaded
C_D0L = C_D0; %Assuming everything is stored inside the aircraft
Flight_envelope(AR, SWP_w, S, t_c_w, W, T_SL, C_D0, C_D0L);

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
SEROC = V * (T_max/2 - D);

%% Task 7. Climb Performance: Rate and Angle of Climb
a_climb = asin((T_max-D)/W);
ROC = V * sin(a_climb);

%% Task 8. Payload-Range Envelope
%Point definition [range, payload_weight]

%A is range 0, max payload
A = [0, W_payload];

%B is max payload, corresponding range
R = Range(W_payload, W_E, MTOW, V_Cruise, Cruise_L_D, Combat_L_D, Loiter_L_D);
R = unitConvert(R, u.nmi);
B = [R, W_payload];

%C is still MTOW, but hits the fuel limit
W_p = MTOW - W_E - W_Fuel_Limit;
R = Range(W_p, W_E, MTOW, V_Cruise, Cruise_L_D, Combat_L_D, Loiter_L_D);
R = unitConvert(R, u.nmi);
C = [R, W_p];

%D is at 0 payload with the fuel limit
R = Range(0, W_E, W_E + W_Fuel_Limit, V_Cruise, Cruise_L_D, Combat_L_D, Loiter_L_D);
R = unitConvert(R, u.nmi);
D = [R, 0];

%Plotting
x = [A(1) B(1) C(1) D(1) 0];
y = [A(2) B(2) C(2) D(2) 0];

x = ul(x);
y = ul(y);

x_max = round(1.25*x(4), 1, 'significant');
y_max = round(1.25*y(1), 1, 'significant');

fill(x, y, [0.2 0.6 0.9]);
xlabel('Range [nmi]');
ylabel('Payload weight [kg]');
xlim([0 x_max]); ylim([0 y_max]);
grid on;
title("Payload-Range Diagram")