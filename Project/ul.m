function output = ul(input, units)
arguments
    input
    units = 'SI'
end
% UL Removes units from a symbolic variable and returns the unitless
% expression as a double. Returns the unmodified argument if no units are
% attached.
% 
% https://www.mathworks.com/help/symbolic/units-list.html#mw_6567b974-b766-4942-bf6d-d787c12778e3
    if ~isa(input, 'sym')
        output = input;
    else
        if ismember(unitType, ['SI', 'CGS', 'US', 'ESU', 'GU', 'EMU'])
            output = double(separateUnits(simplify(unitConvert(input, units, 'Derived'))));
        else
            output = double(separateUnits(simplify(UnitConvert(input, units))));
        end
    end
end