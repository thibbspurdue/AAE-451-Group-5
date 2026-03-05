classdef Engine < Component
    %ENGINE Class organising internal engine properties for initial sizing
    %   Detailed explanation goes here
    properties
        intermediate_SFC = 0  % Maximum dry SFC
        wet_SFC = 0           % Maximum SFC with afterburner
        loiter_SFC = 0        % Lowest SFC to cruise
        minimum_thrust = 0    % Minimum thrust per engine
        max_thrust = 0        % Maximum thrust per engine
        engine_type {mustBeMember(engine_type, [ ...
                    "High-bypass turbofan" ...
                    "Low-bypass turbofan, wet thrust" ...
                    "Low-bypass turbofan, dry thrust" ...
                    "Turbojet, wet thrust" ...
                    "Turbojet, dry thrust" ...
                    "Turboprop"])}
    end

    methods
        function obj = Engine(args)
            %ENGINE Construct an engine instance using provided arguments.
            arguments
                args.?Engine
            end
            if nargin > 0
                for field = fieldnames(args)
                    obj.(field) = args.(ul(field));
                end
            end


        end

        function SFC = interp_SFC = 

        function frac = cruise_frac(obj, range, velocity, lift_drag_ratio)
            arguments
                obj Engine
                range
                velocity
                lift_drag_ratio
            end
            frac = exp(ul(-range * obj.intermediate_SFC / velocity / lift_drag_ratio));
        end

        function frac = loiter_frac(obj, endurance, lift_drag_ratio)
            arguments
                obj Engine
                endurance
                lift_drag_ratio
            end
            frac = exp(ul(-endurance * obj.loiter_SFC / lift_drag_ratio));
        end

        function frac = combat_frac(obj, endurance, lift_drag_ratio)
            arguments
                obj Engine
                endurance
                lift_drag_ratio
            end
            frac = obj.loiter_frac(endurance, lift_drag_ratio);
        end
        
        function thrust = calc_thrust(obj, )
    end
end