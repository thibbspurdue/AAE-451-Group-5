function [] = Flight_envelope(AR, SWP_w, S, t_c_w, W, T_SL, C_D0, C_D0L)
%FLIGHT_ENVELOPE Summary of this function goes here
%T_SL is the thrust available at sea level
rho_SL = 1.225;
nn = 100;

M = linspace(0.1, 2.5, nn);

%h = linspace(0, 60000, nn) * u.ft;
%h = unitConvert(h, u.m);
h = linspace(0, 18288, nn);

%The multiple contours graph

N = [1 2 3 4 5 6 7 7.5];
figure;
hold on;
for n = N
    Ps = Psss(n, C_D0);
    contour(M, h, Ps.', [0 0]);
end
grid on;
legend('n = 1', 'n = 2', 'n = 3', 'n = 4', 'n = 5', 'n = 6', 'n = 7', 'n = 7.5')
title('Sustained Flight Envelopes P_s = 0')

%Clean versus unclean graphs
figure;
contour(M, h, Psss(n, C_D0));
hold on;
contour(M, h, Psss(n, C_D0L));
legend("Clean", "Loaded")
title("Impact of External Stores on 1g flight envelope (Ps = 0)")

%For a value of n, this generates the contour

function Ps = Psss(n, cd0)
    Ps = zeros(nn); %Ps(M,h)
    
    
    for i = 1:nn
        for j = 1:nn
            [~, a, ~, rho] = atmosisa(h(j));
            V = M(i) * a;
            q = 0.5 * rho * V^2;
    
            %Get K and all that
            K = K_find(M(i),AR,SWP_w, t_c_w, W, h(j), S);
    
            %Thrust using thrust limit
            T = T_SL * (rho / rho_SL) * (1 - 0.35 * M(i));
    
            %Drag using definition of it
            D = cd0*q*S + n^2 * (K/q) * (W^2 / S);
    
            Ps(i, j) = T - D;
        end
    end
end

%Makes K
function [K] = K_find(Mb,AR,SWP_w, t_c_w, W, hb, S)
    %K Summary of this function goes here
    %   Detailed explanation goes here
    M_DW_peak = 1.25;         % Mach at peak CDW
    KA = 0.95; %supercritical airfoil
    
    [~, ab, ~, rhob] = atmosisa(hb);
    Vb = Mb * ab;
    qb = 0.5 * rhob * Vb^2;
    
    %M thresholds
    C_L = W / (qb*S);
    
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

