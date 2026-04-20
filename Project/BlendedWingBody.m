classdef BlendedWingBody
    % BLENDEDWINGBODY Class for blended wing body (BWB) aircraft configuration based on BlendedNet paper parameterization.
    properties
        % Geometric parameters
        C1 {mustBePositive} = 0.5 % Chord length at the centerline
        C2_C1 {mustBePositive, mustBeBetween(C2_C1, 0.55, 0.85)}
        C3_C1 {mustBePositive, mustBeBetween(C3_C1, 0.18, 0.28)}
        C4_C1 {mustBePositive, mustBeBetween(C4_C1, 0.06, 0.09)}
        B1_C1 {mustBePositive, mustBeBetween(B1_C1, 0.10, 0.20)}
        B2_C1 {mustBePositive, mustBeBetween(B2_C1, 0.05, 0.20)}
        B3_C1 {mustBePositive, mustBeBetween(B3_C1, 0.20, 0.70)}
        S1 {mustBePositive, mustBeBetween(S1, 40, 60)}
        S2 {mustBePositive, mustBeBetween(S2, 40, 60)}
        S3 {mustBePositive, mustBeBetween(S3, 24, 40)}
        fin_1 = Fin() % Fin object for leftmost fin
        fin_2 = Fin() % Fin object for second from left fin
        fin_3 = Fin() % Fin object for third from left fin
        fin_4 = Fin() % Fin object for third from right fin
        fin_5 = Fin() % Fin object for second from right fin
        fin_6 = Fin() % Fin object for rightmost fin
    end

    methods
        function obj = BlendedWingBody(args)
            arguments
                args.C1 {mustBePositive} = 0
                args.C2_C1 {mustBePositive, mustBeBetween(args.C2_C1, 0.55, 0.85)} = 0
                args.C3_C1 {mustBePositive, mustBeBetween(args.C3_C1, 0.18, 0.28)} = 0
                args.C4_C1 {mustBePositive, mustBeBetween(args.C4_C1, 0.06, 0.09)} = 0
                args.B1_C1 {mustBePositive, mustBeBetween(args.B1_C1, 0.10, 0.20)} = 0
                args.B2_C1 {mustBePositive, mustBeBetween(args.B2_C1, 0.05, 0.20)} = 0
                args.B3_C1 {mustBePositive, mustBeBetween(args.B3_C1, 0.20, 0.70)} = 0
                args.S1 {mustBePositive, mustBeBetween(args.S1, 40, 60)} = 0
                args.S2 {mustBePositive, mustBeBetween(args.S2, 40, 60)} = 0
                args.S3 {mustBePositive, mustBeBetween(args.S3, 24, 40)} = 0
            end
            
            for prop = fieldnames(args)'
                obj.(prop) = args.(prop);
            end

            % Symmetric nominal fin initialization for baseline geometry.
            obj.fin_1 = Fin(length=obj.C1, thickness_chord_ratio=0.10, root_chord=obj.C4_C1*obj.C1, tip_chord=0.6*obj.C4_C1*obj.C1);
            obj.fin_2 = Fin(length=obj.C1, thickness_chord_ratio=0.10, root_chord=obj.C4_C1*obj.C1, tip_chord=0.6*obj.C4_C1*obj.C1);
            obj.fin_3 = Fin(length=obj.C1, thickness_chord_ratio=0.10, root_chord=obj.C4_C1*obj.C1, tip_chord=0.6*obj.C4_C1*obj.C1);
            obj.fin_4 = Fin(length=obj.C1, thickness_chord_ratio=0.10, root_chord=obj.C4_C1*obj.C1, tip_chord=0.6*obj.C4_C1*obj.C1);
            obj.fin_5 = Fin(length=obj.C1, thickness_chord_ratio=0.10, root_chord=obj.C4_C1*obj.C1, tip_chord=0.6*obj.C4_C1*obj.C1);
            obj.fin_6 = Fin(length=obj.C1, thickness_chord_ratio=0.10, root_chord=obj.C4_C1*obj.C1, tip_chord=0.6*obj.C4_C1*obj.C1);
        end
    end
end