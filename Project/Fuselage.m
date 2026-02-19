classdef Fuselage < Component
    % FUSELAGE Fuselage component class used for drag analysis.
    % Subclass of Component class.

    properties
        length = 0
        width = 0
    end
    
    methods
        function obj = Fuselage(interference_factor, options)
            % CUSTOMFUSELAGE Construct a Fuselage object for drag analysis.
            arguments
                interference_factor 
                options.?Fuselage
            end
            obj@Component()
            if nargin == 0
                return
            end
            obj.interference_factor = interference_factor;
            set(obj, ul(options))
        end

        function obj = Fuselage_Hotdog(interference_factor, length, diameter, options)
            % FUSELAGE Construct a hotdog-shaped Fuselage object. Useful
            % for early estimates but should be replaced with more accurate wetted area models.
            % Requires interference factor, length, and diameter.
            arguments
                interference_factor 
                length 
                diameter 
                options.?Fuselage
            end
                                  
            obj = Fuselage(interference_factor);
            obj.form_factor = options.form_factor;
            
            obj.length = ul(length);
            obj.width = ul(diameter);
            obj.fineness_ratio = obj.length / obj.width;
            if isfield(options, "form_factor")
                obj.form_factor = options.form_factor;
            else
                obj.form_factor = 0.9 + 5 / (obj.fineness_ratio^1.5) + obj.fineness_ratio / 400; % From Raymer eq. 12.31
            end
            if isfield(options, "wetted_area")
                options.wetted_area = ul(options.wetted_area);
            else
                obj.wetted_area = pi * obj.width * obj.length * ((1 - 2/obj.fineness_ratio)^(2/3) * (1 + 1/obj.fineness_ratio^2)); % From week 3 slide 12
            end
        end

        function output = CD0(obj, ref_wing_area)
            % CALC_CD0 Calculates and returns parasitic drag of component
            arguments
                obj
                ref_wing_area {mustBePositive}
            end
            ref_wing_area = ul(ref_wing_area);
            output = obj.form_factor * obj.interference_factor * skin_friction_coeff * obj.wetted_area / ref_wing_area;
        end
    end
end

