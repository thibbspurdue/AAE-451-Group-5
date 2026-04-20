classdef Component
    % COMPONENT Generic component.
    % Common components such as wings, fuselages, nacelles, etc. should be
    % instantiated using respective subfunctions to ensure correct
    % attributes are defined.

    properties
        interference_factor = 1
        wetted_area = 0
        mass = 0
        x = 0
        y = 0
        z = 0
    end

    properties (Dependent)
        x_cg
        y_cg
        z_cg
    end

    methods (Access = public)
        function obj = Component(interference_factor, wetted_area, mass)
            % COMPONENT Construct a generic Component object.
            arguments
                interference_factor = 1
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

        function output = calc_cd0(obj, form_factor, skin_friction_coeff)
            % CALC_CD0 Calculates and returns parasitic drag of component. Needs to be divided by reference area to be used in drag calculations.
            arguments
                obj
                form_factor {mustBePositive}
                skin_friction_coeff {mustBePositive}
            end
            output = form_factor * obj.interference_factor * skin_friction_coeff * obj.wetted_area;
        end
    end

    methods (Static)
        function re = calc_reynolds_number(length, altitude, velocity)
            arguments
                length 
                altitude 
                velocity 
            end
            length = ul(length);
            altitude = ul(altitude);
            velocity = ul(velocity);
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

    methods
        function output = get.x_cg(obj)
            output = obj.x;
        end

        function output = get.y_cg(obj)
            output = obj.y;
        end

        function output = get.z_cg(obj)
            output = obj.z;
        end
    end
end

