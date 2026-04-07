clc; clear; close all;

%general airplane inputs, integrate this with the general code later / if
%necessary
t_c = 0.15; %assuming worst case ig as it varies from 0.15 to 0.12

a_percent = 0.5 - 0.12; %percentage of wingbox as a funciton of chord

%stringer statistics
N_Stringers = 20;
hs = 15E-1; bs = 1E-1; ts = 1E-2;

syms m
%% =========================
% INPUTS
%% =========================

% Spanwise positions (your data)
y = [ ...
-8.58531 -8.52667 -8.40978 -8.23544 -8.00484 -7.71956 -7.38155 -6.99312 ...
-6.55692 -6.07592 -5.55343 -4.99299 -4.39845 -3.77386 -3.1235 -2.4518 ...
-1.76334 -1.06285 -0.35509 0.355091 1.062848 1.763344 2.451795 3.123498 ...
3.773864 4.398451 4.992992 5.553425 6.075924 6.556917 6.99312 7.381553 ...
7.719562 8.004839 8.235435 8.409775 8.526667 8.585313];

cl_dist = [ ...
0.070326 0.127674 0.185742 0.239388 0.286962 0.327856 0.362263 0.390336 ...
0.409172 0.413057 0.700246 0.811962 0.881804 0.937175 0.981975 1.016923 ...
1.041878 1.057163 1.077089 1.077089 1.057163 1.041878 1.016923 0.981975 ...
0.937175 0.881804 0.811962 0.700246 0.413057 0.409172 0.390336 0.362263 ...
0.327856 0.286962 0.239388 0.185742 0.127674 0.070326];

% Aircraft parameters
rho = 1.225;          % kg/m^3
V = 306.26;           % m/s
n = 8;              % load factor

% Delta wing geometry
b = max(y) - min(y);  % total span
c_root = 12;         % root chord (m)
c_t = 1; %tip chord (m)

% Material properties
k = 4;                % buckling coefficient

% Skin Material Properties
% https://www.matweb.com/search/datasheet.aspx?matguid=846785025831492884a7196649269af7
skin_density = 1310;        % Density in kg/m^3
skin_sig_t = 70.3E6;        % Tensile strength in Pa
skin_E = 3.38E9;            % Tensile Modulus in Pa
skin_sig_f = 190E6;         % Flexural strength in Pa
skin_E_f = 3.38E9;          % Flexural modulus in Pa
t_skin = 5E-3;

%poissons ratio below
v = 0.12; %not from datasheet from google search ai pulled result

%% =========================
% STEP 1: Chord distribution (delta wing)
%% =========================

y_abs = abs(y);
c_y = (c_root - c_t) * (1 - y_abs / (b/2)) + c_t;


%% =========================
% STEP 2: Lift per unit span
%% =========================

q = 0.5 * rho * V^2;

L_prime = q .* c_y .* cl_dist;
L_prime = n * L_prime;

%% =========================
% STEP 3: Sort & integrate loads
%% =========================

[y_sorted, idx] = sort(y_abs);
L_sorted = L_prime(idx);
c_sorted = c_y(idx);

% Shear force
V_shear = cumtrapz(flip(y_sorted), flip(L_sorted));
V_shear = flip(V_shear);

% Bending moment
M_bend = cumtrapz(flip(y_sorted), flip(V_shear));
M_bend = flip(M_bend);

%% =========================
% STEP 4: Section properties (approx)
%% =========================

% Assume wing box height proportional to chord
h = t_c * c_sorted;   % 12% thickness ratio

% Approximate moment of inertia (rectangular box)
I = (c_sorted .* h.^3) / 12;

%add the moment of inertia of the stringers for stiffening
%[I_stringer, A_stringer] = stringer_inertia(bs, hs, ts);
%I = I + N_Stringers*I_stringer;

%display out the area of the stringers
%fprintf("The area of each stringer is %0.7f m^2\n", A_stringer);

% Distance to outer fiber
z = h / 2;

% Bending stress
sigma = M_bend .* z ./ I;

%% =========================
% STEP 5: Rib spacing via skin buckling
%% =========================

rib_spacing = zeros(size(sigma));

for i = 1:length(sigma)
    sigma_applied = (1/3) * abs(sigma(i));
    
    if sigma_applied < 1e3
        rib_spacing(i) = 2.0;
        continue;
    end

    %page 319 buckling model:
    b = t_skin * sqrt((17.85 * 4 * pi^2 * skin_E) / sigma_applied / 12 / (1 - v^2));
    

    rib_spacing(i) = b; %plug back in at the end
    
    %ignore values that are too high
    if b > 2
        rib_spacing(i) = 2;
    end
end

%% =========================
% STEP 6: Plot results
%% =========================

figure;

subplot(4,1,1)
plot(y, c_y, 'LineWidth', 2);
xlabel('Spanwise position (m)');
ylabel('Chord (m)');
title('Delta Wing Chord Distribution');
grid on;

subplot(4,1,2)
plot(y_sorted, L_sorted, 'LineWidth', 2);
xlabel('Spanwise position (m)');
ylabel('Lift per unit span (N/m)');
title('Lift Distribution');
grid on;

subplot(4,1,3)
plot(y_sorted, M_bend, 'LineWidth', 2);
xlabel('Spanwise position (m)');
ylabel('Bending Moment (Nm)');
title('Bending Moment');
grid on;

subplot(4,1,4)
plot(y_sorted, rib_spacing, 'LineWidth', 2);
xlabel('Spanwise position (m)');
ylabel('Rib Spacing (m)');
title('Estimated Rib Spacing');
grid on;

%% =========================
% OUTPUT
%% =========================

fprintf('Average Rib Spacing: %.3f m\n', mean(rib_spacing));
fprintf('Minimum Rib Spacing: %.3f m\n', min(rib_spacing));


%% =========================
% Stringer moment of inertia
%% =========================
function [I_top, A] = stringer_inertia(bf, h, ts)
    % Ibeam stringer inertia
    % Inputs:
    % bf = flange width
    % tf = flange thickness
    % tw = web thickness
    % h  = total height
    %
    % Output:
    % I_top = moment of inertia about top edge
    
    % --- Area ---
    A = 2*(bf * ts) + (h - 2*ts) * ts;
    
    % --- Centroidal moment of inertia (strong axis) ---
    I_flange = 2 * ( ...
        (bf * ts^3)/12 + ...
        bf * ts * (h/2 - ts/2)^2 );
    
    I_web = (ts * (h - 2*ts)^3) / 12;
    
    I_x = I_flange + I_web;
    
    % --- Parallel axis theorem to shift to top fiber ---
    d = h / 2;
    I_top = I_x + A * d^2;

end