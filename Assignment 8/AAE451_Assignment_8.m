%% AAE 451 Team 5 Assignment 8 Trim Drag stuff

%% Initialisation

% Unit setup
u = symunit; % Initialise symbolic units object

function output = ul(input)
    output = double(separateUnits(input));
end

%% Variable Definition
aircraft = 'Sunfish';

%Aircraft
fields_lengths = {'c_bar', 'c_r','c_ht', 'c_vt', 'b_w', 'l_t','l_v', 'l_f', 'd_f', 'l_N', 'd_N'};
u_lengths = u.m * ones(length(fields_lengths),1);

fields_areas = {'S_w', 'S_t','S_v', 'S'};
u_areas = u.m^2 * ones(length(fields_areas),1);

fields_angles = {'Swp_w', 'Swp_ht', 'Swp_vt', 'a_s'};
u_rad = u.rad * ones(length(fields_angles),1);

    %nondimensional
fields_nondim = {'AR','AR_ht', 'AR_vt','e_t','C_L_0','C_L_0_t', 'C_M_0','x_ac', 'n_h','C_L_max', 'C_L_rot', 'C_L_t_NU', 'C_M_RRo','SM', 'Qf', 'Qw', 'Qht', 'Qvt', 'Qn', 'E'};
u_nd = ones(length(fields_nondim),1);

    %1/rad
fields_airfoil_inv_rads = {'C_L_a', 'C_L_d', 'C_M_a', 'C_M_d','C_L_a_t', 'C_M_a_t'};
u_inv_rad = (1/u.rad) * ones(length(fields_airfoil_inv_rads),1);

fields_weights = {'W'};
u_w = u.kg * ones(length(fields_weights),1);
%append all into one
fields = [fields_lengths, fields_areas, fields_angles, fields_nondim, fields_airfoil_inv_rads, ...
          fields_weights];

units = [u_lengths; u_areas; u_rad; u_nd; u_inv_rad; u_w];

%deal with reading in the multiple sheets later
T = readtable('Parameters_copy.xlsx','Sheet',aircraft);
data = vpa(table2array(T)) .* units;
x = cell2struct(num2cell(data), fields, 2);


% % Now you access them via x.AR, x.c_bar, etc.
fieldNames = fieldnames(x);

for i = 1:numel(fieldNames)
    assignin('base', fieldNames{i}, x.(fieldNames{i}));
end

%% Currently Overriding the Static Margin given in the sheet
SM = 0;

n_h = 0.9; %overriding the n value cause idk

%% Step 0.5, call the drag complex function
%assumptions made:
%1. There is no variation for QCS, QCS=LES=TES
Q = [Qf Qw Qht Qvt Qn];
QCS_w = Swp_w;
QCS_ht = Swp_ht;
QCS_vt = Swp_vt;
S_ref = S;
C_D0 = Drag_Complex(Q, l_f, d_f, l_N, d_N, QCS_w, QCS_ht, QCS_vt, t_c_w, t_c_ht, t_c_vt, c_bar, c_r, c_ht, c_vt, S_ref, S_w, S_ht, S_vt);
%% 2.a  geometry, horizontal tail
V_h = S_t * l_t / S_w / c_bar;

%% 2.b  Scissor Plot
n = 100; %number of points


    %x var is x_cg/c_bar
x_cg_c_bar = linspace(0.1, 0.6, n);
x_cg = x_cg_c_bar * c_bar;


    %derived variables
C_L_t_ND = C_L_a_t * a_s; %Coefficent of lift for the tail if nose down
C_M_RR = -C_L_max * SM + C_M_0; %Coefficent of moment for required recovery

de_da = 2 * C_L_a / pi / AR;

    %Parameters for Takeoff Rotation
% C_L_t_NU = ; %Maximum negative tail lift for nose-up control (-0.5 ~ -0.8)
% C_M_RRo = ; %Coefficent of moment for required rotation
%     %Above depends on the configuration and the position of the main
%     %landing gear (0.1 ~ 0.2)


%Forward Limit (Stability)
St_S_FL = (x_cg - x_ac + SM) ./ ( n_h * (1 - de_da) * l_t ./ c_Bar - (x_cg - x_ac + SM));

%Stall Recovery
St_S_SR = (C_M_0 + C_L_max * (x_cg - x_ac) - C_M_RR) ./ (C_L_t_ND * n_h * (l_t / c_bar - x_cg + x_ac));

%Take-Off Rotation
St_S_TR = (C_M_0 + C_L_rot * (x_cg - x_ac) - C_M_RRo) ./ (C_L_t_NU * n_h * (l_t / c_bar - x_cg + x_ac));

%Graphing section, Scissor Plot
figure;
plot(x_cg_c_bar, vpa(St_S_FL), 'k');
hold on; grid on;
plot(x_cg_c_bar, St_S_SR, '-.k');
plot(x_cg_c_bar, St_S_TR, '--k');
%yline(S_t/S, '--b')
legend("Forward Limit (Stability)", "Aft Limit (Stall Recovery Control", "Forward Limit (Nose-up Control", "Selected S_t/S")
xlabel('x_{cg}/c (Center of Gravity Position)')
ylabel('S_{t}/S (Horizontal tail Area Ratio)')


%% 2.c  Trim analysis
%C_L_trim = 2 * W / p / S_w / V.^2; %this is the actual value
C_L_trim = linspace(-1, 2, n);

%Slide 23 semi-nonsense
%% I dont know the difference between C_L_de_t and C_L_t_de
%E = c_e / c_t; %This is an airfoil thing
C_L_t_de = (C_L_a_t/pi) * (acos(1 - 2*E) + 2 * sqrt(E * (1 - E)));
C_L_de_t = (C_M_a_t / pi) * (1 - E) * sqrt(2*E - 1);

C_L_de = (S_t / S_w) * C_L_de_t;
C_M_de = C_L_t_de * (S_t / S_w) * (x_cg - x_ac) - C_L_de_t * V_h;

%Slide 22, less semi-nonsense
a_trim = (C_M_0 * C_L_de + C_M_de .* (C_L_trim - C_L_0)) ./ (C_L_a * C_M_de - C_L_de * C_M_a);
de_trim = - (C_M_0 * C_L_a + C_M_a * (C_L_trim - C_L_0)) ./ (C_L_a * C_M_de - C_L_de * C_M_a);


%Graph Output
figure;
subplot(2,1,1);
plot(C_L_trim, a_trim);
title("Trim Angle of Attack vs Trim Lift Coefficent")

subplot(2,1,2);
plot(C_L_trim, de_trim);
title("Trim Angle of Attack vs Trim Lift Coefficent")
de_max = vpa(max(de_trim));
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

C_D_clean = C_D_0 + K * C_L_wing.^2 + K_t * (S_t / S) * C_L_tail_clean.^2;
C_D_trimmed = C_D_0 + K * C_L_wing.^2 + K_t * (S_t / S) * C_L_tail_clean.^2;

figure;
plot(C_L_trim, C_D_clean);
hold on; grid on;
plot(C_L_trim, C_D_trimmed);
legend("Clean", "Trimmed")
ylabel("CD")
xlabel("CL_trim")
title("Aircraft Drag Polar")

%% 2.d  geometry, vertical tail
V_h = S_t * l_t / S_w / c_bar;
