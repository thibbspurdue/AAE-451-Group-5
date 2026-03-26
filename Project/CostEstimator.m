classdef CostEstimator
    % Implements CERs from various literature. Includes some modernisations
    % based on AFIT papers, but the original RAND Corporation DAPCA models
    % remain the most accurate.
    properties (Constant) % Wrap rates from Raymer 18.4, 2012 USD/hour
        engineering_rate = 115;
        tooling_rate = 118;
        manufacturing_rate = 98;
        quality_control_rate = 108;
        inflation = 324.122 / 229.594; % 2026 CPI / 2012 CPI
        output_string = "Program DCPR Cost, adjusted to 2026 Dollars: $%.2f\n"
    end

    methods (Static)
        function cost = cost_raymer(empty_weight, max_velocity, prod_qty, test_qty)
            % HOURS_RAYMER Implements DCPR cost estimating
            % relationships (CERs) from Raymer Ch. 18. Excludes the engine,
            % avionics, payload, etc.
            % TODO: Implement modifications by Cpt.
            % Daniel B. Lambert:
            % https://apps.dtic.mil/sti/tr/pdf/ADA538329.pdf
            arguments
                empty_weight % kg if no units specified
                max_velocity % m/s if no units specified
                prod_qty % 5-year production quantity
                test_qty % Number of test flight aircraft (typ. 2-6)
            end
            empty_weight = ul(empty_weight);
            params = [ul(empty_weight) 3.6 * ul(max_velocity) prod_qty]; % DAPCA uses km/h
        
            % Numbers referenced from RAND Corporation DAPCA IV model
            hours.engineering = 5.18 * prod(params.^[0.777 0.894 0.163]);
            hours.tooling = 7.22 * prod(params.^[0.777 0.696 0.263]);
            hours.manufacturing = 10.5 * prod(params.^[0.82 0.484 0.641]);
            hours.quality_control = 0.133 * hours.manufacturing; % 0.076 if cargo aircraft

            cost = hours.engineering * CostEstimator.engineering_rate + ...
                   hours.tooling * CostEstimator.tooling_rate + ...
                   hours.manufacturing * CostEstimator.manufacturing_rate + ...
                   hours.quality_control * CostEstimator.quality_control_rate + ...
                   1947 * empty_weight^0.325 * max_velocity^0.822 * test_qty^1.21 + ... % test flight cost
                   31.2 * empty_weight^0.921 * max_velocity^0.621 * prod_qty^0.799; % manufacturing materials cost

            cost = cost * CostEstimator.inflation; % Adjust cost for inflation
            fprintf(CostEstimator.output_string, cost);
        end % hours_raymer
    
        function cost = cost_alromaihi_weight(empty_weight)
            % HOURS_ALROMAIHI Implements DCPR cost estimating relationships
            % (CERs) from Col. Al-Romaihi et al.'s AFIT paper,
            % https://scholar.afit.edu/cgi/viewcontent.cgi?article=1532&context=etd
            % 
            arguments
                empty_weight % m/s if no units specified
            end
            u = symunit;
            empty_weight = double(separateUnits(unitConvert(ul(empty_weight) * u.kg, u.lbm))); % AFIT CER uses lb
            
            hours.engineering = 7.0191 * empty_weight^1.117 + ... % Design hours
                                15.104 * empty_weight^1.0056 + ... % Design support hours
                                296.43 * empty_weight^0.7920; % Testing hours
            hours.tooling = 0.3022 * empty_weight^1.4075;
            hours.manufacturing = 309.91 * empty_weight^0.7587;
            hours.quality_control = 5.9327 * empty_weight^0.9178;

            cost = hours.engineering * CostEstimator.engineering_rate + ...
                   hours.tooling * CostEstimator.tooling_rate + ...
                   hours.manufacturing * CostEstimator.manufacturing_rate + ...
                   hours.quality_control * CostEstimator.quality_control_rate;
               
            cost = cost * CostEstimator.inflation; % Adjust cost for inflation
            fprintf(CostEstimator.output_string, cost);
        end % hours_alromaihi

        function cost = cost_alromaihi_partsize(empty_weight)
            % HOURS_ALROMAIHI Implements DCPR cost estimating relationships
            % (CERs) from Col. Al-Romaihi et al.'s AFIT paper,
            % https://scholar.afit.edu/cgi/viewcontent.cgi?article=1532&context=etd
            arguments
                empty_weight % m/s if no units specified
            end
            u = symunit;
            empty_weight = double(separateUnits(unitConvert(ul(empty_weight) * u.kg, u.lbm))); % AFIT CER uses lb
            DCPR_weight = 1.568 * empty_weight^0.9019; % eq.24
            part_count = 55.517 * DCPR_weight^0.5821; % eq. 23
            part_size = empty_weight / part_count; % see p.96
            
            % Following values are in hours/lb
            hours.engineering = 401.02 * part_size^-2.4851 + ... % Design hours
                                38.64 * part_size^-0.7454 + ... % Design support hours
                                204.61 * part_size^-1.3836; % Testing hours
            hours.tooling = 255.197 * part_size^-2.1535;
            hours.manufacturing = 207.23 * part_size^-1.7126;
            hours.quality_control = 7.855 * part_size^-0.9072;
            
            cost = hours.engineering * CostEstimator.engineering_rate + ...
                   hours.tooling * CostEstimator.tooling_rate + ...
                   hours.manufacturing * CostEstimator.manufacturing_rate + ...
                   hours.quality_control * CostEstimator.quality_control_rate;
            cost = cost * empty_weight; % hours/lb -> hours
               
            cost = cost * CostEstimator.inflation; % Adjust cost for inflation
            fprintf(CostEstimator.output_string, cost);
        end % hours_alromaihi
    end
end