function [] = Flight_envelope(AR, SWP_w, S, t_c_w, W, T_SL, C_D0, C_D0L, C_L_max)
%FLIGHT_ENVELOPE Summary of this function goes here
%T_SL is the thrust available at sea level
%u = symunit;
function output = ul(input)
    output = double(separateUnits(input));
end

%removing the units for all inputs
%MAKE SURE THE UNITS ARE INPUT IN BASIC SI
SWP_w = ul(SWP_w);
S = ul(S);
W = ul(W * 9.81);
T_SL = ul(T_SL);


rho_SL = 1.225;
nn = 50;

M = linspace(0.1, 2.5, nn);

%h = linspace(0, 60000, nn) * u.ft;
%h = unitConvert(h, u.m);
%h = linspace(0, 18288, nn);
h = linspace(0, 20000, nn);
%The multiple contours graph

N = [1 2 3 4 5 6 7 7.5];
%N = 1;
figure;
hold on;
colors = ['r', 'g', 'b', 'c', 'm', 'y', 'r', 'k'];   % assign diff colors

k = 1;
for n = N
    Psss(n, C_D0, colors(k));
    %contour(M, h, Ps', [0 0], 'Color', colors(k,:));
    k = k + 1;
end
legend('n = 1','n = 2','n = 3','n = 4','n = 5','n = 6','n = 7','n = 7.5')
grid on;
xlabel("Mach number")
ylabel("Altitude (m)")
%legend('n = 1', 'n = 2', 'n = 3', 'n = 4', 'n = 5', 'n = 6', 'n = 7', 'n = 7.5')
title('Sustained Flight Envelopes P_s = 0')

%Clean versus unclean graphs
figure;
Psss(1, C_D0, 'green');
grid on;
%contour(M, h, Psss(n, C_D0)', [0,0], 'green');
hold on;
Psss(1, C_D0L, 'red');
%contour(M, h, Psss(n, C_D0L)', [0,0], 'red');
legend("Clean", "Loaded")
xlabel("Mach number")
ylabel("Altitude (ft)")
title("Impact of External Stores on 1g flight envelope (Ps = 0)")

%For a value of n, this generates the contour

function Ps = Psss(n, cd0, c)
    Ps = zeros(nn); %Ps(M,h)
    
    
    for i = 1:nn
        for j = 1:nn
            [~, a, ~, rho] = atmosisa(h(j));
            V = M(i) * a;
            q = 0.5 * rho * V^2;

            %Stall line stuff
            C_L = n*W / (q*S);
            if C_L > C_L_max
                Ps(i,j) = NaN;
                continue
            end
    
            %Get K and all that
            K = K_find(M(i),AR,SWP_w, t_c_w, n*W, h(j), S);
    
            %Thrust using thrust limit
            T = T_SL * (rho / rho_SL)^0.7 * (1 - 0.35*M(i));
    
            %Drag using definition of it
            D = cd0*q*S + n^2 * (K/q) * (W^2 / S);
    
            Ps(i, j) = (T - D);
        end
    end
    
    Mstall = zeros(size(h));

    for j = 1:length(h)
        [~, a, ~, rho] = atmosisa(h(j));
        Vstall = sqrt(2*n*W / (rho*S*C_L_max));
        Mstall(j) = Vstall / a;
    end
    
    %plot(Mstall, h, 'Color', c);
    %[~, Ps] = contour(M, h, Ps', [0 0], 'Color', c);
    if(n == 1)
        plot(Mstall, h* 3.2808399, 'Color', c, 'HandleVisibility', 'off');
        contour(M, h* 3.2808399, Ps', [0 0], 'Color', c);
    else
        % Get Ps = 0 contour
        C = contourc(M, h, Ps', [0 0]);
    
        M_ps = C(1,2:end);
        h_ps = C(2,2:end);
        %Remove error values
        mask = M_ps >= 0.1;
    
        M_ps = M_ps(mask);
        h_ps = h_ps(mask);
        % Sort contour by mach
        %[M_ps, order] = sort(M_ps);
        %h_ps = h_ps(order);
    
        %find the intersection point
        %[i_stall, i_ps] = find(abs(M_ps(:)' - Mstall(:)) == min(abs(M_ps(:)' - Mstall(:))), 1);
        %i_stall = i_stall - n;
        M_ppps = h_ps*0;
        for j = 1:length(h_ps)
            [~, a, ~, rho] = atmosisa(h_ps(j));
            Vstall = sqrt(2*n*W / (rho*S*C_L_max));
            M_ppps(j) = Vstall / a;
        end
        [i_ps, ~] = find(abs(M_ps(:) - M_ppps(:)) == min(abs(M_ps(:) - M_ppps(:))), 1);

        %Machs = [Mstall(1:i_stall), M_ps(i_ps:end)];
        %Heights = [h(1:i_stall), h_ps(i_ps:end)];

        h_stall = linspace(0, h_ps(i_ps), nn);
        M_stall = 0*h_stall;
        for j = 1:length(h_stall)
            [~, a, ~, rho] = atmosisa(h_stall(j));
            Vstall = sqrt(2*n*W / (rho*S*C_L_max));
            M_stall(j) = Vstall / a;
        end
        Machs = [M_stall, M_ps(i_ps:end)];
        Heights = [h_stall, h_ps(i_ps:end)];
        %Machs = [Mstall(1:i_stall), M_ps(i_ps:end)];
        %Heights = [h(1:i_stall), h_ps(i_ps:end)];
        %Machs = [M_stall, M_ps];
        %Heights = [h_stall, h_ps];
        %Machs = [M_ps, flip(M_stall)];
        %Heights = [h_ps, flip(h_stall)];
        %Machs = [M_ps(i_ps:end), flip(Mstall(1:i_stall))];
        %Heights = [h_ps(i_ps:end), flip(h(1:i_stall))];
        % Find closest intersection between the curves
        % D = hypot(M_ps(:) - M_stall(:)', h_ps(:) - h_stall(:)');  % distance matrix
        % [~, idx] = min(D(:));
        % [i_ps, i_stall] = ind2sub(size(D), idx);
        %i_ps = i_ps - 1;
        %i_stall = i_stall - 1;
        % Trim curves at intersection
        % M_ps_trim = M_ps(1:i_ps);
        % h_ps_trim = h_ps(1:i_ps);
        % 
        % M_stall_trim = M_stall(1:i_stall);
        % h_stall_trim = h_stall(1:i_stall);
        % 
        % Create envelope vectors
        %Machs   = [M_ps_trim, fliplr(M_stall_trim)];
        %Heights = [h_ps_trim, fliplr(h_stall_trim)];
        
        Heights = Heights * 3.2808399; %make it into feet
        plot(Machs, Heights, 'Color', c)
    end
    
end

%Makes K
function [K] = K_find(Mb,AR,SWP_w, t_c_w, Wb, hb, S)
    %K Summary of this function goes here
    %   Detailed explanation goes here
    M_DW_peak = 1.25;         % Mach at peak CDW
    KA = 0.95; %supercritical airfoil
    
    [~, ab, ~, rhob] = atmosisa(hb);
    Vb = Mb * ab;
    qb = 0.5 * rhob * Vb^2;
    
    %M thresholds
    C_L = Wb / (qb*S);
    
    M_DD = KA/cos(SWP_w) - t_c_w/(cos(SWP_w)^2) - C_L / (10 * (cos(SWP_w)^3));
    M_crit = M_DD - 0.08;
    %e
    e = 4.61 * (1 - 0.045*AR^0.68) * (cos(SWP_w)^0.15) - 3.1; %taken from a4
    
    
    % ---- Required CL at this Mach for level flight ----
    K_sub_thresh = 1 / (pi * AR * e);
    Msq_minus_1 = max(Mb^2 - 1, 1e-9);
    Msqpk_minus_1 = max(M_DW_peak^2 - 1, 1e-9);
    K_sup_thresh = AR * Msqpk_minus_1 * cos(SWP_w) / (4 * AR * sqrt(Msqpk_minus_1) - 2);
    % ---- Wake drag + K in regions ----
    if (Mb >= M_crit)
        if (Mb >= M_DW_peak)
            %% Supersonic Region (decay; continuous at M_DW_peak)
            K = AR * Msq_minus_1 * cos(SWP_w) / (4 * AR * sqrt(Msq_minus_1) - 2);
        else
            %% Transonic Region (Gundlach cubic ramp to the peak)
            % Smooth blend 
            x = (Mb - M_crit) / (M_DW_peak - M_crit);
            x = max(0, min(1, x));
            w = x^2 * (3 - 2*x);  % smoothstep
            K = (1-w)*K_sub_thresh + w*K_sup_thresh;
        end
    else
        %% Subsonic Region
        K = K_sub_thresh;
    end

end
end

