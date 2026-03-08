classdef Fuselage < Component
    % FUSELAGE Fuselage component class used for drag analysis.
    % Subclass of Component class.

    properties
        length = 0
        width = 0
        interference_factor = 1
        mass = 0
    end

    properties (Dependent)
        fineness_ratio
        wetted_area
    end

    properties (Access = private)
        fuselage_types = [ ...
            "Hotdog, Raymer eq. 12.31" ...
            "Nicolai eq. xx.xx" ...
            "Nicolai eq. xx.xx"];
    end
    
    methods (Access = public)
        function obj = Fuselage(fuselage_type, length, width, interference_factor, options)
            % FUSELAGE Construct a Fuselage object using two dimensions and
            % the wetted area modelling method. The hotdog method is useful
            % for early estimates but should be replaced with more accurate
            % wetted area models.
            arguments
                fuselage_type (1,1) string {mustBeMember(fuselage_type, [ ...
                    "Hotdog, Raymer eq. 12.31" ...
                    "Nicolai eq. xx.xx" ...
                    "Nicolai eq. xx.xx"])}
                length
                width
                interference_factor = 1
                options.?Fuselage
            end

            if nargin == 0
                return
            end
            
            obj@Component(interference_factor)
            obj.length = ul(length);
            obj.width = ul(width);

            set(obj, ul(options))
        end

        function output = calc_cd0(obj, ref_wing_area)
            % CD0 Calculates and returns parasitic drag of component
            arguments
                obj
                ref_wing_area {mustBePositive}
            end
            ref_wing_area = ul(ref_wing_area);
            output = obj.form_factor * obj.interference_factor * skin_friction_coeff * obj.wetted_area / ref_wing_area;
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
            fineness_ratio = obj.length / obj.drag;
        end

        function wetted_area = get.wetted_area(obj)
            wetted_area = pi * obj.width * obj.length * (1 - 2 * obj.width / obj.length)^(2/3) * (1 + (obj.width / obj.length)^2);
        end
    end
end

