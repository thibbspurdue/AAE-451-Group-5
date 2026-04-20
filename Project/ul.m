function output = ul(input, units, preserve_units)
arguments
    input
    units = 'SI'
    preserve_units = false
end
% UL Removes units from a symbolic variable and returns the unitless
% expression as a double. Returns the unmodified argument if no units are
% attached. Converts the units if the second argument is provided. If the input is not symbolic, it is returned unchanged. If the input is symbolic but has no units, it is returned unchanged. If the input is symbolic and has units, the units are converted to the specified system (if provided) and then removed, returning the magnitude as a double. If preserve_units is true, the output will retain the specified units instead of converting to a double. Supported unit systems include 'SI', 'CGS (centimeter-gram-second)', 'US' (United States customary), 'ESU' (electrostatic units), 'GU' (Gaussian units), and 'EMU' (electromagnetic units). If an unsupported unit system is specified, the function will attempt to convert to the specified units without a predefined system.
% 
% https://www.mathworks.com/help/symbolic/units-list.html#mw_6567b974-b766-4942-bf6d-d787c12778e3
    if ~isa(input, 'sym')
        output = input;
    else
        [input_magnitude, input_units] = separateUnits(input);
        if ismember(units, ['SI', 'CGS', 'US', 'ESU', 'GU', 'EMU'])
            output = simplify(unitConvert(input_units, units, 'Derived'));
        else
            output = simplify(unitConvert(input_units, units));
        end
        output = output .* input_magnitude;
        if ~preserve_units
            output = double(separateUnits(output));
        end
    end
end