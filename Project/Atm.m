classdef Atm
    % ATM Wrapper class with static methods to access MATLAB atmosisa()
    % output components individually in a more accessible format. Converts
    % MATLAB symbolic units, otherwise assumes altitudes are in meters.
    methods (Static)
        function T = temp(altitude)
            T = atmosisa(ul(altitude));
        end

        function a = sonic_speed(altitude)
            [~, a] = atmosisa(ul(altitude));
        end

        function P = pressure(altitude)
            [~, ~, P] = atmosisa(ul(altitude));
        end

        function rho = density(altitude)
            [~, ~, ~, rho] = atmosisa(ul(altitude));
        end

        function nu = viscosity_kin(altitude)
            [~, ~, ~, ~, nu] = atmosisa(ul(altitude));
        end

        function mu = viscosity_dyn(altitude)
            [~, ~, ~, ~, ~, mu] = atmosisa(ul(altitude));
        end

        function velocity = mach_to_v(altitude, mach_number)
            velocity = ul(Atm.sonic_speed(ul(altitude))) * mach_number;
        end

        function mach_number = v_to_mach(altitude, velocity)
            mach_number = ul(velocity) / Atm.sonic_speed(ul(altitude));
        end
    end
end