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

    methods (Access = public)
        function obj = Component(interference_factor, wetted_area, mass)
            % COMPONENT Construct a generic Component object.
            arguments
                interference_factor
                wetted_area = 0
                mass = 0
            end

            if nargin == 0
                return
            end

            obj.interference_factor = interference_factor;
            obj.wetted_area = ul(wetted_area);
            obj.mass = ul(mass);
        end

        function output = calc_cd0(obj, skin_friction_coeff, ref_wing_area)
            % CALC_CD0 Calculates and returns parasitic drag of component
            arguments
                obj
                skin_friction_coeff {mustBePositive}
                ref_wing_area {mustBePositive}
            end
            ref_wing_area = ul(ref_wing_area);
            output = obj.form_factor * obj.interference_factor * skin_friction_coeff * obj.wetted_area / ref_wing_area;
        end
    end

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
    end
end

