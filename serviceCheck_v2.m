function [output,newIDs] = serviceCheck_v2(oldIDs,laneareaID,edgeID)
%serviceCheck_v2 Assess and track how many vehicles have left an lane
%   This program utilizes SUMO programs to track all vehicles that have
%   successfully crossed the threshold of a roadway and have now been
%   considered "serviced" by the intersection.

vehCount = zeros(1,1+numel(laneareaID));
    %% Assess Number of vehicles in each lane
for i=1:numel(laneareaID)
    vehCount(i+1) = vehCount(i)+traci.lane.getLastStepVehicleNumber(laneareaID{i});
end
    %% Pre-allocate cell array size for vehicle IDs
newIDs = cell(sum(vehCount),1);
    %Insert values for each section
for i = 1:numel(laneareaID)
    newIDs((vehCount(i)+1):vehCount(i+1)) =traci.lane.getLastStepVehicleIDs(laneareaID{i});
end
newIDs=newIDs(~cellfun('isempty',newIDs));
edgesID = traci.edge.getLastStepVehicleIDs(edgeID{1});
    %Assess total service rate
output = numel(oldIDs) - numel(intersect(oldIDs,edgesID));


end