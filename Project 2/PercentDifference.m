function pdiff = PercentDifference(array)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    pdiff = zeros(size(array));
    pdiff(1) = NaN;
    for j=2:max(size(array))
        pdiff(j) = 100*2*(array(j)-array(j-1))/(array(j)+array(j-1));
    end
end