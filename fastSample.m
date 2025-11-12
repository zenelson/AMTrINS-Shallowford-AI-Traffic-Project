function [endState] = fastSample(randVal, P,~)
%fastSample Attempt to quickly process new samples
% Generate a method to quickly process output of a random sample. The
% purpose of this was to attempt and reduce the cumulative runtime costed
% by running this search so many times per Dyna-Q simulation


allStateIndeces = 1:256; 

endStateIndeces = allStateIndeces(P~=0);
nonZeroPs = P(endStateIndeces);



for i = 2:length(nonZeroPs)
    nonZeroPs(i) = nonZeroPs(i) + nonZeroPs(i-1); 
end
if length(nonZeroPs) == 1
    endState = endStateIndeces;
else
    endState = endStateIndeces(max(sum((nonZeroPs-randVal)<0),1));%+1);
end
end