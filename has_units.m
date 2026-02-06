function output = has_units(input)
% HAS_UNITS Evaluates if the input is a symbolic variable with units.
    output = ~isempty(findUnits(input));
end