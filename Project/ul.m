function output = ul(input, units, preserve_units)
arguments
    input
    units = 'SI'
    preserve_units = false
end
% UL Removes units from a symbolic variable and returns the unitless
% expression as a double. Returns the unmodified argument if no units are
% attached.
% 
% https://www.mathworks.com/help/symbolic/units-list.html#mw_6567b974-b766-4942-bf6d-d787c12778e3
    if ~isa(input, 'sym')
        output = input;
    else
        [input_magnitude, input_units] = separateUnits(input);
        if ismember(units, ['SI', 'CGS', 'US', 'ESU', 'GU', 'EMU'])
            output = simplify(unitConvert(input_units, units, 'Derived'));
        else
            output = simplify(UnitConvert(input_units, unit));
        end
        output = output * input_magnitude;
        if ~preserve_units
            output = double(separateUnits(output));
        end
    end
end