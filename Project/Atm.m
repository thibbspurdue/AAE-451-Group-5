classdef Atm
    % ATM Wrapper class with static methods to access MATLAB atmosisa()
    % output components individually in a more accessible format. Converts
    % MATLAB symbolic units, otherwise assumes altitudes are in meters.
    methods (Static)
        function T = temp(altitude)
            tempunits = symunit;
            if has_units(altitude)
                altitude = ul(unitConvert(altitude, tempunits.m));
            end
            T = atmosisa(altitude);
        end

        function a = sonic_speed(altitude)
            tempunits = symunit;
            if has_units(altitude)
                altitude = ul(unitConvert(altitude, tempunits.m));
            end
            [~, a] = atmosisa(altitude);
        end

        function P = pressure(altitude)
            tempunits = symunit;
            if has_units(altitude)
                altitude = ul(unitConvert(altitude, tempunits.m));
            end
            [~, ~, P] = atmosisa(altitude);
        end

        function rho = density(altitude)
            tempunits = symunit;
            if has_units(altitude)
                altitude = ul(unitConvert(altitude, tempunits.m));
            end
            [~, ~, ~, rho] = atmosisa(altitude);
        end

        function nu = viscosity_kin(altitude)
            tempunits = symunit;
            if has_units(altitude)
                altitude = ul(unitConvert(altitude, tempunits.m));
            end
            [~, ~, ~, ~, nu] = atmosisa(altitude);
        end

        function mu = viscosity_dyn(altitude)
            tempunits = symunit;
            if has_units(altitude)
                altitude = ul(unitConvert(altitude, tempunits.m));
            end
            [~, ~, ~, ~, ~, mu] = atmosisa(altitude);
        end
    end
end