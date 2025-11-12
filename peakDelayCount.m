function [Output] = peakDelayCount(oldData,Agent)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
Output = 0;
newdata = traci.edge.getLastStepVehicleIDs(Agent.edgeID{1});
for i=1:numel(oldData(:,1))
    check = ismember(oldData{i,1},newdata);
    if check==false && numel(oldData)>1
        Output = Output + oldData{i,2};
    end
end
end

