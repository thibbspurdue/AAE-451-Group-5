classdef Wing < Component
    % WING Wing component class used for drag analysis.
    % Subclass of Component class.

    properties
        interference_factor = 1
        mass = 0
        wingspan = 0
        aspect_ratio = 0
        thickness_chord_ratio = 1
        chord_root = 0
        chord_tip = 0
        LE_sweep = 0 % leading edge sweep
        QC_sweep = 0 % quarter chord sweep
        MC_sweep = 0 % midchord sweep
    end

    properties (Dependent)
        reference_area
        wetted_area
        mean_chord
        oswald_eff
    end
    
    methods (Access = public)
        function obj = Wing(wingspan, aspect_ratio, thickness_chord_ratio, chord_root, chord_tip, interference_factor, options)
            % WING Construct a Wing object for drag analysis.
            % Wing root chord defined at centre of aircraft, not at
            % wing-fuselage interface.
            arguments
                wingspan
                aspect_ratio
                thickness_chord_ratio
                chord_root 
                chord_tip 
                interference_factor = 1
                options.?Wing
            end

            if nargin == 0
                return
            end

            obj@Component(interference_factor)
            obj.wingspan = ul(wingspan);
            obj.aspect_ratio = aspect_ratio;
            obj.thickness_chord_ratio = thickness_chord_ratio;
            obj.chord_root = ul(chord_root);
            obj.chord_tip = ul(chord_tip);
            obj.interference_factor = interference_factor;

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

        function drag_factor = calc_induced_drag_factor(obj, mach_number)
            arguments
                obj
                mach_number 
            end
            
    end

    methods
        function area = get.reference_area(obj)
            area = obj.wingspan^2 / obj.aspect_ratio;
        end

        % function area = get.wetted_area(obj)
        % % Calculates and sets wetted area when given a
        % % reference Fuselage object to determine overlapping planform area.
        % % Uses equation from week 3 slide 14.
        %     overlap_distance = fuselage.diameter / obj.length;
        %     overlap_area = overlap_distance * (overlap_distance * (obj.chord_root - obj.chord_tip) + obj.chord_root) / 2;
        %     area = (obj.reference_area - overlap_area) * 2 * 1.02;
        % end

        function area = get.wetted_area(obj)
        % Calcuates and sets wetted area when given a
        % reference Fuselage object to determine overlapping planform area.
        % Uses Raymer eqns. 7.11 and 7.12.
            overlap_distance = fuselage.diameter / obj.length;
            overlap_area = overlap_distance * (overlap_distance * (obj.chord_root - obj.chord_tip) + obj.chord_root) / 2;
            exposed_area = obj.reference_area - overlap_area;
            if obj.thickness_chord_ratio < 0.05
                area = exposed_area * 2.003;
            else
                area =  exposed_area * (1.977 + 0.52 * obj.thickness_chord_ratio);
            end
        end

        function output = get.mean_chord(obj)
            output = (obj.chord_root + obj.chord_tip) / 2;
        end

        function output = get.oswald_eff(obj)
            output = 4.61 * (1 - 0.045 * obj.aspect_ratio^0.68) * (cos(obj.LE_sweep)^0.15) - 3.1; % Raymer eq. 12.49
        end
    end
end

