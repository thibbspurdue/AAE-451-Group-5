%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSIGNMENT 10 - PART 3 WINGBOX LOADING
% Input: b_w c_r c_t S W
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wingbox(b_w, c_r, c_t, W)
    u = symunit;
    altitude = 0;
    g = 9.81 * u.m / u.s^2;
    density = Atm.density(altitude);    % Assume SL
    tR = ul(c_t/c_r);                   % Taper ratio
    L = ul(W * g); %1/2 * density * 
    b_w = ul(b_w);
    syms y real

    %% Schrenk approximation
    % Fundementals Aircraft Airship Design Vol1 page 545, 19.3 & 19.4
    L_trap = 2*L / (b_w * (1 + tR)) * (1 - 2.*y./b_w .* (1 - tR)); % Trapezoidal lift distribution
    L_elip = 4*L / (pi * b_w) * sqrt(1 - (2.*y./b_w).^2);            % Elliptical lift distribution

    %% Distribution function (symbolic)
    L_y = 1/2 .* (L_trap + L_elip); % Lift distribution function
    tau_y = int(L_y,y);             % Shear distribution function
    bm_y = int(tau_y,y);            % Bending distribution function
    
    n = 50;
    y_n = linspace(0,ul(b_w)/2,n);  % Numeric span distribution

    %% Distribution function (numeric)
    L_trap_n = 2*L / (b_w * (1 + tR)) .* (1 - 2.*y_n./b_w .* (1 - tR));
    L_elip_n = 4*L / (pi * b_w) * sqrt(1 - (2.*y_n./b_w).^2);
    L_n = 1/2 .* (L_trap_n + L_elip_n);

    tau_n = subs(tau_y,y,y_n);
    bm_n = subs(bm_y,y,y_n);

    %% Plot

    RGB = orderedcolors("gem");
    
    figure()
    subplot(3,1,1)
    plot(y_n,L_n,'Color',RGB(1,:),'LineWidth',2)
    grid on
    grid minor
    legend("Schrenk Lift distribution (N/m)")
    title("Wingbox Loading plot")
    subtitle("Assignment 10 part (3)")

    subplot(3,1,2)
    plot(y_n,flip(tau_n),'Color',RGB(2,:),'LineWidth',2)
    grid on
    grid minor
    legend("Shear force V (N)")

    subplot(3,1,3)
    plot(y_n,flip(bm_n),'Color',RGB(3,:),'LineWidth',2)
    grid on
    grid minor
    legend("Bending moment M (N-m)")
    xlabel("Spanwise Coordinate y (m)")
end