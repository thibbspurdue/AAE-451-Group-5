classdef Wing < Component
    % WING Wing component class used for drag analysis.
    % Subclass of Component class.

    properties
        wingspan = 0                % Wingspan, m
        aspect_ratio = 0            % Aspect ratio, AR = b^2 / S_ref
        thickness_chord_ratio = 0   % Maximum thickness/chord
        fuselage_overlap = 0        % Overlapping wing-fuselage area, m^2
        root_chord = 0              % Root chord length at centre of aircraft (in fuselage), m
        leading_edge_sweep = 0      % Leading edge sweep, rad
    end % properties

    properties (Dependent)
        half_span
        reference_area              % Flat reference wing area, including overlap, m^2
        wetted_area_raymer          % Wetted surface area as calculated from Raymer, without overlap, m^2
        wetted_area_slides          % Wetted surface area as calculated from slides, without overlap, m^2
        oswald_eff                  % Oswald efficiency factor
        mean_chord                  % Mean chord length, m
        tip_chord                   % Tip chord length, m
        taper_ratio                 % Tip to root chord ratio
        quarter_chord_sweep         % Angle of quarter chord line, rad
        mid_chord_sweep             % Angle of midchord line, rad
        trailing_edge_sweep         % Angle of trailing edge, rad
    end % dependent properties
    
    methods
        function obj = Wing(o)
            % WING Construct a Wing object for drag analysis.
            % Wing root chord defined at centre of aircraft, not at
            % wing-fuselage interface.
            arguments
                o.?Wing
            end

            if nargin > 0
                for field = fieldnames(o)
                    obj.(field) = args.(ul(field));
                end

                if obj.aspect_ratio == 0
                    if obj.wingspan ~= 0 && obj.reference_area ~= 0
                        obj.aspect_ratio = obj.wingspan^2 / obj.reference_area;
                    else
                        error("Either reference area + wingspan or aspect ratio required.\n")
                    end
                end
            end
        end % constructor

        function form_factor = calc_form_factor(obj, mach_number)
            arguments
                obj 
                mach_number 
            end
            form_factor = 1 + calc_sweep_correction(obj, mach_number) * obj.thickness_chord_ratio + 100 * obj.thickness_chord_ratio^4;
        end

        function sweep_correction = calc_sweep_correction(obj, mach_number)
            arguments
                obj 
                mach_number 
            end
            sweep_correction = (2 - mach_number^2) * cos(obj.quarter_chord_sweep) / sqrt(1 - (mach_number * cos(obj.quarter_chord_sweep))^2);
        end

        function output = calc_cd0(obj, altitude, airspeed)
            % CALC_CD0 Calculates and returns parasitic drag of component.
            % Requires either Mach number or velocity, using Mach number if
            % both are provided.
            arguments
                obj Component
                altitude {mustBePositive}
                airspeed.mach_number = 0
                airspeed.velocity = 0
            end

            altitude = ul(altitude);
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
            
            output = obj.calc_cd0(altitude, obj.reference_area, form_factor, obj.mean_chord, "velocity", airspeed.velocity);
        end

        function angle = calc_chord_sweep(obj, x)
            arguments
                obj 
                x {mustBeBetween(x, 0, 1)}
            end
            x_1 = obj.root_chord / x;
            x_2 = obj.half_span * tan(obj.leading_edge_sweep) + obj.tip_chord / x;
            angle = atan2(obj.half_span, x_1 - x_2);
        end

        function drag_factor = calc_induced_drag_factor(obj, mach_number)
            arguments
                obj
                mach_number
            end
            drag_factor = 1 / (pi * obj.aspect_ratio * obj.oswald_eff * (1 - mach_number^2)^0.5);
        end

    end % methods

    methods
        function span = get.half_span(obj)
            span = obj.wingspan / 2;
        end

        function area = get.reference_area(obj)
            area = obj.wingspan * obj.mean_chord;
        end

        function area = get.wetted_area_slides(obj)
            % Calculates wetted area using equation from week 3 slide 14.
            arguments
                obj
            end
            area = (obj.reference_area - obj.fuselage_overlap) * 2 * 1.02;
        end

        function area = get.wetted_area_raymer(obj)
            % Calcuates wetted area using Raymer eqns. 7.11 and 7.12.
            arguments
                obj 
            end
            if obj.thickness_chord_ratio < 0.05
                area = (obj.reference_area - obj.fuselage_overlap) * 2.003;
            else
                area =  (obj.reference_area - obj.fuselage_overlap) * (1.977 + 0.52 * obj.thickness_chord_ratio);
            end
        end

        function output = get.oswald_eff(obj)
            output = 4.61 * (1 - 0.045 * obj.aspect_ratio^0.68) * (cos(obj.leading_edge_sweep)^0.15) - 3.1; % Raymer eq. 12.49
        end

        function output = get.mean_chord(obj)
            output = (obj.root_chord + obj.tip_chord) / 2;
        end
        
        function chord = get.tip_chord(obj)
            chord = 2 * obj.mean_chord - obj.chord_root;
        end

        function taper = get.taper_ratio(obj)
            taper = obj.tip_chord / obj.root_chord;
        end

        function angle = get.quarter_chord_sweep(obj)
            angle = obj.calc_chord_sweep(0.25);
        end

        function angle = get.mid_chord_sweep(obj)
            angle = obj.calc_chord_sweep(0.5);
        end

        function angle = get.trailing_edge_sweep(obj)
            angle = obj.calc_chord_angle(1);
        end
    end % getter methods
end

