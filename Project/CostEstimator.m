classdef CostEstimator
    % Implements CERs from various literature. Includes some modernisations
    % based on AFIT papers, but the original RAND Corporation DAPCA models
    % remain the most accurate.
    properties (Constant) % Wrap rates from Raymer 18.4, 2012 USD/hour
        engineering_rate = 115;
        tooling_rate = 118;
        manufacturing_rate = 98;
        quality_control_rate = 108;
        avionics_cost = 18000 * 1.025; % USD/kg, Raymer 18.4.2, added 2.5% for complexity
        wrap_rates = [CostEstimator.engineering_rate; CostEstimator.tooling_rate; CostEstimator.manufacturing_rate; CostEstimator.quality_control_rate];
        inflation = 324.122 / 236.7; % 2026 CPI / 2014 CPI
        output_string = "Program DCPR Cost, adjusted to 2026 USD: $%.2f\n"
    end

    methods (Static)
        function test_cost = cost_raymer(empty_weight, max_velocity, test_qty, prod_qty, engine_cost, avionics_weight, learning_curve)
            % HOURS_RAYMER Implements DCPR cost estimating
            % relationships (CERs) from Raymer Ch. 18. Excludes the engine,
            % avionics, payload, etc.
            % TODO: Implement modifications by Cpt.
            % Daniel B. Lambert:
            % https://apps.dtic.mil/sti/tr/pdf/ADA538329.pdf
            arguments
                empty_weight % kg if no units specified
                max_velocity % m/s if no units specified
                test_qty % Number of test flight aircraft/initial batch size
                prod_qty % Total production quantity within 5 years, excluding test aircraft
                engine_cost % Total engine cost per aircraft, 2026 USD
                avionics_weight % Total avionics weight
                learning_curve = 0.85; % assume default curve of 85%
            end
            empty_weight = ul(empty_weight);
            avionics_weight = ul(avionics_weight);
            params = [ul(empty_weight) 3.6 * ul(max_velocity) test_qty]; % DAPCA uses km/h

            test_hours = CostEstimator.hours_raymer(params);
            params(end) = prod_qty + test_qty;
            prod_hours = CostEstimator.hours_raymer(params) - test_hours;
            prod_hours = (((prod_qty + test_qty)/ test_qty)^(1 + log2(learning_curve)) - 1) / (1 + log2(learning_curve)) / ((prod_qty + test_qty)/ test_qty - 1) * prod_hours;
        
            % Numbers referenced from RAND Corporation DAPCA IV model
            test_cost_components = [test_hours .* CostEstimator.wrap_rates; % engineering, tooling, manufacturing, and QC
                                    31.2 * empty_weight^0.921 * max_velocity^0.621 * test_qty^0.799; % program test manufacturing materials cost
                                    test_qty * avionics_weight * CostEstimator.avionics_cost; % avionics cost
                                    1947 * empty_weight^0.325 * max_velocity^0.822 * test_qty^1.21]; % test flight cost

            prod_cost_components = [prod_hours .* CostEstimator.wrap_rates; % engineering, tooling, manufacturing, and QC
                                    prod_qty * avionics_weight * CostEstimator.avionics_cost; % avionics cost
                                    31.2 * empty_weight^0.921 * max_velocity^0.621 * prod_qty^0.799]; % program production manufacturing materials cost

            test_cost_components = test_cost_components * CostEstimator.inflation;
            prod_cost_components = prod_cost_components * CostEstimator.inflation;

            test_engine_cost = test_qty * engine_cost;
            prod_engine_cost = prod_qty * engine_cost;

            test_program_cost = sum(test_cost_components) + test_engine_cost;
            production_cost = sum(prod_cost_components) + prod_engine_cost; % excludes test airframes
            acquisition_cost = test_program_cost + production_cost;
            spares_cost = 0.10 * acquisition_cost;

            fprintf("%-34s %-28s %-14s %-14s\n", "Item", "Total Quantity", "Unit Cost", "Total Cost");
            fprintf("%-34s %-28s %-14s %-14s\n", "Test program", sprintf("%d Test Aircraft", test_qty), CostEstimator.format_musd(test_program_cost / test_qty), CostEstimator.format_musd(test_program_cost));
            fprintf("%-34s %-28s %-14s %-14s\n", "Production (including RD&T)", sprintf("%d Aircraft", prod_qty), CostEstimator.format_musd(production_cost / prod_qty), CostEstimator.format_musd(production_cost));
            fprintf("%-34s %-28s %-14s %-14s\n", "Engineering", CostEstimator.format_hours(test_hours(1) + prod_hours(1)), CostEstimator.format_musd(prod_cost_components(1) / prod_qty), CostEstimator.format_musd(prod_cost_components(1)));
            fprintf("%-34s %-28s %-14s %-14s\n", "Tooling", CostEstimator.format_hours(test_hours(2) + prod_hours(2)), CostEstimator.format_musd(prod_cost_components(2) / prod_qty), CostEstimator.format_musd(prod_cost_components(2)));
            fprintf("%-34s %-28s %-14s %-14s\n", "Manufacturing", CostEstimator.format_hours(test_hours(3) + prod_hours(3)), CostEstimator.format_musd(prod_cost_components(3) / prod_qty), CostEstimator.format_musd(prod_cost_components(3)));
            fprintf("%-34s %-28s %-14s %-14s\n", "Quality Control", CostEstimator.format_hours(test_hours(4) + prod_hours(4)), CostEstimator.format_musd(prod_cost_components(4) / prod_qty), CostEstimator.format_musd(prod_cost_components(4)));
            fprintf("%-34s %-28s %-14s %-14s\n", "Material Cost", "N/A", CostEstimator.format_musd(prod_cost_components(6) / prod_qty), CostEstimator.format_musd(prod_cost_components(6)));
            fprintf("%-34s %-28s %-14s %-14s\n", "Avionics Cost", sprintf("%d lbs. ea., %s lbs. total", round(avionics_weight * 2.20462), CostEstimator.format_int(round(prod_qty * avionics_weight * 2.20462))), CostEstimator.format_musd(prod_cost_components(5) / prod_qty), CostEstimator.format_musd(prod_cost_components(5)));
            fprintf("%-34s %-28s %-14s %-14s\n", "Engine Cost", sprintf("2 ea., %d total", 2 * prod_qty), CostEstimator.format_musd(prod_engine_cost / prod_qty), CostEstimator.format_musd(prod_engine_cost));
            fprintf("%-34s %-28s %-14s %-14s\n", "Spares + Upfront Acquisition Costs", "10% of acquisition", CostEstimator.format_musd(spares_cost / prod_qty), CostEstimator.format_musd(spares_cost));

            test_cost = test_program_cost;
        end % cost_raymer

        function hours = hours_raymer(params)
            % Numbers referenced from RAND Corporation DAPCA IV model
            hours = [5.18 * prod(params.^[0.777 0.894 0.163]) % engineering hours
                     7.22 * prod(params.^[0.777 0.696 0.263]); % tooling hours
                     10.5 * prod(params.^[0.82 0.484 0.641])]; % manufacturing hours
            hours(4) = 0.133 * hours(3); % QC hours, 0.076 if cargo aircraft
        end

        function total_os_cost = cost_operations_support(fleet_qty, service_life_years, annual_flight_hours_per_aircraft, unit_consumption_cost_per_fh, mission_capable_rate, annual_support_labor_hours_per_aircraft, maintenance_mmh_per_fh, labor_rate_per_hour, carrier_ops_cost_per_fh, csi_fraction_of_acquisition, acquisition_cost)
            % COST_OPERATIONS_SUPPORT Estimates lifecycle military O&S cost
            % for an autonomous, carrier-operated combat aircraft fleet.
            %
            % Reference basis (military only, no civilian/passenger/cargo CERs):
            % 1) DoD O&S element structure (unit-level consumption, depot,
            %    sustaining support, continuing system improvements, indirect support).
            %    https://www.acqnotes.com/acqnote/tasks/operating-and-support-cost
            % 2) O&S cost drivers (fleet size, flying hours, mission capability,
            %    maintenance burden) from GAO weapon-system sustainment review.
            %    https://www.gao.gov/products/gao-23-106217
            % 3) Continuing modernization pressure in advanced tactical aircraft
            %    sustainment (F-35 Block 4 + logistics modernization context).
            %    https://www.gao.gov/products/gao-22-105128
            % 4) Carrier-based unmanned operations include mission-control
            %    system and deck integration burden (MQ-25 / UMCS context).
            %    https://www.navair.navy.mil/product/MQ-25A-Stingray
            arguments
                fleet_qty (1,1) double {mustBePositive}
                service_life_years (1,1) double {mustBePositive}
                annual_flight_hours_per_aircraft (1,1) double {mustBeNonnegative}
                unit_consumption_cost_per_fh (1,1) double {mustBeNonnegative}
                mission_capable_rate (1,1) double {mustBeGreaterThanOrEqual(mission_capable_rate, 0), mustBeLessThanOrEqual(mission_capable_rate, 1)}
                annual_support_labor_hours_per_aircraft (1,1) double {mustBeNonnegative}
                maintenance_mmh_per_fh (1,1) double {mustBeNonnegative}
                labor_rate_per_hour (1,1) double {mustBeNonnegative}
                carrier_ops_cost_per_fh (1,1) double {mustBeNonnegative}
                csi_fraction_of_acquisition (1,1) double {mustBeGreaterThanOrEqual(csi_fraction_of_acquisition, 0), mustBeLessThanOrEqual(csi_fraction_of_acquisition, 1)}
                acquisition_cost (1,1) double {mustBeNonnegative}
            end

            % Realized lifecycle utilization reflects achievable readiness.
            lifecycle_flight_hours = fleet_qty * service_life_years * annual_flight_hours_per_aircraft * mission_capable_rate;

            % DoD-style O&S elements.
            unit_level_consumption = lifecycle_flight_hours * unit_consumption_cost_per_fh;
            maintenance_labor = lifecycle_flight_hours * maintenance_mmh_per_fh * 70;
            support_labor = fleet_qty * service_life_years * annual_support_labor_hours_per_aircraft * labor_rate_per_hour;
            carrier_integration_ops = lifecycle_flight_hours * carrier_ops_cost_per_fh;

            % Military fighter sustainment fractions (not civilian CERs).
            depot_maintenance = 0.30 * (unit_level_consumption + maintenance_labor);
            sustaining_support = 0.07 * acquisition_cost;
            continuing_system_improvements = csi_fraction_of_acquisition * acquisition_cost;
            support_overhead = 0.12 * (unit_level_consumption + maintenance_labor + support_labor + depot_maintenance);

            total_os_cost = unit_level_consumption + maintenance_labor + support_labor + ...
                            carrier_integration_ops + depot_maintenance + ...
                            sustaining_support + continuing_system_improvements + ...
                            support_overhead;

            os_per_aircraft = total_os_cost / fleet_qty;
            annual_os = total_os_cost / service_life_years;

            unit_unit_level_consumption = unit_level_consumption / fleet_qty;
            unit_maintenance_labor = maintenance_labor / fleet_qty;
            unit_support_labor = support_labor / fleet_qty;
            unit_carrier_integration_ops = carrier_integration_ops / fleet_qty;
            unit_depot_maintenance = depot_maintenance / fleet_qty;
            unit_sustaining_support = sustaining_support / fleet_qty;
            unit_continuing_system_improvements = continuing_system_improvements / fleet_qty;
            unit_support_overhead = support_overhead / fleet_qty;

            fprintf("\n%-40s %-22s %-14s %-14s\n", "O&S Item", "Driver", "Unit Cost", "Total Cost");
            fprintf("%-40s %-22s %-14s %-14s\n", "Unit-Level Consumption", CostEstimator.format_hours(lifecycle_flight_hours), CostEstimator.format_musd(unit_unit_level_consumption), CostEstimator.format_musd(unit_level_consumption));
            fprintf("%-40s %-22s %-14s %-14s\n", "Maintenance Labor", sprintf("%.1f MMH/FH", maintenance_mmh_per_fh), CostEstimator.format_musd(unit_maintenance_labor), CostEstimator.format_musd(maintenance_labor));
            fprintf("%-40s %-22s %-14s %-14s\n", "Autonomous Mission Support Labor", sprintf("%.0f h/aircraft/yr", annual_support_labor_hours_per_aircraft), CostEstimator.format_musd(unit_support_labor), CostEstimator.format_musd(support_labor));
            fprintf("%-40s %-22s %-14s %-14s\n", "Carrier Integration / Deck Ops", CostEstimator.format_hours(lifecycle_flight_hours), CostEstimator.format_musd(unit_carrier_integration_ops), CostEstimator.format_musd(carrier_integration_ops));
            fprintf("%-40s %-22s %-14s %-14s\n", "Depot Maintenance", "30% of consume+maint", CostEstimator.format_musd(unit_depot_maintenance), CostEstimator.format_musd(depot_maintenance));
            fprintf("%-40s %-22s %-14s %-14s\n", "Sustaining / Indirect Support", "7% + 12% burden", CostEstimator.format_musd((unit_sustaining_support + unit_support_overhead)), CostEstimator.format_musd(sustaining_support + support_overhead));
            fprintf("%-40s %-22s %-14s %-14s\n", "Continuing System Improvements", sprintf("%.0f%% of acquisition", 100 * csi_fraction_of_acquisition), CostEstimator.format_musd(unit_continuing_system_improvements), CostEstimator.format_musd(continuing_system_improvements));
            fprintf("%-40s %-22s %-14s %-14s\n", "TOTAL O&S (Lifecycle)", sprintf("%d aircraft x %.0f years", round(fleet_qty), service_life_years), CostEstimator.format_musd(os_per_aircraft), CostEstimator.format_musd(total_os_cost));
            fprintf("%-40s %-22s %-14s %-14s\n", "TOTAL O&S (Annualized Fleet)", sprintf("%.0f years", service_life_years), CostEstimator.format_musd(annual_os / fleet_qty), CostEstimator.format_musd(annual_os));
        end
    
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
        end % cost_alromaihi_weight

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
        end % cost_alromaihi_partsize

        function output = format_c(value)
            locale = java.util.Locale.US;
            currency_format = java.text.NumberFormat.getCurrencyInstance(locale);
            output = currency_format.format(value);
        end

        function output = format_musd(value)
            locale = java.util.Locale.US;
            number_format = java.text.NumberFormat.getNumberInstance(locale);
            number_format.setGroupingUsed(true);
            number_format.setMaximumFractionDigits(2);
            number_format.setMinimumFractionDigits(0);
            output = "$" + string(number_format.format(value / 1e6)) + "M";
        end

        function output = format_hours(value)
            output = sprintf("%.2f x 10^6 hours", value / 1e6);
        end

        function output = format_int(value)
            locale = java.util.Locale.US;
            number_format = java.text.NumberFormat.getIntegerInstance(locale);
            number_format.setGroupingUsed(true);
            output = string(number_format.format(value));
        end
    end
end