classdef Tail < Component
    % TAIL Aerodynamic surface component class used for tails.
    % Subclass of Component class.

    properties
        length = 0
        thickness_chord_ratio = 1
        chord_root = 0
        chord_tip = 0
        leading_edge_sweep = 0
        quarter_chord_sweep = 0
        mid_chord_sweep = 0
    end

    properties (Dependent)
        reference_area
        wetted_area
        mean_chord
        aspect_ratio
    end
    
    methods (Access = public)
        function obj = Tail(length, chord_root, chord_tip, thickness_chord_ratio, interference_factor, options)
            % TAIL Construct a single Tail object for drag analysis. Left
            % and right tails should be instantiated separately.
            arguments
                length 
                chord_root 
                chord_tip
                thickness_chord_ratio
                interference_factor = 1
                options.?Tail
            end

            if nargin == 0
                return
            end

            obj@Component(interference_factor)
            obj.length = ul(length);
            obj.chord_root = ul(chord_root);
            obj.chord_tip = ul(chord_tip);
            obj.thickness_chord_ratio = thickness_chord_ratio;

            set(obj, ul(options))
        end

        function form_factor = calc_form_factor(obj, mach_number)
            form_factor = 1 + calc_sweep_correction(obj, mach_number) * obj.thickness_chord_ratio + 100 * obj.thickness_chord_ratio^4;
        end

        function sweep_correction = calc_sweep_correction(obj, mach_number)
            sweep_correction = (2 - mach_number^2) * cos(obj.QC_sweep) / sqrt(1 - (mach_number * cos(obj.QC_sweep))^2);
        end

        function output = calc_cd0(obj, altitude, mach_number, velocity)
            % CALC_CD0 Calculates and returns parasitic drag of component.
            % Requires either Mach number or velocity, using Mach number if
            % both are provided.
            arguments
                obj
                altitude {mustBePositive}
                mach_number {mustBePositive} = 0
                velocity = 0
            end

            [altitude, velocity] = ul([altitude velocity]);
            if mach_number == 0 && velocity == 0
                error("Must input either velocity or Mach number")
            elseif mach_number == 0
                mach_number = velocity / Atm.sonic_speed(altitude);
            else
                velocity = mach_number * Atm.sonic_speed(altitude);
            end

            form_factor = obj.calc_form_factor(mach_number);
            reynolds_number = calc_reynolds_number(obj.mean_chord, altitude, velocity);
            skin_friction_factor = calc_skin_friction_factor(reynolds_number);
            
            output = form_factor * obj.interference_factor * skin_friction_factor * obj.wetted_area / obj.reference_area;
        end
    end

    methods
        function area = get.reference_area(obj)
            area = obj.length^2 / obj.aspect_ratio;
        end

        % function area = get.wetted_area(obj)
        % % WETTED_AREA Calculates and sets wetted area using the equation
        % % from week 3 slide 14.
        %     area = obj.reference_area * 2 * 1.02;
        % end

        function area = get.wetted_area(obj)
        % WETTED_AREA_RAYMER Calcualtes and sets wetted area using Raymer
        % eqns. 7.11 and 7.12.
            if obj.thickness_chord_ratio < 0.05
                area = obj.reference_area * 2.003;
            else
                area =  obj.reference_area * (1.977 + 0.52 * obj.thickness_chord_ratio);
            end
        end

        function output = get.mean_chord(obj)
            output = (obj.chord_root + obj.chord_tip) / 2;
        end

        function ratio = get.aspect_ratio(obj)
            ratio = obj.length^2 / obj.reference_area;
        end
    end
end

