%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assignment 10
% AAE 45100 Aircraft design
% Team 05
% Code overview:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Definition of V-n diagram parameters
n_max = 8;
n_min = -3;
M_cruise = 0.9;
M_max = 1.85;
C_L_min = -0.6;

W_S = 60 * 47.880258888889; %lbf/ft^2 to Pa
%% Unit stuff?
u = symunit;
function output = iul(input, unit, unit2)
    if nargin == 1  % Symbolic input, simple unit conversion
        output = double(separateUnits(unitConvert(input,'US')));
    elseif nargin == 2  % Symbolic input, complicated unit conversion
        output = double(separateUnits(unitConvert(input, unit)));
    else    % double input (undesired)
        output = double(separateUnits(unitConvert(input*unit, unit2)));
    end
end

function output = ul(input)
    output = double(separateUnits(input));
end

%% Parameters derivation
spreadsheet = 'Parameters_copy.xlsx';
aircraft = 'Sunfish';
airfoil = 'Airfoil';

Parameter_Import(spreadsheet, aircraft, airfoil);
[l_t, l_h, l_v, S_h, S_t] = Parameters_rebalance(l_t, l_v, x_ac, S_t, S_v);

%% V-n diagram
M_manuver = V_n(n_max, n_min, W_S, C_L_max, C_L_min, ul(C_L_a), ul(c_bar), M_cruise, M_max);

%% wingbox diagram
wingbox(b_w, c_r, c_t, W);
