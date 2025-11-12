function [vals,state] = nextStateProb(upProbMat,estQueue,numLanes)
%nextStateProb Returns the probability of full/empty transitions
%   The program evalautes the upProbMat matrix to decide the total
%   probability that a state may transition from empty to full
FullVal = 4*numLanes;
if estQueue < FullVal
    state = 0;
    rem = FullVal - estQueue;
    idx = find(upProbMat(:,1) >= rem);
    if ~isempty(idx)
        vals = sum(upProbMat(idx,2));
    else
        vals = 0;
    end
else
    state = 1;
    if estQueue >= (2*FullVal)
        vals = 1;
    else
        rem = (2*FullVal) - estQueue;
        idx = find(upProbMat(:,1) >= rem);
        if ~isempty(idx)
            vals = 0;
        else
            vals = sum(upProbMat(idx,2));
        end
    end
end
end

