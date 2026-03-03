%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assignment 9
% AAE 45100 Aircraft design
% Team 05
% Code overview:
%
% Subfunctions required to compile:
% TO_performance.m
% doghouse.m
% Drag_Complex.m
% Parameter_Import
% Parameters_rebalance
% Range.m
% K_find_matrix.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Tasks that must be done in order for this assignment to work

% Envelope function doesn't work for now; I think it's because the
% temperature is not defined in the main, and I don't know what unit it
% expects. 

%% Unit stuff?
u = symunit;
function output = ul(input)
    output = double(separateUnits(input));
end

%% Parameters derivation
spreadsheet = 'Parameters_copy.xlsx';
aircraft = 'Sunfish';
airfoil = 'Airfoil';

Parameter_Import(spreadsheet, aircraft, airfoil);
[l_t, l_h, l_v, S_h, S_t] = Parameters_rebalance(l_t, l_v, x_ac, S_t, S_v);
Q = [Qf Qw Qht Qvt Qn];
QCS_w = Swp_w;
QCS_ht = Swp_ht;
QCS_vt = Swp_vt;
S_ref = S;

%% Variables needed for calculation (please alter this section later on)
MTOW = 21410 * u.kg;
W_E = 10479 * u.kg;%empty weight
W_Fuel_Limit = 1.25*6298.5  * u.kg;%Assuming it is 25% more than intended may payload one
W_payload = 10215* u.lbm; 
W_payload = unitConvert(W_payload, u.kg);
V_Cruise = 400 * u.m/u.s;%Need to find optimal cruising speed?

T_wet = 43000 * u.lbf;
T_wet = unitConvert(T_wet, u.N); %wet thrust, one engine

T_dry = 28000 * u.lbf;
T_dry = unitConvert(T_dry, u.N); %wet thrust, one engine

Cruise_L_D = 9.2;                  % Assignment 4
Combat_L_D = 4.5;                  % Assignment 4
Loiter_L_D = 11;                   % Assignment 4

%dummy values used for testing the range
%MTOW = 90000 * 0.45359237 * u.kg;
%W_E = 50000* 0.45359237 * u.kg;%empty weight
%W_Fuel_Limit = 35000* 0.45359237 * u.kg;%we dont know this yet, def in kg
%% Code iteration from previous assignments
C_D0 = Drag_Complex(Q, l_f, d_f, l_N, d_N, QCS_w, QCS_ht, QCS_vt, t_c_w, t_c_ht, t_c_vt, c_bar, c_r, c_ht, c_vt, S_ref, S_w, S_t, S_v); 
e = 4.61 * (1 - 0.045*AR^0.68) * (cos(Swp_w)^0.15) - 3.1;
g = 9.81 * u.m / u.s^2;

%% Task 1. Carrier Takeoff Performance
TO_performance(W,S,C_L_max,C_D0,AR,e,g)

%% Task 2. Maneuvering Performance
doghouse(C_L_max,S,C_D0,AR,W,Swp_w,t_c_w)

%% Task 3 + 4. Flight Envelope and Specific Excess Power
%C_D0L is the 0 Lift Coefficent of Drag when th eplane is loaded
C_D0L = C_D0; %Assuming everything is stored inside the aircraft
Flight_envelope(AR, Swp_w, S, t_c_w, MTOW, 2 * T_dry, C_D0, C_D0L, C_L_max);

%% Task 5. Carrier Landing and Arrestment
app_coef = 1.1; % range from 1.1 ~ 1.15
V_wod = 15 * u.knot; % Arbitrary
L_s = 344 * u.ft;

V_stall = sqrt(2*W*g/(Atm.density(0*u.ft)*u.kg/u.m^3*S*C_L_max));
V_app = app_coef * V_stall;
V_eng = unitConvert(1.05 * V_app - V_wod, u.knot);
V_eng_range = linspace(100,180).*u.knot; 
%k_E_eng = 1/2*unitConvert(W,'US')*V_eng^2;
C2 = 40000 * u.lbf * (145 * u.knot)^2; 
W_arrest_limit = C2 ./ (V_eng_range.^2);

figure()
hold on
area(separateUnits(unitConvert(V_eng_range, u.knot)), separateUnits(W_arrest_limit), 'FaceColor',[0.95 0.9 0.9], 'EdgeColor','none')
plot(separateUnits(unitConvert(V_eng_range, u.knot)), separateUnits(W_arrest_limit))
ylim([20000 70000])
plot(separateUnits(unitConvert(V_eng, u.knot)), separateUnits(unitConvert(W*g, u.lbf)),'Marker','.','MarkerSize',10,'LineStyle','none')
grid on
grid minor
title("Arresting gear performance")
xlabel("Engaging speed (knots)")
ylabel("Airplane weight (lbf)")
legend('', 'Weight capacity for Mark 7 mod 3', 'Landing condition')
hold off
%% Task 6 & 7 Setup: Single Engine Rate of Climb (SEROC) & Climb Performance: Rate and Angle of Climb
% Run this first before running either 6 or 7

V_climb_range = unitConvert(u.knot .*linspace(200,1000,100),'SI');
rho = Atm.density(10000* u.ft) * u.kg/u.m^3;
Mb = ul(V_climb_range) ./Atm.sonic_speed(10000*u.ft);
hb = ul(10000*u.ft);
K = K_find_matrix(Mb,ul(AR),ul(Swp_w), ul(t_c_w), ul(W), hb, ul(S));
C_L_req = ul(W*g./(1/2*rho*V_climb_range.^2*S));
C_D = C_D0 + K .* C_L_req.^2;
T_dry = 123E3 * u.N;
T_wet = 191E3 * u.N;

D = 1/2 * rho .* V_climb_range.^2 * S .* C_D;

%% Task 6 - output given in Command line
% Takeoff procedure: Landing gear included
M_TO = ul(V_stall*1.2) ./ Atm.sonic_speed(0);
h_TO = 0;
K_TO = K_find_matrix(M_TO,ul(AR), ul(Swp_w), ul(t_c_w), ul(W), h_TO, ul(S));
C_L_req_TO = C_L_max / 1.21;    % Raymer P.129
% Assuming frontal area is approx. 22 m2
C_D_TO = C_D0 + 0.7 * 22 * u.m^2 / S_ref + K_TO * C_L_req_TO^2;
D_TO = 1/2 * rho .* (V_stall*1.2)^2 * S_ref * C_D_TO;

SEROC_TO = unitConvert(V_stall*1.2 * (T_wet - D_TO) / (W*g), u.ft / u.min);
fprintf("The SEROC of takeoff is %.2f ft/min.\n", double(separateUnits(SEROC_TO)))

% Approach procedure: Flap & Landing gear included
M_app = ul(V_app) ./ Atm.sonic_speed(0);
h_app = 0;
K_app = K_find_matrix(M_app,ul(AR), ul(Swp_w), ul(t_c_w), ul(W), h_app, ul(S));
C_L_req_app = 2*W*g/(rho*S*V_app^2);    % Raymer P.129
% Assuming frontal area is approx. 22 m2, 0.075 to account for flaps
C_D_app = C_D0 + 0.7 * 22 * u.m^2 / S_ref + 0.075 + K_app * C_L_req_app^2;
D_app = 1/2 * rho .* V_app^2 * S_ref * C_D_app;

SEROC_app = unitConvert(V_app * (T_wet - D_app) / (W*g), u.ft / u.min);     % This would benefit a lot from empty weight
fprintf("The SEROC of approach is %.2f ft/min.\n", double(separateUnits(SEROC_app)))

%% Task 7 Plot
a_climb = asind(ul((T_dry * 2 - D)/(W*g)));
ROC = ul(V_climb_range .* (T_dry * 2 - D)/(W*g));

max_a = [max(a_climb) ul(V_climb_range(a_climb==max(a_climb)))];
max_ROC = [max(ul(ROC)) ul(V_climb_range(ROC==max(ROC))) a_climb(ROC==max(ROC))];

figure()
grid on
grid minor
yyaxis left
hold on
plot(ul(V_climb_range), ROC, 'b:')
plot(max_ROC(2), max_ROC(1), 'LineStyle','none','Marker','.','MarkerSize',15, 'MarkerFaceColor','b')
ylabel("Rate of climb in m/s","Color",'b')
yyaxis right
plot(ul(V_climb_range), a_climb, 'r')
ylabel("Angle of climb in degrees",'Color','r')
plot(max_a(2), max_a(1), 'LineStyle','none','Marker','.','MarkerSize',15, 'MarkerFaceColor','r')

legend("Rate of climb", "Maximum ROC = "+real(max_ROC(1))+" m/s at Vy = "+real(max_ROC(2)*cosd(max_ROC(3)))+" m/s", ...
    "Angle of climb", "Maximum AOC = "+real(max_a(1))+" degrees at Vx = "+real(max_a(2)*sind(max_a(1)))+" m/s", 'Location','best')
title("Aircraft climb performance at 10,000 ft")
xlabel("Airspeed in m/s")

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
figure;
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