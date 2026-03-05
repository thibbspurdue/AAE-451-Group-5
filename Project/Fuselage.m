classdef Fuselage < Component
    % FUSELAGE Fuselage component class used for drag analysis.
    % Subclass of Component class.
    properties
        length = 0
        width = 0
    end

    properties (Dependent)
        fineness_ratio
    end

    properties (Access = private)
        fuselage_types = [ ...
            "Hotdog, Raymer eq. 12.31" ...
            "Nicolai eq. xx.xx" ...
            "Nicolai eq. xx.xx"];
    end
    
    methods (Access = public)
        function obj = Fuselage(fuselage_type, args)
            % FUSELAGE Construct a Fuselage object using two dimensions and
            % the wetted area modelling method. The hotdog method is useful
            % for early estimates but should be replaced with more accurate
            % wetted area models.
            arguments
                fuselage_type (1,1) string {mustBeMember(fuselage_type, [ ...
                    "Hotdog, Raymer eq. 12.31" ...
                    "Nicolai eq. xx.xx" ...
                    "Nicolai eq. xx.xx"])}
                args.?Fuselage
            end

            if nargin > 0
                for field = fieldnames(args)
                    obj.(field) = args.(ul(field));
                end
            end
            switch fuselage_type
                case "Hotdog, Raymer eq. 12.31"
                     obj.wetted_area = pi * obj.width * obj.length * (1 - 2 * obj.width / obj.length)^(2/3) * (1 + (obj.width / obj.length)^2);
            end
        end

        function output = calc_cd0(obj, altitude, ref_wing_area, airspeed)
            % CD0 Calculates and returns parasitic drag of component
            arguments
                obj
                altitude {mustBePositive}
                ref_wing_area {mustBePositive}
                airspeed.mach_number = 0
                airspeed.velocity = 0
            end

            altitude = ul(altitude);
            ref_wing_area = ul(ref_wing_area);
            airspeed.velocity = ul(airspeed.velocity);
            
            if airspeed.velocity == 0
                if airspeed.mach_number == 0
                    error("Mach number or velocity required")
                else
                    airspeed.velocity = Atm.mach_to_v(altitude, airspeed.mach_number);
                end
            else
                if abs(mach_number - Atm.v_to_mach(altitude, airspeed.velocity)) / airspeed.mach_number > 0.01
                    error("Conflicting Mach number and velocity provided (> 1% difference)\n")
                end
            end

            form_factor = obj.calc_form_factor();

            output = calc_cd0(obj, altitude, ref_wing_area, form_factor, obj.length, "velocity", airspeed.velocity);
        end

        function form_factor = calc_form_factor(obj)
            form_factor = 0.9 + 5 / (ul(obj.length / obj.width)^1.5) + ul(obj.length / obj.width) / 400; % From Raymer eq. 12.31
        end

        function obj = set_wetted_area(obj, wetted_area)
            obj.wetted_area = ul(wetted_area);
        end
    end

    methods
        function fineness_ratio = get.fineness_ratio(obj)
            fineness_ratio = obj.length / obj.width;
        end
    end
end

