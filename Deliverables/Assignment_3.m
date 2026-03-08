%% Team 5 Matlab Sizing Code
function mass_estimate = Assignment_3()
    %% Conversions
    ft_NM = 6076.12;  % 1 Nautical Mile = 6076 feet
    ft_Mi = 5280;     % 1 Mile = 5280 feet
    
    %% Aircraft Dependent Paramaters
    % Propulsion
    Cruise_SFC = 0.82;     % lb/lbf * hr
    Combat_SFC = 1.844;    % lb/lbf * hr
    Loiter_SFC = 0.80;     % lb/lbf * hr
    Cruise_L_D = 9.2;      % Assignment 4
    Combat_L_D = 4.5;      % Assignment 4
    Loiter_L_D = 11;       % Assignment 4
    Kvs = 1;               % 1 for fixed wing sweep
    AR = 4;                % 
    Wing_loading = 96;     %lb/ft^2
    Thrust_Weight = 0.93;
     
    %% Fixed Parameters
    W_payload = 6000;   %lbs, Assignment 3
    W_crew = 215;       %lbs, Assignment 3
    W1_W0 = 0.970;      % Assingment 3
    W2_W1 = 0.985;      % Assignment 3
    Combat_Time = 2;    % min, RFP
    Combat_Speed = 2;   % Mach 2 is desired, RFP
    Loiter_Time = 20;   % minutes
    W7_W6 = 0.995;      % Assignment 3
    Cruise_Out = 700;   % NM, RFP
    Cruise_Back = 700;  %, RFP
    % Raymer Sizing Constraints
    A = -0.02;          % Assignment 3
    B = 2.16;           % Assignment 3
    C1 = -0.1;          % Assignment 3
    C2 = 0.2;           % Assignment 3
    C3 = 0.04;          % Assignment 3
    C4 = -0.10;         % Assignment 3
    C5 = 0.08;          % Assignment 3
    M_max = 2;
    
    %% Assumed Constraints
    V_Cruise = 516 * ft_NM; % Nicolai (136), Assumption that Cruise is 0.9 at alt 36000-45000
    
    %% Calculations
    % Fuel Fraction Method
    % The Fuel fraction can be calculated before determining the W0, We
    
    % Initial Cruise
    R = Cruise_Out * ft_NM;
    C = Cruise_SFC;
    V = V_Cruise;
    W3_W2 = exp(-R*C/(V*Cruise_L_D));

    %Combat
    E = Combat_Time / 60;
    C = Combat_SFC;
    W4_W3 = exp(-E*C / Combat_L_D);
    
    %Final Cruise
    R = Cruise_Back * ft_NM;
    C = Cruise_SFC;
    V = V_Cruise;
    W5_W4 = exp(-R*C/(V*Cruise_L_D));
        
    %Loiter
    E = Loiter_Time / 60;
    C = Loiter_SFC;
    W6_W5 = exp(-E*C / Loiter_L_D);
    
    %% Determine the Fuel Fraction
    k = 0.05 + 0.01; %Coefficent of trapped and reserve fuel, given in the lecture slides
    Wf_W0 = (1 + k)*(1 - W7_W6 * W6_W5 * W5_W4 * W4_W3 * W3_W2 * W2_W1 * W1_W0);
    
    for Carrier_Penalty = 0.031
        W0 = 50000; % Initial guess
        W0i = 0;    
        W0_history = W0; % Array to store convergence history
        iter = 0;
        
        while abs(W0 - W0i) > 0.1
            W0i = W0; 
            iter = iter + 1;
           
            % Determine Empty Weight Fraction
            We_W0 = (A + B*(W0^C1)*(AR^C2)*(Thrust_Weight^C3)*(Wing_loading^C4)*(M_max^C5)*Kvs) + Carrier_Penalty;
            
            % Re-Determine the total weight
            W0 = (W_crew + W_payload) / (1 - Wf_W0 - We_W0);
            W0_history(iter) = W0;
        end
    end 
    u = symunit;
    mass_estimate = ul(W0 * u.lbm);
end