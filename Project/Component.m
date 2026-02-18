classdef Component
    % COMPONENT Generic component used for drag analysis.
    % Common components such as wings, fuselages, nacelles, etc. should use
    % their respective subclasses.
    
    properties (Constant)
        tempunits = symunit;
        g (1,1) double {mustBePositive} = 9.81 % gravitational acceleration
    end
    properties
        fineness_ratio = 0
        form_factor = 0
        interference_factor = 0
        wetted_area = 0
    end
    
    methods
        function obj = Component(form_factor, interference_factor, wetted_area)
            % COMPONENT Construct a generic Component object.
            % Used in specific component subclasses.
            % arguments
            %     form_factor
            %     interference_factor
            %     % skin_friction_factor % not included since this is
            %     % altitude-dependent as opposed to an intrinsic property
            %     wetted_area
            % end
            if nargin == 0
                return
            end

            if has_units(wetted_area)
                wetted_area = ul(unitConvert(wetted_area, obj.tempunits.m^2));
            end

            obj.form_factor = form_factor;
            obj.interference_factor = interference_factor;
            obj.wetted_area = wetted_area;
        end

        function re = calc_reynolds_no(length, altitude)
            re = length * velocity * Atm.density(altitude) / Atm.viscosity_dyn(altitude);
        end
        
        function output = calc_CD0(obj, skin_friction_factor, ref_wing_area)
            % CALC_CD0 Calculates and returns parasitic drag of component
            output = obj.form_factor * obj.interference_factor * skin_friction_factor * obj.wetted_area / ref_wing_area;
        end
    end
end

