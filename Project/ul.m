function output = ul(input)
% UL Removes units from a symbolic variable and returns the unitless
% expression as a double.
    output = double(separateUnits(input));
end