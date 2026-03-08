function output = ul(input)
% UL Removes units from a symbolic variable and returns the unitless
% expression as a double. Returns the unmodified argument if no units are
% attached.
% 
% https://www.mathworks.com/help/symbolic/units-list.html#mw_6567b974-b766-4942-bf6d-d787c12778e3
    if ~isa(input, 'sym')
        output = input;
    else
        output = double(separateUnits(simplify(unitConvert(input, 'SI', 'Derived'))));
    end
end