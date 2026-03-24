function [] = Parameter_Import(spreadsheet, aircraft, airfoil)
%PARAMETER_IMPORT will import and properly format the parameters from the
%parameters file established in the onedrive. single source of truth on
%variable initialization

%spreadsheet variable has the .xlsx
%aircraft = 'Blend';%if is not working remove the space

% Unit setup
u = symunit; % Initialise symbolic units object

function output = ul(input)
    output = double(separateUnits(input));
end

%% Variable Definition
% Pulling parameters
T = readtable(spreadsheet,'sheet',aircraft,'Range','1:2');
T2 = readtable(spreadsheet,'Sheet',airfoil,'Range','1:2');
Tsum = [T(1,:) T2(1,:)];
fields = Tsum.Properties.VariableNames;

% Pulling units
unitT = [readcell(spreadsheet,'sheet',aircraft,'Range','3:3') readcell(spreadsheet,'Sheet',airfoil,'Range','3:3')];
unitMap = dictionary(...
    "m",   u.m, ... % length
    "m2",  u.m^2, ... % area  
    "r",   u.rad, ...   % angle
    "kg",  u.kg, ...    % mass/weight?
    "i",   1/u.rad, ... % inverse angle
    "u", 1);    % unitless
units = unitMap(string(unitT));
% Concatonating & assigning variables
data = vpa(table2array(Tsum)) .* units;
x = cell2struct(num2cell(data), fields,2);

for i = 1:numel(fields)
    assignin('base', fields{i}, x.(fields{i}));
end

clear T T2 Tsum x data i unitT units unitMap fields
end

