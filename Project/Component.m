classdef Component
    % COMPONENT Generic component.
    % Common components such as wings, fuselages, nacelles, etc. should be
    % instantiated using respective subfunctions to ensure correct
    % attributes are defined.

    properties
        interference_factor = 1
        mass = 0
        wetted_area
    end

    methods
        function obj = Component(args)
            % COMPONENT Construct a generic Component object.
            arguments
                args.?Component
            end

            if nargin > 0
                for field = fieldnames(args)
                    obj.(field) = args.(ul(field));
                end
            end
        end % constructor

        function output = calc_cd0(obj, altitude, ref_wing_area, form_factor, characteristic_length, airspeed)
            % CALC_CD0 Calculates and returns parasitic drag of component
            arguments
                obj
                altitude {mustBePositive}
                ref_wing_area {mustBePositive}
                form_factor
                characteristic_length
                airspeed.mach_number = 0
                airspeed.velocity = 0
            end

            altitude = ul(altitude);
            ref_wing_area = ul(ref_wing_area);
            characteristic_length = ul(characteristic_length);
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

            reynolds_number = calc_reynolds_number(characteristic_length, altitude, airspeed.velocity);
            skin_friction_factor = calc_skin_friction_factor(reynolds_number);

            if obj.wetted_area == 0 || ul(skin_friction_factor) == 0
                output = 0;
            else
                output = form_factor * obj.interference_factor * skin_friction_factor * obj.wetted_area / ref_wing_area;
            end
        end
    end % methods

    methods (Static)
        function re = calc_reynolds_number(length, altitude, velocity)
            arguments
                length 
                altitude 
                velocity 
            end
            [length, altitude, velocity] = ul([length, altitude, velocity]);
            re = length * velocity * Atm.density(altitude) / Atm.viscosity_dyn(altitude);
        end

        function output = calc_skin_friction_factor(reynolds_number)
            arguments
                reynolds_number
            end
            % SKIN_FRICTION_COEFF Returns skin friction coefficient as
            % determined using simplified 'Schlichting Formula' from Week 3
            % Slide 11. Requires Reynolds number.
            output = 0.455 / (log10(reynolds_number)^2.58);
        end
    end % methods
end

