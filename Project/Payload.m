classdef Payload < Component
    %PAYLOAD Payload component class used for drag analysis.
    % Subclass of Component class.

    properties
        
    end

    properties (Constant, Access = private)
        payload_types = [
            "M61 Cannon", ...
            "AIM-7M Sparrow" ...
            ]
    end

    methods
        function obj = Payload(payload_type)
            %PAYLOAD Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                payload_type string {mustBeMember(payload_type), Payload.payload_types}
            end
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end