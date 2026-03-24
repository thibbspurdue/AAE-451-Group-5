function [M_manuver] = V_n(n_max, n_min, W_S, C_L_max, C_L_min, C_L_a, c_bar, M_cruise, M_max)
%V_N Summary of this function goes here
%   Detailed explanation goes here

%As the C_L_min is for the negative loads, ensure it is negative
C_L_min =  - abs(C_L_min);

%Plotting
figure;
hold on;
grid on;


%plotting iteration items
c = ["b" "r" "w" "k"];
h = [15000 10000 5000 0];
gusts = 0.3048 * [-50 -25 25 50];

c = flip(c); h = flip(h);

%Plot the gust lines first
%Plot the gust lines
[~, a, ~, rho] = atmosisa(0);
g = 9.81;
mu_g = 2 * W_S / rho / c_bar / C_L_a / g;
K_g = 0.88 * mu_g / (5.3 + mu_g);

    %plotting using linspace 0 - Max mach
Ms = linspace(0, M_max, 100); Vs = Ms * a;


for vgu = gusts
    ns = 1 + (K_g * vgu * C_L_a / W_S) * Vs;
    plot(Ms, ns, '--', 'Color', 'c', 'HandleVisibility', 'off')
end

n_cruise_gusts_50 = 1 + (K_g * gusts([1,4]) * C_L_a / W_S) * M_cruise * a;
n_cruise_gusts_25 = 1 + (K_g * gusts([2,3]) * C_L_a / W_S) * M_max * a;
n_cruise_gusts = [n_cruise_gusts_50(1) n_cruise_gusts_25 n_cruise_gusts_50(2)];

M_gusts_corner_50 = ([n_min n_max] - 1) ./ (K_g * gusts([1,4]) * C_L_a / W_S) ./ a;

%Plotting the envelopes
for i = 1:4
    %Extract atmospheric data
    [~, a, ~, rho] = atmosisa(h(i));
    %Plotting everything with n as the independent variable

    %plotting positive stall line
    n_stall_p = linspace(1, n_max, 100);

    V_stall_p = sqrt( n_stall_p * 2 * W_S / (rho * C_L_max) );
    M_stall_p = V_stall_p / a;

        %crop
    M_stall_p = M_stall_p(M_stall_p < M_max);
    n_stall_p = n_stall_p(M_stall_p < M_max);

    %plotting negative stall line
    n_stall_n = linspace(-1, n_min, 100);

    V_stall_n = sqrt( n_stall_n * 2 * W_S / (rho * C_L_min) );
    M_stall_n = V_stall_n / a;

    %Plotting the filled envelope for sea level
    
    

    if(h(i) == 0)
        %Add in the gust lines
        n_min_gust_50 = min(n_min, n_cruise_gusts(1));
        n_min_gust_25 = min(n_min, n_cruise_gusts(2));
        n_max_gust_25 = max(n_max, n_cruise_gusts(3));
        n_max_gust_50 = max(n_max, n_cruise_gusts(4));

        %add in gust corners
        M_gusts_corner_50_n = min(M_gusts_corner_50(1), M_cruise);
        M_gusts_corner_50_p = min(M_gusts_corner_50(2), M_cruise);

        M = [M_stall_p(1) M_stall_p M_gusts_corner_50_p M_cruise M_max M_max M_cruise M_gusts_corner_50_n flip(M_stall_n) M_stall_n(1) M_stall_p(1)];
        n = [0 n_stall_p n_max n_max_gust_50 n_max_gust_25 n_min_gust_25 n_min_gust_50 n_min flip(n_stall_n) 0 0];

        %Output manuver velocity
        M_manuver = M_stall_p(end);

        fill(M, n, 'k', 'FaceAlpha',0.3, 'HandleVisibility', 'off');
        plot(M, n, 'Color', c(i), 'LineWidth', 3)
    else
        M = [M_stall_p(1) M_stall_p M_max M_max flip(M_stall_n) M_stall_n(1) M_stall_p(1)];
        n = [0 n_stall_p n_max n_min flip(n_stall_n) 0 0];

        plot(M, n, '--','Color', c(i))
    end

end

%Constant lines
yline(n_max, 'm')
yline(n_min, '--', 'Color', 'm')
xline(M_cruise, 'y')
xline(M_max, 'b')

%Finish Plotting
plot(0, 1, '--', 'Color', 'c')
lgd = legend("Sea Level Envelope", ...
       "5,000 m Limits", ...
       "10,000 m Limits", ...
       "15,000 m Limits", ...
       "Structural Limit (+)", ...
       "Structural Limit (-)", ...
       "Cruise Mach", ...
       "Max Mach", ...
       "Gusts" + newline + "50,25,-25,-50 ft/s", ...
       'Location', 'northwest');
lgd.Color = [0.7 0.7 0.7];
xlabel("Mach Number (M)")
ylabel("Load Factor (n)")



%Calculate good limits
x_max = ceil(M_max * 1.1);
y_min = - 5 * ceil((- n_min * 1.1)/5);
y_max = 5 * ceil((n_max * 1.1)/5);

xlim([0 x_max]); ylim([y_min y_max]);

end

