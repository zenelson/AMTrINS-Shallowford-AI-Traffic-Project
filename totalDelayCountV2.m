function [maxCount,totalCount,newcell] = totalDelayCountV2(oldData,Agent)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%NOTE: This is a version to try and differentiate left and through turns
newdata = traci.edge.getLastStepVehicleIDs(Agent.edgeID{1});
newcell = cell(numel(newdata),2);
newcell(:,1) = newdata;
newcell(:,2) = num2cell(zeros(numel(newdata),1));
% if contains(Agent.Name,'Left')
%     dir = 'L';
% elseif contains(Agent.Name,'Through')
%     dir = 'T';
% else
%     error('Misnamed Variables Detected!')
% end
dir = Agent.routeIDs;
for i=1:numel(newdata)
    [Lia,Loc] = ismember(newdata{i},oldData(:,1));
    if Lia==true 
        if oldData{Loc,2} > 0
            newcell{i,2} = oldData{Loc,2} + 1;
        else
            vel = traci.vehicle.getSpeed(newdata{i});
            route = traci.vehicle.getRouteID(newdata{i});
            if vel < 0.5*Agent.Velocity && contains(route,dir)
                newcell{i,2} = 1;
            end
        end
    else
        vel = traci.vehicle.getSpeed(newdata{i});
        if vel < 0.5*Agent.Velocity && contains(newdata{i},dir)%&& vel > 0
            newcell{i,2} = 1;
        end
    end
end
count = cell2mat(newcell(:,2));
if isempty(count)
    maxCount = 0;
    totalCount = 0;
else
    maxCount = max(count);
    totalCount = sum(count);
end
end

