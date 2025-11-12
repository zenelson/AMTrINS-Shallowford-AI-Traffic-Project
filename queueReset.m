function [Agent] = queueReset(Agent,action)
%queueReset This program is intended to re-run queue predictions for lanes
%that were designated as "active" rather than "inactive"
%   
%   This is a function-based version of "V5QueueTestBench.m"

if action == 1
    idx = [2,6];
elseif action == 2
    idx = [1,5];
elseif action == 3
    idx = [1,2];
elseif action == 4
    idx = [5,6];
elseif action == 5
    idx = [4,8];
elseif action == 6
    idx = [3,7];
elseif action == 7
    idx = [3,4];
elseif action == 8
    idx = [7,8];
else
    error('Invalid Action Selected');
end
for i=1:8
    k = i;
    if ismember(i,idx)
        Agent(k).Queue = Agent(k).backup.Queue;
        Agent(k).dur = Agent(k).backup.dur;
        Agent(k).queueOG = Agent(k).backup.queueOG;
        Agent(k).Active = Agent(k).backup.Active;
        Count(k) = Agent(k).backup.Count;
        Agent(k).DelayHistory = Agent(k).backup.DelayHistory;
        Agent(k).Serivce = Agent(k).backup.Service;
        service = Agent(k).backup.Service;
        dur = Agent(k).dur;
        queueOG = Agent(k).queueOG;
        if Agent(i).dur > 0
            Agent(i).stateLight = repmat('G',1,Agent(i).Cycle);
        else
            Agent(i).stateLight = append(repmat('3',1,3),repmat('G',1,Agent(i).Cycle-3));
        end
        state = Agent(k).stateLight;
        [estQueue,Agent(k).Active,oldActive,queueMat,Agent(k).dur,Agent(k).queueOG] = validateProcV3(Agent(k).Queue,Agent(k).GapMap,Agent(k).Active,Agent(k).obsWindow,Agent(k).vehLength,Agent(k).vehGap,Agent(k).numLanes,1,Agent(k).absVal,Agent(k).divisionPoint,Agent(k).Cycle,state,queueOG,dur);
        queueDiff = max(0,estQueue-Agent(k).Queue);
        Agent(k).Queue = estQueue;
        Agent(k).DelayHistory = circshift(Agent(k).DelayHistory,-1);
        if Agent(k).DelayHistory(end) > 0
            Agent(k).DelayHistory(1) = Agent(k).DelayHistory(1) + Agent(k).DelayHistory(end);
            Agent(k).DelayHistory(end) = 0;
        end
        Agent(k).DelayHistory(end) = queueDiff;
        z=1;
        if sum(Agent(k).DelayHistory) < Agent(k).Queue
            diff = Agent(k).Queue - sum(Agent(k).DelayHistory);
            Agent(k).DelayHistory(end) = Agent(k).DelayHistory(end) + diff;
        end
        array = Agent(k).DelayHistory;
        while service>0
            a = max(0,array(z)-service);
            service = service-array(z);
            array(z) = a;
            z = z + 1;
            if z==length(array)
                break
            end
        end
        Agent(k).DelayHistory = array;
        Agent(k).maxDelay = Agent(k).waitTime(find(fliplr(Agent(k).DelayHistory),1,'first'));
        if isempty(Agent(k).maxDelay)
            Agent(k).maxDelay = 0;
        end
        Agent(k).Delay = Agent(k).DelayHistory*Agent(k).DelayVal';
        Agent(k).Service = 0; %Placeholder to try and fix an overloading error
    else
        Agent(i).stateLight = 'rrrrrrrrrrrrr';
    end
end
end



