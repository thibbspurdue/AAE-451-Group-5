function [l_t, l_h, l_v, S_h, S_t] = Parameters_rebalance(l_t, l_v, x_ac, S_t, S_v)
%PARAMETERS_REBALANCE
%   This changes around the variables from the parameters into ones
%   recognized by typical aae convention

%Change lever arm from starting at leading edge to ac
l_t = l_t - x_ac;
l_v = l_v - x_ac;

%Create a unified tail
l_h = l_t;
S_h = S_t;
S_t = S_h + S_v;

l_t = (S_h*l_h + S_v*l_v)/S_t;
end

