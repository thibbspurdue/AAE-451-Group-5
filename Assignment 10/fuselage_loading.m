%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSIGNMENT 10 - PART 2 FUSELAGE LOADING
% Input: 
% W_am =    Fuselage mass distributed array (matrix)
%           Double-row matrix with format such as: [location(m) Mass(kg)]'
% L_ps =    Lift point locations
%           Double-row matrix with format such as: [location(m) Lift(N)]'
% M_ps =    Point mass locations
%           Double-row matrix with format such as: [location(m) Mass(kg)]'
% aoa = angle of attack (arbitrary, might not be necessary)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fuselage_loading(W_am, x_acs, M_ps, c_r)
    %convention with negative lift i think
    %% Base setup
    n_des = 200;
    x_des = linspace(0,ul(c_r),n_des);
    x_old = W_am(1,:);
    x_cg = x_acs(1); %set x_cg=x_ac
    
    %% Mass - > Force Conversions
    %placing them all in one place to keep good track of it
    W_am(2,:) = W_am(2,:) * 9.81; M_ps(2,:) = M_ps(2,:) * 9.81;

    %% Weight setup
    %W_am(2,:)
    %W_smooth = interp1(W_am(2,:), x_old, x_des, 'spline')
    W_smooth = interp1(W_am(1,:), W_am(2,:), x_des, 'spline');
    
    % Check mass conservation
    fuse_original = trapz(x_old, W_am(2,:));
    fuse_smooth = trapz(x_des, W_smooth);
    W_smooth = W_smooth .* (fuse_original/fuse_smooth);

    %% Use x_ac, x_act and the weights, etc to calculate the lifts
    x_ac = x_acs(1); x_act = x_acs(2);
    %total weights and moment to balance
    W = fuse_original + sum(M_ps(2,:));

    M_dist = trapz(x_des, W_smooth .* (x_des - x_ac));
    M_point = sum(M_ps(2,:) .* (M_ps(1,:) - x_ac));
    M = M_dist + M_point;

    %use lin alj to solve for appropriate L
    A = [1, 1;x_ac, x_act];b = [-W;-M];

    L_ps = A \ b;   % solves for [Lw; Lt]
    L_ps = [x_ac x_act; L_ps(1) L_ps(2)];
    % %% Concatonate mass points
    % %since this is W', need to scale the points by x_step
    % L_ps(2,:) = L_ps(2,:) / (x_des(2)); M_ps(2,:) = M_ps(2,:) / (x_des(2));
    % 
    % %iterate
    % for i_L = 1:length(L_ps)
    %     index = find(L_ps(1,i_L)>x_des,1,"Last") + 1;
    %     W_smooth(index) = W_smooth(index) + L_ps(2,i_L);
    % end
    % for i_M = 1:length(M_ps)
    %     index = find(M_ps(1,i_M)>x_des,1,"Last") + 1;
    %     W_smooth(index) = W_smooth(index) + M_ps(2,i_M);
    % end
    % W_smooth = - W_smooth;
    % figure;
    % plot(W_smooth)
    % sum(W_smooth)
    % 
    % %% Numeric integration
    % %V = cumtrapz(W_smooth, x_des);
    % %BM = cumtrapz(W_smooth, x_des);
    % V = cumtrapz(x_des, W_smooth);
    % BM = cumtrapz(x_des, V);

    %% Properly define the jump points
    V = cumtrapz(x_des, W_smooth);

    % Add point loads as shear jumps
    for i = 1:size(L_ps,2)
        V(x_des >= L_ps(1,i)) = V(x_des >= L_ps(1,i)) + L_ps(2,i);
    end
    
    for i = 1:size(M_ps,2)
        V(x_des >= M_ps(1,i)) = V(x_des >= M_ps(1,i)) + M_ps(2,i);
    end
    
    BM = cumtrapz(x_des, V);
    
    %spoof if we must
    % [~, i_cg] = min(abs(x_des - x_cg));
    % BM = BM - BM(i_cg);
    % BM(i_cg)

    %% Plotting
    RGB = orderedcolors("gem");

    figure()
    subplot(2,1,1)
    title('Fuselage Loading')
    subtitle("Assignment 10 part (2)")
    plot(x_des, V, 'LineWidth',2, 'Color',RGB(1,:))
    grid on
    grid minor
    ylabel("Shear force in N")

    subplot(2,1,2)
    plot(x_des, BM, 'Linewidth',2,'Color',RGB(2,:))
    grid on
    grid minor
    ylabel("Bending Moment (Nm)")
    xlabel("Distance along the fuselage in m")
end