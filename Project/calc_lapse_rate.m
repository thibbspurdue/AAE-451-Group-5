function alpha = calc_lapse_rate(altitude, mach_number, throttle_ratio, engine_configuration)
% LAPSE_RATE Returns engine thrust lapse given altitude (m), Mach number,
% throttle ratio, and engine type (configuration and engagement of
% afterburner)
%   Implements empirically-fitted installed thrust lapse curves from
%   Mattingly textbook, see section 2.3.2 (Propulsion) and appendix D.
%   Accepts scalar and vector inputs, and handles vector altitude/Mach
%   number inputs with scalar throttle ratio and engine configuration
%   inputs.
    arguments
        altitude
        mach_number
        throttle_ratio
        engine_configuration {mustBeInteger, mustBeInRange(engine_configuration, 1, 6)}
    end

    altitude = ul(altitude);
    assert(length(altitude) == length(mach_number), 'Invalid altitude/Mach number inputs')

    % Convert possibly scalar inputs into arrays
    if (~isscalar(altitude) && isscalar(throttle_ratio))
        throttle_ratio = ones(size(altitude)) * throttle_ratio;
    end
    if (~isscalar(altitude) && isscalar(engine_configuration))
        engine_configuration = ones(size(altitude)) * engine_configuration;
    end

    gamma = 1.4; % air heat capacity ratio, assumed constant, ul
    alpha = zeros(length(altitude));
    for i = 1:length(altitude)
        theta_0 = Atm.temp(altitude) / Atm.temp(0) * (1 + ((gamma - 1) / 2) * mach_number^2);
        delta_0 = Atm.pressure(altitude) / Atm.pressure(0) * (1 + ((gamma - 1) / 2) * mach_number^2)^(gamma / (gamma - 1));

        % M_0_break = sqrt(2 ./ (gamma - 1) .* (theta_0_break - 1)); % Mach # ASL at which theta break is reached, Mattingly eq. D.7
        switch engine_configuration(i)
            case 1 % High bypass ratio turbofan, M_0 < 0.9
                if theta_0(i) <= throttle_ratio(i)
                    alpha(i) = delta_0(i) * (1 - 0.49 * sqrt(mach_number(i)));
                else
                    alpha(i) = delta_0(i) * (1 - 0.49 * sqrt(mach_number(i)) - (3 * (theta_0(i) - throttle_ratio(i))) / (1.5 + mach_number(i)));
                end
            case 2 % Low bypass ratio, mixed flow turbofan, wet/maximum thrust
                if theta_0(i) <= throttle_ratio(i)
                    alpha(i) = delta_0(i);
                else
                    alpha(i) = delta_0(i) * (1 - 3.5 * (theta_0(i) - throttle_ratio(i)) / theta_0(i));
                end
            case 3 % Low bypass ratio, mixed flow turbofan, dry/military thrust
                if theta_0(i) <= throttle_ratio(i)
                    alpha(i) = 0.6 * delta_0(i);
                else
                    alpha(i) = 0.6 * delta_0(i) * (1 - 3.5 * (theta_0(i) - throttle_ratio(i)) / theta_0(i));
                end
            case 4 % Turbojet, wet/maximum thrust
                if theta_0(i) <= throttle_ratio(i)
                    alpha(i) = delta_0(i) * (1 - 0.3 * (theta_0(i) - 1) - 0.1 * sqrt(mach_number(i)));
                else
                    alpha(i) = delta_0(i) * (1 - 0.3 * (theta_0(i) - 1) - 0.1 * sqrt(mach_number(i)) - (1.5 * (theta_0(i) - throttle_ratio(i)) / theta_0(i)));
                end
            case 5 % Turbojet, dry/military thrust
                if theta_0(i) <= throttle_ratio(i)
                    alpha(i) = 0.8 * delta_0(i) * (1 - 0.16 * sqrt(mach_number(i)));
                else
                    alpha(i) = 0.8 * delta_0(i) * (1 - 0.16 * sqrt(mach_number(i)) - (24 * (theta_0(i) - throttle_ratio(i)) / (theta_0(i) * (9 + mach_number(i)))));
                end
            case 6 % Turboprop
                if mach_number <= 0.1
                    alpha(i) = delta_0(i);
                elseif theta_0(i) <= throttle_ratio(i)
                        alpha(i) = delta_0(i) * (1 - 0.96 * (mach_number(i) - 1)^(1/4));
                else
                    alpha(i) = delta_0(i) * (1 - 0.96 * (mach_number(i) - 1)^(1/4) - (3 * (theta_0(i) - throttle_ratio(i)) / (8.13 * (mach_number(i) - 0.1))));
                end
        end
    end
end

