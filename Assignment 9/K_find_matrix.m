function [K] = K_find_matrix(Mb,AR,SWP_w, t_c_w, W, hb, S)
    % Mb = mach number
    % hb must be unitless
    %K Summary of this function goes here
    %   Detailed explanation goes here
    M_DW_peak = 1.25;         % Mach at peak CDW
    KA = 0.95; %supercritical airfoil
    
    [~, ab, ~, rhob] = atmosisa(hb);
    Vb = Mb .* ab;
    qb = 0.5 * rhob * Vb.^2;
    
    %M thresholds
    C_L = W ./ (qb*S);
    
    M_DD = KA/cos(SWP_w) - t_c_w/(cos(SWP_w)^2) - C_L ./ (10 * (cos(SWP_w)^3));
    M_crit = M_DD - 0.08;
    %e
    e = 4.61 * (1 - 0.045*AR^0.68) * (cos(SWP_w)^0.15) - 3.1; %taken from a4
    
    
    % ---- Required CL at this Mach for level flight ----
    K_sub_thresh = 1 / (pi * AR * e);
    Msq_minus_1 = max(Mb.^2 - 1, 1e-9);
    Msqpk_minus_1 = max(M_DW_peak^2 - 1, 1e-9);
    K_sup_thresh = AR * Msqpk_minus_1 * cos(SWP_w) / (4 * AR * sqrt(Msqpk_minus_1) - 2);
    % ---- Wake drag + K in regions ----
    supersonicR = Mb>=M_DW_peak;
    transsonicR = Mb<M_DW_peak & Mb >= M_crit;
    subsonicR = Mb < M_crit;

    K(supersonicR) = AR .* Msq_minus_1(supersonicR) * cos(SWP_w) / (4 * AR * sqrt(Msq_minus_1(supersonicR)) - 2);

    x = (Mb(transsonicR) - M_crit(transsonicR)) ./ (M_DW_peak - M_crit(transsonicR));
    x = max(0, min(1, x));
    w = x.^2 .* (3 - 2.*x);  % smoothstep
    K(transsonicR) = (1-w)*K_sub_thresh + w*K_sup_thresh; 

    K(subsonicR) = K_sub_thresh;

end