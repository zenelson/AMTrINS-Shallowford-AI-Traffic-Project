function [Agent,Split,upProbMat,stateProb] = VSMUpdateV6(Split,Agent,timecheck,timeGap)
%VSMUpdateV6 Processes and predictings upcoming vehicles
%   This function uses several loops, SUMO, and recurring data to track and
%   maintain an estimate of all the traffic approaching an intersection.
%   This is relevant for the prediction of incoming traffic to train 

newData(1).data = {};
newData(2).data = {};
newData(3).data = {};
newData(4).data = {};
newData(5).data = {};
newData(6).data = {};
newData(7).data = {};
newData(8).data = {};
upProbMat = nan;
stateProb = nan;
if rem(timecheck,timeGap)==0
    
    %% Second Step: Update Agent Data
    Count = zeros(1,numel(Split)*2);
    for i=1:numel(Split)
        Split(i).newData = traci.edge.getLastStepVehicleIDs(Split(i).ID);    
        newVeh = numel(Split(i).newData)-numel(intersect(Split(i).newData,Split(i).oldData));
        Split(i).oldData = Split(i).newData;
        Split(i).newVeh = newVeh;
        % Use simplified version of Q-learning to update Ratio
        if abs(Split(i).newRatio - Split(i).Ratio) > Split(i).errorMargin
            Split(i).Ratio = Split(i).newRatio;
        end
        if newVeh>0
            for k=1:newVeh
                s=rand;
                if s < Split(i).Ratio 
                    Count((2*i)) = Count((2*i)) + 1; %Through Turn Traffic
                else
                    Count(((2*i)-1)) = Count(((2*i)-1)) + 1; %Left Turn Traffic
                end
            end
        end
    end
    for i=1:numel(Split)
        k = 2*i;
        j = k-1;
            Agent(k).validSensors.queueCount = 0;
            for z=1:numel(Agent(k).validSensors.ID)
                Agent(k).validSensors.queueCount = Agent(k).validSensors.queueCount + traci.lanearea.getLastStepVehicleNumber(Agent(k).validSensors.ID{z});
            end
            Agent(j).validSensors.queueCount = 0;
            for z=1:numel(Agent(j).validSensors.ID)
                Agent(j).validSensors.queueCount = Agent(j).validSensors.queueCount + traci.lanearea.getLastStepVehicleNumber(Agent(j).validSensors.ID{z});
            end
            if Agent(k).validSensors.Saturated == 0
                Agent(k).validSensors.Saturated = Agent(k).validSensors.queueCount>=Agent(k).validSensors.Threshold;
            end
            if Agent(j).validSensors.Saturated == 0
                Agent(j).validSensors.Saturated = Agent(j).validSensors.queueCount>=Agent(j).validSensors.Threshold;
            end
 


        [Service1,newData(j).data] = serviceCheck_v2(Agent(j).Sensors.oldData,Agent(j).laneIDs,Agent(j).edgeID);
        Agent(j).Sensors.newData = newData(j).data;
        Agent(j).Service = Agent(j).Service + Service1;
        
        [Service2,newData(k).data] = serviceCheck_v2(Agent(k).Sensors.oldData,Agent(k).laneIDs,Agent(k).edgeID);
        Agent(k).Sensors.newData = newData(k).data;
        Agent(k).Service = Agent(k).Service + Service2;
        
        Split(i).headCount = Split(i).headCount - Agent(j).Service - Agent(k).Service;
        %This code repositioned because it may work better if queues are
        %serviced/reduced before validateCheck.m, given that Headcount is
        %accounting for serviced vehicles
        [Agent(j).Queue,Agent(j).Active] = serviceClean(Agent(j).Service,Agent(j).Queue,Agent(j).Active);
        Agent(j).oldQueue = Agent(j).Queue;
        
        [Agent(k).Queue,Agent(k).Active] = serviceClean(Agent(k).Service,Agent(k).Queue,Agent(k).Active);
        Agent(k).oldQueue = Agent(k).Queue;
        
        if isempty(Agent(k).Active) && isempty(Agent(j).Active)
            if Agent(k).Queue < 0
                Agent(j).Queue = Agent(j).Queue - Agent(k).Queue;
                Agent(k).Queue = 0;
            elseif Agent(j).Queue <0
                Agent(k).Queue = Agent(k).Queue - Agent(j).Queue;
                Agent(j).Queue = 0;
            end
            Agent(j).oldQueue = Agent(j).Queue;
            Agent(k).oldQueue = Agent(k).Queue;
        end
        
        
        [Agent(k),Agent(j),Ratio] = validateCheck_V8(Agent(k),Agent(j),Split(i));%.headCount);
        if Ratio >=0
            Split(i).newRatio = (1-Split(i).UpdateWeight)*Split(i).newRatio + Split(i).UpdateWeight*Ratio;
        end
        Split(i).headCount = Split(i).headCount + Split(i).newVeh;
        
        for j=0:1
            k = 2*i - 1 + j;
            if ~isempty(Agent(k).Active)
                Agent(k).Active = circshift(Agent(k).Active,-1);
                Agent(k).Active(end) = Count(k); 
                Agent(k).Number = circshift(Agent(k).Number,-1);
                Agent(k).Number(end) = Count(k);
            end
            clc
            if ~Agent(k).validSensors.Saturated
                queuecount = 0;
                for z=1:numel(Agent(k).validSensors.ID)
                    queuecount = queuecount + traci.lanearea.getLastStepVehicleNumber(Agent(k).validSensors.ID{z});
                end

                Agent(k).Queue = queuecount;
            else
                Agent(k).Queue = Agent(k).Queue;
            end
            
            % Historic Catalog
            Agent(k).backup.Queue = Agent(k).oldQueue;
            Agent(k).backup.dur = Agent(k).dur;
            Agent(k).backup.queueOG = Agent(k).queueOG;
            Agent(k).backup.Active = Agent(k).Active;
            Agent(k).backup.Count = Count(k);
            Agent(k).backup.DelayHistory = Agent(k).DelayHistory;
            Agent(k).backup.Service = Agent(k).Service;
        
            dur = Agent(k).dur;
            queueOG = Agent(k).queueOG;
            state = Agent(k).stateLight;
            %% Diagnostic Code
            %%
            if ~isempty(Agent(k).Active)
                [estQueue,Agent(k).Active,oldActive,queueMat,Agent(k).dur,Agent(k).queueOG] = validateProcV3(Agent(k).Queue,Agent(k).GapMap,Agent(k).Active,Agent(k).obsWindow,Agent(k).vehLength,Agent(k).vehGap,Agent(k).numLanes,1,Agent(k).absVal,Agent(k).divisionPoint,Agent(k).Cycle,state,queueOG,dur);
                
               
                [upProbMat,stateProb] = upProbBuild(queueMat,oldActive,Agent(k).Queue,Count(k),Agent(k).numLanes,Agent(k).vehLength,Agent(k).vehGap,Agent(k).obsWindow,Agent(k).GapMap,Agent(k).absVal);
                [shortVal,state] = nextStateProb(upProbMat,estQueue,Agent(k).numLanes);
                [~,Agent(k).ActivatedQueue,Agent(k).ActivatedShortProb,Agent(k).ActiveDelay] = ActivePredictor(Agent(k));
                stateProb = stateProb(1,2);
            else
                estQueue = Agent(k).Queue;
                stateProb = min(Agent(k).Queue./(Agent(k).numLanes*4),1);
                shortVal = max(min((Agent(k).Queue-4*Agent(k).numLanes)./(Agent(k).numLanes*4),1),0);
                if Agent(k).Queue> 4*Agent(k).numLanes
                    state = 1;
                else
                    state = 0;
                end
                Agent(k).ActivatedQueue = max(Agent(k).Queue-4*Agent(k).numLanes,0);
                Agent(k).ActivatedShortProb = shortVal;
                actCount = min(sum(Agent(k).DelayHistory),Agent(k).Queue);
                ActiveFuture = circshift(Agent(k).DelayHistory,-1);
                z = 1;
                while actCount>0
                    tmp = max(0,actCount-ActiveFuture(z));
                    ActiveFuture(z) = max(0,ActiveFuture(z)-actCount);
                    actCount = tmp;
                    z = z+1;
                end
                Agent(k).ActiveDelay = 0;
                Agent(k).ActiveDelay = ActiveFuture*Agent(k).DelayVal';
            end
            queueDiff = max(0,estQueue-Agent(k).oldQueue);
            Agent(k).Queue = max(estQueue,Agent(k).Queue);
            Agent(k).Sensors.oldData = newData(k).data;
            Agent(k).upProbMat = upProbMat;
            Agent(k).longProb = circshift(Agent(k).longProb,-1);
            Agent(k).longProb(end) = stateProb;%(1,2);
            Agent(k).stateProb = mean(Agent(k).longProb);
            Agent(k).shortProb = shortVal;
            Agent(k).oldService = Agent(k).Service;
            Agent(k).state = state;
            Agent(k).DelayHistory = circshift(Agent(k).DelayHistory,-1);
            if Agent(k).DelayHistory(end) > 0
                Agent(k).DelayHistory(1) = Agent(k).DelayHistory(1) + Agent(k).DelayHistory(end);
                Agent(k).DelayHistory(end) = 0;
            end
            Agent(k).DelayHistory(end) = queueDiff;
            if Agent(k).Queue < sum(Agent(k).DelayHistory)
                error = sum(Agent(k).DelayHistory) - (Agent(k).Queue);
                z = 0;
                while error>0
                    arraydiff = max(0,Agent(k).DelayHistory(end-z)-error);
                    error = error - Agent(k).DelayHistory(end-z);
                    Agent(k).DelayHistory(end-z) = arraydiff;
                    if z == (length(Agent(k).DelayHistory)-1) || error<1
                        break
                    end
                    z = z + 1;
                end
            end
            if sum(Agent(k).DelayHistory) < Agent(k).Queue
                diff = Agent(k).Queue - sum(Agent(k).DelayHistory);
                Agent(k).DelayHistory(end) = Agent(k).DelayHistory(end) + diff;
            end
            service = Agent(k).Service;
            z=1;
            array = Agent(k).DelayHistory;
            while service>0
                arraydiff = max(0,array(z)-service);
                service = service-array(z);
                array(z) = arraydiff;
                
                if z==length(array)|| service<1 
                    break
                end
                z = z + 1;
            end
            Agent(k).DelayHistory = array;
            Agent(k).DelayFuture = circshift(Agent(k).DelayHistory,-1);
            if Agent(k).DelayFuture(end) > 0
                Agent(k).DelayFuture(1) = Agent(k).DelayFuture(1) + Agent(k).DelayFuture(end);
                Agent(k).DelayFuture(end) = upProbMat(find(upProbMat==max(upProbMat(:,1)),1),2);%0;
            end
            Agent(k).Service = 0;
            Agent(k).maxDelay = Agent(k).waitTime(find(fliplr(Agent(k).DelayHistory),1,'first'));
            if isempty(Agent(k).maxDelay)
                Agent(k).maxDelay = 0;
            end
            if Agent(k).state == 0 && Agent(k).maxDelay >= 60
                Agent(k).state = 1;
            end
        end
    end
else
    for i=1:4
        for j=0:1
            k = 2*i - 1 + j;
            [Service,newData(k).data] = serviceCheck_v2(Agent(k).Sensors.oldData,Agent(k).laneIDs,Agent(k).edgeID);
            Agent(k).Service = Agent(k).Service + Service;
            Agent(k).Sensors.oldData = newData(k).data;
            %% Update Validation Sensors
            sensTot = {};
            for x=1:numel(Agent(k).validSensors.ID)
                sens = traci.lanearea.getLastStepVehicleIDs(Agent(k).validSensors.ID{x});
                sensTot = [sensTot,sens];
            end
                newIDs = numel(sensTot)-sum(ismember(sensTot,Agent(k).validSensors.oldData));
                Agent(k).validSensors.Count = Agent(k).validSensors.Count + newIDs;
                Agent(k).validSensors.oldData = sensTot;

            
        end
    end
end
end

