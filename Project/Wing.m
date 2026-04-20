classdef Wing < Component
    % WING Wing component class used for drag analysis.
    % Uses Fin as the shared geometric/aerodynamic primitive for one half-wing.

    properties
        wingspan = 0                  % Full span, m
        aspect_ratio = 0              % AR = b^2 / S_ref
        thickness_chord_ratio = 0     % Maximum thickness/chord
        root_chord = 0                % Root chord at aircraft centerline, m
        tip_chord = 0                 % Tip chord, m
        leading_edge_sweep = 0        % Leading edge sweep, rad
        fuselage_overlap = 0          % Overlapped wing planform area at fuselage, m^2
    end

    properties (Dependent)
        half_span
        reference_area                % Full wing reference area, m^2
        wetted_area_raymer            % Wetted area from Raymer correlations, m^2
        wetted_area_slides            % Wetted area from class slides, m^2
        oswald_eff
        mean_chord
        taper_ratio
        quarter_chord_sweep
        mid_chord_sweep
        trailing_edge_sweep
        critical_mach_number
        drag_divergence_mach_number
    end

    methods
        function obj = Wing(options)
            arguments
                options.wingspan = 0
                options.aspect_ratio = 0
                options.thickness_chord_ratio = 0
                options.root_chord = 0
                options.tip_chord = 0
                options.leading_edge_sweep = 0
                options.interference_factor = 1
                options.fuselage_overlap = 0
            end

            fields = fieldnames(options);
            for i = 1:numel(fields)
                field = fields{i};
                if isprop(obj, field)
                    obj.(field) = ul(options.(field));
                end
            end

            if obj.wingspan == 0 && obj.aspect_ratio ~= 0
                obj.wingspan = obj.aspect_ratio * obj.mean_chord;
            end

            if obj.aspect_ratio == 0 && obj.wingspan ~= 0 && obj.reference_area ~= 0
                obj.aspect_ratio = obj.wingspan^2 / obj.reference_area;
            end
        end

        function form_factor = calc_form_factor_raymer(obj, mach_number)
            fin = obj.as_fin();
            form_factor = fin.calc_form_factor(mach_number);
        end

        function form_factor = calc_form_factor_shevell(obj, mach_number)
            form_factor = 1 + obj.calc_sweep_correction(mach_number) * obj.thickness_chord_ratio + 100 * obj.thickness_chord_ratio^4;
        end

        function sweep_correction = calc_sweep_correction(obj, mach_number)
            fin = obj.as_fin();
            sweep_correction = fin.calc_sweep_correction(mach_number);
        end

        function output = calc_cd0(obj, altitude, velocity)
            arguments
                obj Component
                altitude {mustBePositive}
                velocity = 0
            end

            altitude = ul(altitude);
            velocity = ul(velocity);
            mach_number = velocity / Atm.sonic_speed(altitude);

            skin_friction_coeff = Component.calc_skin_friction_factor( ...
                Component.calc_reynolds_number(obj.mean_chord, altitude, velocity));
            form_factor = obj.calc_form_factor_raymer(mach_number);

            output = form_factor * obj.interference_factor * skin_friction_coeff * obj.wetted_area_raymer;
        end

        function output = calc_cd0_mach(obj, altitude, mach_number, options)
            arguments
                obj Component
                altitude {mustBePositive}
                mach_number {mustBePositive}
                options.include_wave_drag (1,1) logical = false
                options.m_crit = []
                options.m_dw_peak (1,1) double {mustBePositive} = 1.25
                options.c_dw_peak (1,1) double {mustBeNonnegative} = 0.058
                options.min_wave_fraction (1,1) double {mustBeNonnegative} = 0.3
            end
            fin = obj.as_fin();
            output = fin.calc_cd0_mach(altitude, mach_number, ...
                include_wave_drag=options.include_wave_drag, ...
                m_crit=options.m_crit, ...
                m_dw_peak=options.m_dw_peak, ...
                c_dw_peak=options.c_dw_peak, ...
                min_wave_fraction=options.min_wave_fraction);
        end

        function output = calc_cd0_total_mach(obj, altitude, mach_number, m_crit, options)
            arguments
                obj Component
                altitude {mustBePositive}
                mach_number {mustBePositive}
                m_crit (1,1) double
                options.m_dw_peak (1,1) double {mustBePositive} = 1.25
                options.c_dw_peak (1,1) double {mustBeNonnegative} = 0.058
                options.min_wave_fraction (1,1) double {mustBeNonnegative} = 0.3
            end
            fin = obj.as_fin();
            output = fin.calc_cd0_total_mach(altitude, mach_number, m_crit, ...
                m_dw_peak=options.m_dw_peak, ...
                c_dw_peak=options.c_dw_peak, ...
                min_wave_fraction=options.min_wave_fraction);
        end

        function cd_wave = calc_wave_drag(obj, mach_number, m_crit, options)
            arguments
                obj Component
                mach_number {mustBePositive}
                m_crit (1,1) double
                options.m_dw_peak (1,1) double {mustBePositive} = 1.25
                options.c_dw_peak (1,1) double {mustBeNonnegative} = 0.058
                options.min_wave_fraction (1,1) double {mustBeNonnegative} = 0.3
            end
            fin = obj.as_fin();
            cd_wave = fin.calc_wave_drag(mach_number, m_crit, ...
                m_dw_peak=options.m_dw_peak, ...
                c_dw_peak=options.c_dw_peak, ...
                min_wave_fraction=options.min_wave_fraction);
        end

        function angle = calc_chord_sweep(obj, x)
            fin = obj.as_fin();
            angle = fin.calc_chord_sweep(x);
        end

        function drag_factor = calc_induced_drag_factor(obj, mach_number)
            if mach_number < 1
                drag_factor = 1 / (pi * obj.aspect_ratio * obj.oswald_eff);
            else
                beta = sqrt(max(mach_number^2 - 1, 1e-6));
                drag_factor = max(1 / (pi * obj.aspect_ratio * obj.oswald_eff), beta / 4);
            end
        end

        function output = l_d_max(obj, altitude, velocity)
            mach_number = ul(velocity) / Atm.sonic_speed(ul(altitude));
            output = obj.l_d_max_mach(altitude, mach_number);
        end

        function output = l_d_max_mach(obj, altitude, mach_number)
            output = 1 / sqrt(obj.calc_cd0_mach(altitude, mach_number) + obj.calc_induced_drag_factor(mach_number));
        end

        function output = calc_induced_drag(obj, lift_coefficient, altitude, velocity)
            mach_number = ul(velocity) / Atm.sonic_speed(ul(altitude));
            drag_factor = obj.calc_induced_drag_factor(mach_number);
            output = drag_factor * lift_coefficient^2;
        end
    end

    methods
        function span = get.half_span(obj)
            span = obj.wingspan / 2;
        end

        function area = get.reference_area(obj)
            area = obj.wingspan * obj.mean_chord;
        end

        function area = get.wetted_area_slides(obj)
            area = (obj.reference_area - obj.fuselage_overlap) * 2 * 1.02;
        end

        function area = get.wetted_area_raymer(obj)
            planform = obj.reference_area - obj.fuselage_overlap;
            if obj.thickness_chord_ratio < 0.05
                area = planform * 2.003;
            else
                area = planform * (1.977 + 0.52 * obj.thickness_chord_ratio);
            end
        end

        function output = get.oswald_eff(obj)
            output = 4.61 * (1 - 0.045 * obj.aspect_ratio^0.68) * (cos(obj.leading_edge_sweep)^0.15) - 3.1;
        end

        function output = get.mean_chord(obj)
            fin = obj.as_fin();
            output = fin.mean_chord;
        end

        function taper = get.taper_ratio(obj)
            fin = obj.as_fin();
            taper = fin.taper_ratio;
        end

        function sweep = get.quarter_chord_sweep(obj)
            fin = obj.as_fin();
            sweep = fin.calc_chord_sweep(0.25);
        end

        function sweep = get.mid_chord_sweep(obj)
            fin = obj.as_fin();
            sweep = fin.calc_chord_sweep(0.5);
        end

        function sweep = get.trailing_edge_sweep(obj)
            fin = obj.as_fin();
            sweep = fin.calc_chord_sweep(1);
        end

        function output = get.critical_mach_number(obj)
            output = (obj.oswald_eff / (obj.oswald_eff - 1))^0.5 * (1 / obj.thickness_chord_ratio) - 1;
        end

        function output = get.drag_divergence_mach_number(obj)
            output = (obj.oswald_eff / (obj.oswald_eff - 1))^0.5 * (1 / obj.thickness_chord_ratio) - 0.1;
        end
    end

    methods (Access = private)
        function fin = as_fin(obj)
            fin = Fin( ...
                length=obj.half_span, ...
                thickness_chord_ratio=obj.thickness_chord_ratio, ...
                root_chord=obj.root_chord, ...
                tip_chord=obj.tip_chord, ...
                leading_edge_sweep=obj.leading_edge_sweep, ...
                interference_factor=obj.interference_factor);
        end
    end
end
