function [R] = Range(W_P, W_E, TOW, V_Cruise, Cruise_L_D, Combat_L_D, Loiter_L_D)
%% Unit setup
% Unit setup
u = symunit; % Initialise symbolic units object
%% RANGE Funciton gives a range using the Breguet Range Equation for a
%specific payload weight
%W_E is the weight of the aircraft with no fuel or payload
V_Cruise = V_Cruise * u.m/u.s;
%SFC values
Cruise_SFC = 0.80*u.lbm/(u.lbf*u.hr);      % lb/lbf * hr, currently from propulsion system choice
Combat_SFC = 1.9*u.lbm/(u.lbf*u.hr);       % lb/lbf * hr, currently from propulsion system choice
Loiter_SFC = 0.80*u.lbm/(u.lbf*u.hr);      % lb/lbf * hr, currently from propulsion system choice

% Configuration: Carrier-based, Fixed Wing (or simple fold), Afterburning Turbofans.
W1_W0 = 0.970;          % Given in Assignment 3 Description
W2_W1 = 0.985;          % Given in Assignment 3 Description
W7_W6 = 0.995;          % Given in Assignment 3 Description
Combat_Time = 2*u.min;        % min Given in RFP Mission Profile
%Combat_Speed = 1.6;     % Mach Given in RFP Mission Profile
Loiter_Time = 20*u.min;       % minutes Given in RFP Mission Profile

% Determine the Fuel Fraction
k = 0.05 + 0.01; %Coefficent of trapped and reserve fuel, given in the lecture slides

%% Unit convert the above area so it meshes together 
g = 9.81*u.m/u.s/u.s;

Cruise_SFC = Cruise_SFC * g;
Combat_SFC = Combat_SFC * g;
Loiter_SFC = Loiter_SFC * g;

Cruise_SFC = unitConvert(Cruise_SFC, 1/u.s);
Combat_SFC = unitConvert(Combat_SFC, 1/u.s);
Loiter_SFC = unitConvert(Loiter_SFC, 1/u.s);

Combat_Time = unitConvert(Combat_Time, u.s);
Loiter_Time = unitConvert(Loiter_Time, u.s);
%% Calculating General values using input weights
W_F = TOW - W_P - W_E; %Total fuel weight
W_f = W_F / (1 + k); %Usable Fuel Weight
W_0 = TOW; %W_0 is defined as the takeoff weight
W_7 = W_E + W_P + (W_F - W_f); %The landing weight includes the payload, carried the whole time 


%Wf_W0 = W_f / W_0;
W7_W0 = W_7 / W_0;
%% Calculations (Integration of Assignments 3, 4, 5)
%% Assignment 3
% Fuel Fraction Method

%Combat
E = Combat_Time;
C = Combat_SFC;
W4_W3 = exp(-E*C / Combat_L_D);

%Loiter
E = Loiter_Time;
C = Loiter_SFC;
W6_W5 = exp(-E*C / Loiter_L_D);


%Figuring out the weight fraction from cruising
WC_frac = W7_W0 / (W7_W6 * W6_W5 * W4_W3 * W2_W1 * W1_W0);

% Cruise_Range
C = Cruise_SFC;
V_cruise = V_Cruise;

R = -(V_cruise*Cruise_L_D/C) * log(WC_frac);
R = vpa(R); %make it numeric

%How cruise is calculated originally, here for reference
% % Initial Cruise
% R = Cruise_Out;
% C = Cruise_SFC;
% V_cruise = V_Cruise;
% W3_W2 = exp(-R*C/(V_cruise*Cruise_L_D));
% 
% %Final Cruise
% R = Cruise_Back;
% C = Cruise_SFC;
% V_cruise = V_Cruise;
% W5_W4 = exp(-R*C/(V_cruise*Cruise_L_D));
end

