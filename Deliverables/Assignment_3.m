%% Team 5 Matlab Sizing Code
%% Conversions
ft_NM = 6076.12;
ft_Mi = 5280;
%% Design Requirements
W_payload = 6000; %lbs
W_crew = 215; %lbs
% Configuration: Carrier-based, Fixed Wing (or simple fold), Afterburning Turbofans.
%% Design Mission
W1_W0 = 0.970;
W2_W1 = 0.985;
Cruise_Out = 400; %NM
Combat_Time = 3; %min
Combat_Speed = 1.2; %Mach
Cruise_Back = 400; %NM
Loiter_Time = 20; %minutes
W7_W6 = 0.995;
%% Technical Data
%Propulsion
Cruise_SFC = 0.82; %lb/lbf * hr
Combat_SFC = 1.844; %lb/lbf * hr
Loiter_SFC = 0.80; %lb/lbf * hr
% Aerodynamics
Cruise_L_D = 9.2;
Combat_L_D = 4.5;
Loiter_L_D = 11;
%% Raymer Sizing Constraints
A = -0.02;
B = 2.16;
C1 = -0.1;
C2 = 0.2;
C3 = 0.04;
C4 = -0.10;
C5 = 0.08;
Kvs = 1;  % 1 for fixed wing sweep
% Carrier Penalty: +0.03 < CP < 0.06 (Must be added to the result to account for keel beam, arresting hook, and heavy gear)
%% Performance Constraints
M_max = 1.2;%Mach during mission, 1.6 fond in Assignment 1
AR = 4;
Wing_loading = 132; %lb/ft^2
Thrust_Weight = 8.557;
%% Assumed Constraints
V_Cruise = 516 * ft_NM; % Nicolai (136), Assumption that Cruise is 0.9 at alt 36000-45000
%% Fuel Fraction Method
% The Fuel fraction can be calculated before determining the W0, We
    %Initial Cruise
%Convert to lbs, ft, etc
R = Cruise_Out * ft_NM;
C = Cruise_SFC;
V = V_Cruise;
W3_W2 = exp(-R*C/V/Cruise_L_D);
    %Combat
E = Combat_Time / 60;
C = Combat_SFC;
W4_W3 = exp(-E*C / Combat_L_D);
    %Final Cruise
%Convert to lbs, ft, etc
R = Cruise_Back * ft_NM;
C = Cruise_SFC;
V = V_Cruise;
W5_W4 = exp(-R*C/V/Cruise_L_D);
    %Loiter
E = Loiter_Time / 60;
C = Loiter_SFC;
W6_W5 = exp(-E*C / Loiter_L_D);
%% Determine the Fuel Fraction
k = 0.05 + 0.01; %Coefficent of trapped and reserve fuel, given in the lecture slides (Raymer 
%I think theres a W8_W7 but i just saw that once in the book
Wf_W0 = (1 + k)*(1 - W7_W6 * W6_W5 * W5_W4 * W4_W3 * W3_W2 * W2_W1 * W1_W0);
%% Iteration Section
%Determine an initial guess for the weight
%Im not sure how the convergance code will be written
%Add that stuff in better later
for Carrier_Penalty = [0.03 0.06]
    W0 = 66000; %MTOW
    W0i = 0; %This is for the previous guess
    while (W0 - W0i)^2 > 1
        W0i = W0; %Set the previous guess
    
        % Determine the Empty Weight Fraction
        %I dont know what Kvs or Carrier Penalty are
        We_W0 = A + B*(W0^C1)*(AR^C2)*(Thrust_Weight^C3)*(Wing_loading^C4)*(M_max^C5)*Kvs + Carrier_Penalty;
        
        %Re-Determine the empty weight
        W0 = (W_crew + W_payload) / (1 - Wf_W0 - We_W0);
    end
    fprintf("\n\n~ ~ ~ ~\n Iteration Results \n~ ~ ~ ~\n\n")
    fprintf("For a Carrier Penalty of %0.2f : \n", Carrier_Penalty)
    fprintf("Our final calculated Initial Weight for the aircraft is W_0 = %0.2f lbs\n", W0);
    fprintf("Our final calculated Empty Weight for the aircraft is W_e = %0.2f lbs\n", We_W0*W0);
    fprintf("Required fudge factor: %0.2f\n", 32100/(We_W0*W0));
end
