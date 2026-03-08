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
    end
end