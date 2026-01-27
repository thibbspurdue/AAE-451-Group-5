% AAE 451 
% Assignment 4
%%Variable definitions
%Weight and Geometry
W = ;       % Weight

AR = 4;     % Aspect Ratio
d = 2.165;       % fuselage diameter, if its noncircular we need
D = sqrt(4 * Amax / pi); %noncircular eqn
l_f = 18.379;     % fuselage length (m) from excel
b = 44.9;   % wingspan (ft)

S_ref =;    % not supre sure if this is S or not
    %Wing Geometry
t_c_w = ;%thickness over chord wing
MCS_w = ;     % Mid chord sweep
QCS_w = ;     %Quarter chord sweep
LES_w = 30;   %Leading edge sweep (deg)
S = 500;    % Wing Area (ft^2)
S_w = S; 
ch_w = ;%Chord length of the wing
    %Horizontal Tail Geometry
t_c_ht = ;%thickness over chord
MCS_ht = ;     % Mid chord sweep
QCS_ht = ;     %Quarter chord sweep
LES_ht = ;   %Leading edge sweep (deg)
ch_ht = ;%Chord length of the horizontal tail
    %Vertical Tail Geometry
t_c_vt = ;%thickness over chord
MCS_vt = ;     % Mid chord sweep
QCS_vt = ;     %Quarter chord sweep
LES_vt = ;   %Leading edge sweep (deg)
ch_vt = ;%Chord length of the vertical tail
    %Nacelle Geometry
l_N = ;%Nacelle length
d_N = ;%Nacelle diameter

%Flight conditions
V = 516;             % flight velocity (from Assignment 3, not sure units)
h = 40000;           % altitude (FEET)
p = 5.87*10^-4;      % air density (Slugs/ft^3)
a = 659.8;           % speed of sound (mph)
q = 100691.89;       % dynamic pressure (Pa)
mu = 2.969*10^-7;    % kinematic viscosity (slug/(ft s))

%% Part 1: Subsonic Analysis & Vortex Lift
%We should probably have multiple graphs which sweep over M and AoA
AoA = linspace(-5, 30, 101);

%
Kp = (2*pi*AR) / (2 + sqrt(AR^2 * (1 + tan(MCS)) + 4))
Kv = pi * AR / 2 / cos(LES)
C_Lp = Kp * sin(AoA)*cos(AoA)
C_Lv = Kv * (sin(AoA)^2)*cos(AoA)
C_L = C_Lp + C_Lv


%% Part 2: Parasitic Drag Estimation

%% Part 3: Supersonic Effects and Cruise Efficiency


%% Various Equations idk where fit in



%Oswald effciency factor
e = 0.98 * (1 - (d/b)^2); 


%sum all the wing components to get the total using component build up
%method

%Form factor calculations

%Order is: fuselage, wings, h tail, v tail, nacelles

%Form Factor ones
    %fuselage
lamf = l_f/d; %fineness ratio for fuselage
FFf = 0.9 + 5 / (lamf^(1.5)) + lamf / 400; %Raymer 6th ed
    %Wings
Z_w = (2 - M^2)*cos(QCS_w) / sqrt(1 - (M*cos(QCS_w))^2)
FFw = 1 + Z_w*(t_c_w) + 100*(t_c_w)^4
    %Horizontal Tail
Z_ht = (2 - M^2)*cos(QCS_ht) / sqrt(1 - (M*cos(QCS_ht))^2)
FFht = 1 + Z_ht*(t_c_ht) + 100*(t_c_ht)^4
    %Vertical Tail
Z_vt = (2 - M^2)*cos(QCS_vt) / sqrt(1 - (M*cos(QCS_vt))^2)
FFvt = 1 + Z_vt*(t_c_vt) + 100*(t_c_vt)^4
    %nacelle
FFn = 1 + 0.35 / (l_N / d_N)
    %Order is: fuselage, wings, h tail, v tail, nacelles
FF = [FFf FFw FFht FFvt FFn]; % add in these for all the components

%Interferance factors
Qf = 1; %the nacelles seem more than Dn away from the fuselage
Qn = 1.3; %Seems less than Dn away from wing
Qw = 1;
Qv = 1.03; %seems both V and conventional
Qh = 1.08; %horizontal stabilizer separate component
%Not sure how these all combine ... --> resolved, by individual comp
Q = [];

%Skin friction factors
%Order is: fuselage, wings, h tail, v tail, nacelles
    %figure out where the flow is terminal or laminar

    %Fuselage
C_f_f = 

C_f = [];

%Wetted area of the different components
%Order is: fuselage, wings, h tail, v tail, nacelles
    %Wings
S_wet_w = S_w * 2 * 1.02;
    %h tail
S_wet_ht = S_ht * 2 * 1.02;
    %v tail
S_wet_vt = S_vt * 2 * 1.02;
S_wet = [];

% component build up
C_D0 = sum(FF .* Q .* C_f .* S_wet, 'all') / S_ref;

%Add misc drag
C_D0_misc = 0.1 * C_D0; %estimation from drag pred pg 25
C_D0 = C_D0 + C_D0_misc; %add the misc values in

%Cdwake
%SWP is from the cdwake slide i think its total sweep
M_DD = KA/cos(SWP) - t_c/(cos(SWP)^2) - C_L / (10 * (cos(SWP)^3))
M_crit = M_DD - 0.08;

C_D_wake = 

% c_dc has something to do with speed in mach
K_sub = 1 / (pi * AR * e);
K_sup = AR * (M^2 - 1) * cos(LES) / (4 * SR * sqrt(M2 - 1) - 2)

C_Di = K_sub * (C_L^2)
C_D = C_D0 + C_Di %are we doing cdwake?

LDMax = 1/sqrt(C_D0+K) %% FIND K!!!
Effic_Index = Mach*LDMax;

