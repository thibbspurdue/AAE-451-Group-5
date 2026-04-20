classdef Fuselage < Component
    % FUSELAGE Fuselage component class used for drag analysis.
    % Subclass of Component class.

    properties
        fuselage_type = "Hotdog, Raymer eq. 12.31"
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
        function obj = Fuselage(options)
            % FUSELAGE Construct a Fuselage object using two dimensions and
            % the wetted area modelling method. The hotdog method is useful
            % for early estimates but should be replaced with more accurate
            % wetted area models.
            arguments
                options.fuselage_type (1,1) string {mustBeMember(options.fuselage_type, [ ...
                    "Hotdog, Raymer eq. 12.31" ...
                    "Nicolai eq. xx.xx" ...
                    "Nicolai eq. xx.xx"])} = "Hotdog, Raymer eq. 12.31"
                options.length = 0
                options.width = 0
                options.mass = 0
            end

            obj@Component(1);
            obj.fuselage_type = options.fuselage_type;
            obj.length = ul(options.length);
            obj.width = ul(options.width);
            obj.mass = ul(options.mass);
            obj.wetted_area = pi * obj.width * obj.length * (1 - 2 * obj.width / obj.length)^(2/3) * (1 + (obj.width / obj.length)^2);
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
            fineness_ratio = obj.length / obj.width;
        end
    end
end

