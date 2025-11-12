function [endState] = fastSampleExperimental(randVal,P)
%fastSampleExperimental Bolster random sample rate
%   Somewhat outdated, but the concept was to utilize logarithmic search
%   metrics to bolster average search rate to improve computation rate
endState = 256;
start = max(find(P,1),2);
for k = start:256
        P(k) = P(k)+P(k-1);
    if P(k)> randVal
        endState = k;
        break
    end
end
end

