classdef Configuration
    % CONFIGURATION Defines a Configuration object containing information
    % to calculate physical properties such as lift and drag.
    
    properties
        aspect_ratio
        fuselage_diameter
        wingspan
    end
    
    methods
        function obj = Configuration(inputArg1,inputArg2)
            % Configuration Construct an instance of this class
            % Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function C_L = calculateLift(obj, AoA)
            
            C_L = 
        end

        function C_D0 = parasiticDrag(obj)
            C_D0 = 
        end

        function totalDrag = method1(obj, inputArg)
            % TOTALDRAG Calculates the total drag coefficient of an
            % aircraft at a specific angle of attack
            %   C_D = C_D0 + (C_L^2 / (pi * AR * e)) + C_DW
            totalDrag = parasitic_drag + ();
        end
    end
end

