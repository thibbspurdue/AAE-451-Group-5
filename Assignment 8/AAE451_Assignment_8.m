%% AAE 451 Team 5 Assignment 8 Trim Drag stuff

%% Initialisation

% Unit setup
u = symunit; % Initialise symbolic units object

function output = ul(input)
    output = double(separateUnits(input));
end

%% Variable Definition
%Global Constants
V = * u.m / u.s; %Flight speed
p = * u.kg / u.m^3;


%Aircraft
W = * u.kg; %Aircraft weight for trim purposes
    %Wing
AR = ;
Swp = * u.deg;
c_bar = * u.m;
b_w = * u.m;
S_w = * u.m^2;
    %Horizontal Tail
l_t = * u.m;
S_t = * u.m^2;
AR_t = ;
e_t = ; %efficency factor, tail
    %Vertical Tail
l_v = * u.m;
S_v = * u.m^2;
    %Aerodynamic Coefficents, wing
C_L_0 = ;
C_L_a =  / u.rad;
C_L_d =  / u.rad;
C_M_0 = ;
C_M_a =  / u.rad;
C_M_d =  / u.rad;
a_s =  * u.rad; %alpha stall
    %Aerodynamic Coefficents, tail
%C_L_0_t = ;
C_L_a_t =  / u.rad;
%C_L_d_t =  / u.rad;
%C_M_0_t = ;
C_M_a_t =  / u.rad;
%C_M_d_t =  / u.rad;
    %Aerodynamic Coefficents, drag
C_D_0 = ;
    %Aero Coefficents, X
%x_cg = * u.m;
x_ac = * u.m;




%% 2.a  geometry, horizontal tail
V_h = S_t * l_t / S_w / c_bar;

%% 2.b  Scissor Plot
n = 100; %number of points

%needed variables
n_h = ; %n_h in the slides, think this might mean n_t
de_da = ;
C_L_max = ;
C_L_rot = ;


    %x var is x_cg/c_bar
x_cg_c_bar = linspace(0.1, 0.6, n);
x_cg = x_cg_c_bar * c_bar;


    %derived variables
C_L_t_ND = C_L_a_t * a_s; %Coefficent of lift for the tail if nose down
C_M_RR = -C_L_max * SM + C_M_0; %Coefficent of moment for required recovery


    %Parameters for Takeoff Rotation
C_L_t_NU = ; %Maximum negative tail lift for nose-up control (-0.5 ~ -0.8)
C_M_RRo = ; %Coefficent of moment for required rotation
    %Above depends on the configuration and the position of the main
    %landing gear (0.1 ~ 0.2)


%Forward Limit (Stability)
St_S_FL = (x_cg - x_ac + SM) / ( n_h * (1 - de_da) * l_t / c_Bar - (x_cg - x_ac + SM));

%Stall Recovery
St_S_SR = (C_M_0 + C_L_max * (x_cg - x_ac) - C_M_RR) / (C_L_t_ND * n_h * (l_t / c_bar - x_cg + x_ac));

%Take-Off Rotation
St_S_TR = (C_M_0 + C_L_rot * (x_cg - x_ac) - C_M_RRo) / (C_L_t_NU * n_h * (l_t / c_bar - x_cg + x_ac));
%% 2.c  Trim analysis
C_L_trim = 2 * W / p / S_w / V.^2;

%Slide 23 semi-nonsense
E = c_e / c_t; %This is an airfoil thing
C_L_t_de = (C_L_a_t/pi) * (acos(1 - 2*E) + 2 * sqrt(E * (1 - E)));
C_M_t_de = (C_M_a_t / pi) * (1 - E) * sqrt(2*E - 1);

%Slide 22, less semi-nonsense
a_trim = (C_M_0 * C_L_de + C_M_de * (C_L_trim - C_L_0)) / (C_L_a * C_M_de - C_L_de * C_M_a);
de_trim = - (C_M_0 * C_L_a + C_M_a * (C_L_trim - C_L_0)) / (C_L_a * C_M_de - C_L_de * C_M_a);

%% 2.d  geometry, vertical tail
V_h = S_t * l_t / S_w / c_bar;
