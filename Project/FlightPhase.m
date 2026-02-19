classdef FlightPhase
    % FLIGHTPHASE Defines a FlightPhase object containing information for
    % different flight phases.
    %   Takes in required altitude, load factor, engine configuration, and
    %   velocity information. Defaults to 0 acceleration and climb rate
    %   unless otherwise specified by name-value pairs at the end of the
    %   input arguments.
    
    properties (Constant)
        tempunits = symunit;
        g (1,1) double {mustBePositive} = 9.81 % gravitational acceleration
    end
    properties
        altitude (1,1)                     % altitude ASL, m
        air_density                        % (ρ) kg*m^-3
        sonic_speed                        % speed of sound, m/s

        velocity                           % airspeed, m/s
        mach_number (1,1)                  % ul
        C_D0                               % parasitic drag factor, ul
        K                                  % induced drag factor, ul
        dv_dt = 0                          % horizontal acceleration, m*s^-2
        dh_dt = 0                          % climb rate, m/s
        lapse_rate                         % (α) of engine, altitude-dependent
        load_factor                        % (β) weight fractions given in assignment
        throttle_ratio = 1.04              % (TR), assume 1.04 for now
        engine_config                      % see constructor below
    end
    
    methods
        function obj = FlightPhase(altitude, load_factor, engine_config, options)
            % FLIGHTPHASE Construct and initialise a FlightPhase object
            %   Currently assumes use of a low-bypass turbofan. Engine
            %   selection will be abstracted to a higher-level class (e.g.:
            %   'Aircraft' if implemented.

            arguments
                altitude (1,1)
                load_factor (1,1)
                engine_config (1,1) string {mustBeMember(engine_config, [ ...
                    "High-bypass turbofan" ...
                    "Low-bypass turbofan, wet thrust" ...
                    "Low-bypass turbofan, dry thrust" ...
                    "Turbojet, wet thrust" ...
                    "Turbojet, dry thrust" ...
                    "Turboprop"])}
                options.?FlightPhase
            end

            if nargin == 0
                return
            end

            if has_units(altitude)
                altitude = ul(unitConvert(altitude, obj.tempunits.m));
            end
            obj.altitude = altitude;
            [~, obj.sonic_speed, ~, obj.air_density] = atmosisa(obj.altitude);
            obj.load_factor = load_factor;

            assert(isfield(options, "velocity") || isfield(options, "mach_number"), "Airspeed is required. Please supply Mach # or velocity.")
            if isfield(options, "mach_number") % Default to Mach number definition
                obj.mach_number = options.mach_number;
                obj.velocity = obj.mach_number * obj.sonic_speed;
            else
                if has_units(options.velocity)
                    options.velocity = ul(options.velocity);
                end
                obj.velocity = options.velocity;
                obj.mach_number = obj.velocity / obj.sonic_speed;
            end

            % Cannot simply set(obj, options) since additional validation is
            % applied to name-value arguments
            if isfield(options, "dv_dt")
                if has_units(options.dv_dt)
                    options.dv_dt = ul(unitConvert(options.dv_dt, obj.tempunits.m / obj.tempunits.s^2));
                end
                obj.dv_dt = options.dv_dt;
            end
            if isfield(options, "dh_dt")
                if has_units(options.dh_dt)
                    options.dh_dt = ul(unitConvert(options.dh_dt, obj.tempunits.m / obj.tempunits.s));
                end
                obj.dh_dt = options.dh_dt;
            end
            
            % There has to be a better way to do this but I can't be
            % bothered to explore MATLAB's peculiarities at the moment
            switch(engine_config)
                case "High-bypass turbofan"
                    obj.engine_config = 1;
                case "Low-bypass turbofan, wet thrust"
                    obj.engine_config = 2;
                case "Low-bypass turbofan, dry thrust"
                    obj.engine_config = 3;
                case "Turbojet, wet thrust"
                    obj.engine_config = 4;
                case "Turbojet, dry thrust"
                    obj.engine_config = 5;
                case "Turboprop"
                    obj.engine_config = 6;
            end
        end
        
        function twr = twr(obj, wing_loading, C_D0, K)
            % TWR Calculates the thrust-weight ratio for a flight
            % phase given wing loading and drag components.
            arguments
                obj             % pass in data using FlightPhase object
                wing_loading    % can be an array
                C_D0            % parasitic drag component
                K               % induced drag component
            end
            
            obj.lapse_rate = calc_lapse_rate(obj.altitude, obj.mach_number, obj.throttle_ratio, obj.engine_config);

            q = 0.5 * obj.air_density * obj.velocity^2;
            C_L = wing_loading * obj.load_factor / q;
            twr = 0.5 * obj.air_density * obj.velocity^2 .* (C_D0 + K * C_L.^2) / obj.load_factor ./ wing_loading;
            twr = twr + obj.dh_dt / obj.velocity + obj.dv_dt / obj.g .* ones(size(twr));
            twr = (obj.load_factor / obj.lapse_rate) * twr;
        end

        function w_s = wing_loading(obj, C_L, K)
            % W_S Calculates the wing loading for a flight phase given
            % lift/drag components.
            arguments
                obj            % pass in data using FlightPhase object
                C_L            % lift coefficient
                K              % induced drag component (~1.1 from slide 19)
            end
            w_s = obj.air_density * C_L * obj.velocity^2 / (2 * obj.load_factor * K^2);
        end
    end
end