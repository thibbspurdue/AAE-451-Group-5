%% AAE 451 Team 5 Assignment 8 Trim Drag stuff

%% Initialisation

% Unit setup
u = symunit; % Initialise symbolic units object

function output = ul(input)
    output = double(separateUnits(input));
end

%% Variable Definition
spreadsheet = 'Parameters_copy.xlsx';
aircraft = 'Sunfish';
airfoil = 'Airfoil';

Parameter_Import(spreadsheet, aircraft, airfoil);
[l_t, l_h, l_v, S_h, S_t] = Parameters_rebalance(l_t, l_v, x_ac, S_t, S_v);

%% Step 0.5, call the drag complex function
%assumptions made:
%1. There is no variation for QCS, QCS=LES=TES
Q = [Qf Qw Qht Qvt Qn];
QCS_w = Swp_w;
QCS_ht = Swp_ht;
QCS_vt = Swp_vt;
S_ref = S;
C_D0 = Drag_Complex(Q, l_f, d_f, l_N, d_N, QCS_w, QCS_ht, QCS_vt, t_c_w, t_c_ht, t_c_vt, c_bar, c_r, c_ht, c_vt, S_ref, S_w, S_t, S_v);
%% 2.a  geometry, horizontal tail
V_h = S_h * l_h / S_w / c_bar;

%% 2.b  Scissor Plot
n = 100; %number of points

    %x var is x_cg/c_bar
x_cg_c_bar = linspace(-1, 1, n); %linspace(0.1, 0.6, n);
x_cg = x_cg_c_bar ; % * c_bar; Be concerned with x_cg def later, unitless here
x_ac = x_ac / c_bar;

    %derived variables
C_L_t_ND = C_L_a_t * a_s; %Coefficent of lift for the tail if nose down
C_M_RR = -C_L_max * SM + C_M_0; %Coefficent of moment for required recovery

de_da = separateUnits(1.6 * C_L_a / pi / AR);


    %Parameters for Takeoff Rotation
% C_L_t_NU = ; %Maximum negative tail lift for nose-up control (-0.5 ~ -0.8)
% C_M_RRo = ; %Coefficent of moment for required rotation
%     %Above depends on the configuration and the position of the main
%     %landing gear (0.1 ~ 0.2)

%Forward Limit (Stability)
St_S_FL = (x_cg - x_ac + SM) ./ ( n_h * (1 - de_da) * l_t ./ c_bar - (x_cg - x_ac + SM));

%Stall Recovery
St_S_SR = (C_M_0 + C_L_max * (x_cg - x_ac) - C_M_RR) ./ (C_L_t_ND * n_h * (l_t / c_bar - x_cg + x_ac));

%Take-Off Rotation
St_S_TR = (C_M_0 + C_L_rot * (x_cg - x_ac) - C_M_RRo) ./ (C_L_t_NU * n_h * (l_t / c_bar - x_cg + x_ac));

%Graphing section, Scissor Plot
figure;
plot(separateUnits(x_cg_c_bar), vpa(St_S_FL), 'k');
hold on; grid on;
plot(separateUnits(x_cg_c_bar), separateUnits(St_S_SR), '-.k');
plot(separateUnits(x_cg_c_bar), St_S_TR, '--k');
yline(double(S_t/S), '--b')

ylim_radius = 0.3; ylim([(double(S_t/S) - ylim_radius) (double(S_t/S) + ylim_radius)])

legend("Forward Limit (Stability)", "Aft Limit (Stall Recovery Control", "Forward Limit (Nose-up Control", "Selected S_t/S")
xlabel('x_{cg}/c (Center of Gravity Position)')
ylabel('S_{t}/S (Horizontal tail Area Ratio)')
title("Scissor Plot", aircraft)



%% 2.c  Trim analysis
%C_L_trim = 2 * W / p / S_w / V.^2; %this is the actual value
C_L_trim = linspace(-1, 2, n);

%x_cg = x_ac - SM + (C_L_a_t * (1 - de_da) * V_h) / (C_L_a + (S_t / S_w) * C_L_a_t * (1 - de_da));
[~, i1] = min((St_S_FL - double(S_t/S)).^2);
[~, i2] = min((St_S_TR - double(S_t/S)).^2);
x_cg = 0.5 * (x_cg(i1) + x_cg(i2));

C_M_a_t = -0.22 / u.rad;
%Slide 23 semi-nonsense
C_L_t_de = (C_L_a_t/pi) * (acos(1 - 2*E) + 2 * sqrt(E * (1 - E)));
C_L_de_t = (C_M_a_t / pi) * (1 - E) * sqrt(2*E - 1); %under the assumption there is a typo in slide 23

C_L_de = (S_t / S_w) * C_L_t_de;
C_M_de = C_L_de_t * (S_t / S_w) * (x_cg - x_ac) - C_L_t_de * V_h;
% C_L_de = (S_t / S_w) * C_L_de_t;
% C_M_de = C_L_t_de * (S_t / S_w) * (x_cg - x_ac) - C_L_de_t * V_h;

%Slide 22, less semi-nonsense
a_trim = (C_M_0 * C_L_de + C_M_de .* (C_L_trim - C_L_0)) ./ (C_L_a * C_M_de - C_L_de * C_M_a);
de_trim = - (C_M_0 * C_L_a + C_M_a * (C_L_trim - C_L_0)) ./ (C_L_a * C_M_de - C_L_de * C_M_a);

%Graph Output
figure;
subplot(2,1,1);
plot(C_L_trim, separateUnits(a_trim) * 180 / pi);
subtitle("Trim Angle of Attack vs Trim Lift Coefficent")
xlabel("Trim Lift Coefficent")
ylabel("Trim Angle of Attack")
%ylim([-pi/9 pi/9])
grid on;

subplot(2,1,2);
plot(C_L_trim, separateUnits(de_trim) * 180 / pi);
subtitle("Trim Elevator Deflection vs Trim Lift Coefficent")
xlabel("Trim Lift Coefficent")
ylabel("Trim Elevator Deflection")
%ylim([-pi/9 pi/9])
de_max = vpa(max(de_trim));
grid on;
%yline([de_max -de_max], '--r') %The red lines on the graph

%% 2.c trimmed drag polar
C_L_wing = C_L_0 + C_L_a * a_trim;
C_L_tail_clean = C_L_0_t + C_L_a_t * a_trim;
C_L_tail = C_L_tail_clean + C_L_de * de_trim;

%define K in the same way that the K is defined for the tail
e = 4.61 * (1 - 0.045*AR^0.68) * (cos(Swp_w)^0.15) - 3.1; %taken from a4
K = 1 / (pi * AR * e);

if(e_t == 0) %using the horizontal tail only, someone else can change from here if they wnt
    e_t = 4.61 * (1 - 0.045*AR_ht^0.68) * (cos(Swp_ht)^0.15) - 3.1; %taken from a4
end

K_t = 1 / (pi * e_t * AR_ht);

C_D_clean = C_D0 + K * C_L_wing.^2 + K_t * (S_t / S) * C_L_tail_clean.^2;
C_D_trimmed = C_D0 + K * C_L_wing.^2 + K_t * (S_t / S) * C_L_tail.^2;

figure;
plot(C_L_trim, C_D_clean);
hold on; grid on;
plot(C_L_trim, C_D_trimmed);
legend("Clean", "Trimmed")
ylabel("CD")
xlabel("CL trim")
title("Aircraft Drag Polar")

%% 2.d  geometry, vertical tail
V_t = S_t * l_v / S_w / c_bar;