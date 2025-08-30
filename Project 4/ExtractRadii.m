function [r_in,r_out] = ExtractRadii(r_array)
% Returns arrays of the inner and outer radius from the design variable array 
% Input
%   r_array = array of radius design variables
% Outputs
%     r_in = array of inner radii
%     r_out = array of outer radii

    r_in = r_array(1:end/2);
    r_out = r_array(end/2+1:end);
end