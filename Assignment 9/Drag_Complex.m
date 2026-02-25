function [C_D0] = Drag_Complex(Q, l_f, d_f, l_N, d_N, QCS_w, QCS_ht, QCS_vt, t_c_w, t_c_ht, t_c_vt, c_w, c_r, c_ht, c_vt, S_ref, S_w, S_ht, S_vt)
% Drag Complex computes the C_D_0 value for a specific aircraft
% Everything should be input in metric

%Variable descriptions
%Q: interferance factors, Q = [Qf Qw Qht Qvt Qn]
%l_f: Length of the fuselage
%d_f: Diameter of the fuselage
%l_N: Length of the nacelles
%d_N: Diameter of the nacelles
%QCS_w: Quarter Chord Sweep for the wing in radians
%QCS_ht: Quarter Chord Sweep for the horizontal tail in radians
%QCS_vt: Quarter Chord Sweep for the vertical tail in radians
%t_c_w: average t/c for the wing
%t_c_ht: average t/c for the horizontal tail
%t_c_vt: average t/c for the vertical tail

%c_w: mean chord of the wing
%c_r: root chord of the wing
%c_ht: mean chord of the horizontal tail
%c_vt: mean chord of the horizontal tail

%S_ref: reference area of the aircraft
%S_w: area of the wing
%S_ht: area of the horizontal tail
%S_vt: area of the vertical tail

u = symunit; % Initialise symbolic units object

%% Global Constants
% Set these to be the values used for the Assignment 8 trimming code
M = 0.9;
a = 294.9 * u.m / u.s; %m/s
V = M * a;

p = 0.3023 * u.kg / (u.m^3); %air density, kg/m^3
mu = 1.4216e-05 * u.kg / u.m / u.s; %kinematic viscosity, kg/m/s

%% Part 2: Parasitic Drag Estimation
%M = V/a; % We are using the mach of the flight conditions given
%Form Factor
% Fuselage
if d_f == 0
    lamf = 0;
    FFf = 0;
else
    lamf = l_f/d_f;                             % fineness ratio for fuselage
    FFf = 0.9 + 5 / (lamf^(1.5)) + lamf / 400;  % Raymer 6th ed
end

% Wings
Z_w = (2 - M^2)*cos(QCS_w) / sqrt(1 - (M*cos(QCS_w))^2);
FFw = 1 + Z_w*(t_c_w) + 100*(t_c_w)^4;
% Horizontal Tail
Z_ht = (2 - M^2)*cos(QCS_ht) / sqrt(1 - (M*cos(QCS_ht))^2);
FFht = 1 + Z_ht*(t_c_ht) + 100*(t_c_ht)^4;
  
% Vertical Tail
Z_vt = (2 - M^2)*cos(QCS_vt) / sqrt(1 - (M*cos(QCS_vt))^2);
FFvt = 1 + Z_vt*(t_c_vt) + 100*(t_c_vt)^4;

% Nacelle
if l_N == 0
    FFn = 0;
else
    FFn = 1 + 0.35 / (l_N / d_N);
end

% Order is: fuselage, wings, h tail, v tail, nacelles
FF = [FFf FFw FFht FFvt FFn];        % add in these for all the components
% Interferance factors


% Qf = 1;          % The nacelles seem more than Dn away from the fuselage
% Qn = 1.3;        % Seems less than Dn away from wing
% Qw = 1;
% Qvt = 1.03;      % Seems both V and conventional
% Qht = 1.08;      % Horizontal stabilizer separate component
%Q = [Qf Qw Qht Qvt Qn];


% Skin friction factors
% Order is: fuselage, wings, h tail, v tail, nacelles
  
% Fuselage
Re_f = l_f * (V * p / mu);
C_f_f = 0.455 / ( log10(Re_f)^2.58);
% Wings
Re_w = c_w * (V * p / mu);
C_f_w = 0.455 / ( log10(Re_w)^2.58);
% Horizontal Tail
Re_ht = c_ht * (V * p / mu);
C_f_ht = 0.455 / ( log10(Re_ht)^2.58);
% Vertical Tail
Re_vt = c_vt * (V * p / mu);
C_f_vt = 0.455 / ( log10(Re_vt)^2.58);
% Nacelles
Re_n = l_N * (V * p / mu);
C_f_n = 0.455 / ( log10(Re_n)^2.58);
C_f = [C_f_f C_f_w C_f_ht C_f_vt C_f_n];
% Wetted area of the different components
% Order is: fuselage, wings, h tail, v tail, nacelles
% Fuselage
if lamf == 0
    S_wet_f = 0;
else
    S_wet_f = pi * d_f * l_f * ( (1 - 2/lamf)^(2/3) ) * (1 + 1/lamf^2);
end
% Wings
S_wet_w = (S_w - c_r * d_f) * 2 * 1.02; %removing the area also covered by the fuselage
% Horizontal tail
S_wet_ht = S_ht * 2 * 1.02;
% Vertical tail
S_wet_vt = S_vt * 2 * 1.02;
% Nacelles 
S_wet_n = pi * d_N * l_N;
S_wet = [S_wet_f S_wet_w S_wet_ht S_wet_vt S_wet_n];

% component build up
C_D0 = sum(simplify(FF .* Q .* C_f .* S_wet), 'all') / S_ref;
end
