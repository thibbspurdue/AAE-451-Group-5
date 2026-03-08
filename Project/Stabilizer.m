classdef Stabilizer < Component
    % TAIL Aerodynamic surface component class used for tail drag buildup.
    % Models a single isolated fin component as opposed to an entire tail.
    % Subclass of Component class.

    properties
        length = 0
        thickness_chord_ratio = 1
        chord_root = 0
        chord_tip = 0
        leading_edge_sweep = 0
        quarter_chord_sweep = 0
        mid_chord_sweep = 0
    end % properties

    properties (Dependent)
        reference_area
        mean_chord
        aspect_ratio
    end % dependent properties
    
    methods (Access = public)
        function obj = Stabilizer(args)
            % TAIL Construct a single Tail object for drag analysis. Left
            % and right tails should be instantiated separately.
            arguments
                args.?Stabilizer
            end
            if nargin > 0
                for field = fieldnames(args)
                    obj.(field) = args.(ul(field));
                end
            end
        end % constructor

        function area = wetted_area_slides(obj)
        % Calculates wetted area using the equation from week 3 slide 14.
            area = obj.reference_area * 2 * 1.02;
        end

        function area = wetted_area_raymer(obj)
        % Calculates wetted area using Raymer eqns. 7.11 and 7.12.
            if obj.thickness_chord_ratio < 0.05
                area = obj.reference_area * 2.003;
            else
                area =  obj.reference_area * (1.977 + 0.52 * obj.thickness_chord_ratio);
            end
        end

        function form_factor = calc_form_factor(obj, mach_number)
            form_factor = 1 + calc_sweep_correction(obj, mach_number) * obj.thickness_chord_ratio + 100 * obj.thickness_chord_ratio^4;
        end

        function sweep_correction = calc_sweep_correction(obj, mach_number)
            sweep_correction = (2 - mach_number^2) * cos(obj.QC_sweep) / sqrt(1 - (mach_number * cos(obj.QC_sweep))^2);
        end

        function output = calc_cd0(obj, altitude, ref_wing_area, airspeed)
            % CALC_CD0 Calculates and returns parasitic drag of component.
            % Requires either Mach number or velocity, using Mach number if
            % both are provided.
            arguments
                obj Component
                altitude {mustBePositive}
                ref_wing_area {mustBePositive}
                airspeed.mach_number {mustBePositive} = 0
                airspeed.velocity {mustBePositive} = 0
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

            form_factor = obj.calc_form_factor(airspeed.mach_number);
            
            output = obj.calc_cd0(altitude, ref_wing_area, form_factor, obj.mean_chord, "velocity", airspeed.velocity);
        end
    end % methods

    methods
        function area = get.reference_area(obj)
            area = obj.length^2 / obj.aspect_ratio;
        end

        function output = get.mean_chord(obj)
            output = (obj.chord_root + obj.chord_tip) / 2;
        end

        function ratio = get.aspect_ratio(obj)
            ratio = obj.length^2 / obj.reference_area;
        end
    end % getter methods
end