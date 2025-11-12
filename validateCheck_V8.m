function [Agent1,Agent2,Ratio] = validateCheck_V8(Agent1,Agent2,Split)
%validateCheck_V8 attempts to make any necessary adjustments to the
%environment based on sensors. The goal is to recalibrate the environment
%based on observed information.

% This program is meant as a method to help stabilize and maintain
% measurements of vehicles along a roadway. When systems become overloaded,
% there is a tendency to fail and forget vehicles, resulting in sub-optimal
% performance of the RL program. The program is now designed to account for
% various configurations and policies based on the saturation point of both
% left and through traffic.

%%Import Data
Sensor1 = Agent1.validSensors.ID; %Identify Through traffic sensors
Sensor2 = Agent2.validSensors.ID; %Identify Left traffic sensors

sens1Tot = {}; %Initialize Through Sensor Data
sens2Tot = {}; %Initialize Left Sensor Data

num1 = Agent1.Number; %Import Through Segment Data
num2 = Agent2.Number; %Import Left Segment Data

Headcount = Split.headCount;

%% Measure Influx of Vehicles on Sensors
for i=1:numel(Sensor1) %For Each Sensor in Through Sensor List
    sens = traci.lanearea.getLastStepVehicleIDs(Sensor1{i}); %Record all vehicle IDs along a sensor
    sens1Tot = [sens1Tot,sens]; %Compile all vehicle IDs
end
newIDs1 = numel(sens1Tot) - sum(ismember(sens1Tot,Agent1.validSensors.oldData)); %Identify the latest influx of through traffic
Agent1.validSensors.oldData = sens1Tot; %Update Influx Data

for i=1:numel(Sensor2) %For Each Sensor in Left Sensor List
    sens = traci.lanearea.getLastStepVehicleIDs(Sensor2{i});
    sens2Tot = [sens2Tot,sens];
end
newIDs2 = numel(sens2Tot) - sum(ismember(sens2Tot,Agent2.validSensors.oldData));
Agent2.validSensors.oldData = sens2Tot;

%% Measure Ratio based on recent data
Count1 = Agent1.validSensors.Count + (newIDs1);
Count2 = Agent2.validSensors.Count + (newIDs2);
if Count1+Count2>0% && Agent1.validSensors.Saturated == 0 && Agent2.validSensors.Saturated == 0
    Ratio = (Count1 / (Count1+Count2));
else
    Ratio = -1;
end
%% Recalibration Setup
%Currently unclear but somewhere the queue prediction is deleting vehicles
%in the number array, this is meant as a safeguard in the meantime
num1 = max(num1,0);
num2 = max(num2,0);
if isempty(num1) || isempty(num2)
    Agent1.Queue = Count1;
    Agent2.Queue = Count2;
    diff = Headcount-Count1-Count2;
    AG1 = round(diff*Split.newRatio);
    AG2 = diff - AG1;
    Agent1.Queue = Agent1.Queue + AG1;
    Agent2.Queue = Agent2.Queue + AG2;
else
    %% Scenario 1: Both Lanes are Unsaturated
    if Agent1.validSensors.Saturated == 0 && Agent2.validSensors.Saturated == 0
        if Count1 > sum(num1(1:2))  %If Through traffic is higher than expected
            diff = Count1 - sum(num1(1:2));   %Calculate the difference
            num1(1) = Count1;          %Update the value
            num2(1) = max(num2(1) - diff,0);     %Update the neighboring value
            if num2(1)-diff < 0
                num2(2) = num2(2) + num2(1) - diff;
            end
            Agent1.Number = num1;
            Agent2.Number = num2;
        elseif Count2 > sum(num2(1:2)) %If Left traffic is higher than expected
            diff = Count2 - sum(num2(1:2));   %Calculate the difference
            num2(1) = Count2;          %Update the value
            num1(1) = max(num1(1) - diff,0);     %Update the neighboring value
            if num1(1) - diff < 0
                num1(2) = num1(2) + num1(1) - diff;
            end
            Agent1.Number = max(0,num1);
            Agent2.Number = max(0,num2);
            Agent1.Active = min(Agent1.Active,num1);
            Agent2.Active = min(Agent2.Active,num2);
        end
        if Count1 < num1(1) && Agent1.validSensors.Saturated == 0 %If No sign of Through traffic measured on sensor
            diff = num1(1)-Count1;
            num2(1) = num2(1) + diff;
        elseif Count2 < num2(1) && Agent2.validSensors.Saturated == 0 %If No sign of Left traffic measured on sensor
            diff = num2(1)-Count2;
            num1(1) = num1(1) + diff;
        end
        %Safeguard to deal with slower vehicles
        if (Count1 + Count2) < (Agent1.Active(1) + Agent2.Active(1))
            Agent1.Active(2) = Agent1.Active(2) + Agent1.Active(1) - Count1;
            Agent1.Number(2) = Agent1.Number(2) + Agent1.Number(1) - Count1;
            Agent2.Active(2) = Agent2.Active(2) + Agent2.Active(1) - Count2;
            Agent2.Number(2) = Agent2.Number(2) + Agent2.Number(1) - Count2;
        end
        Agent1.Number = max(0,num1);
        Agent2.Number = max(0,num2);
        Agent1.Active = min(Agent1.Active,num1);
        Agent2.Active = min(Agent2.Active,num2);
        
        Agent1.validSensors.Count = 0;
        Agent2.validSensors.Count = 0;
        
    elseif Agent1.validSensors.Saturated == 1 && Agent2.validSensors.Saturated == 0
        %% Scenario 2: Through Lane is Saturated, Left Lane is Unsaturated
        if Count2 > sum(num2(1:2)) %If Left Lane experiences more traffic than possible
            diff = Count2 - sum(num2(1:2)); %Reduce queue size of Through Lane, assume it's already added to queue
            num2(1) = Count2;
            % Reduce any
            error = diff;
            z = 0;
            while error>0
                tempdiff = max(0,error-Agent1.DelayHistory(end-z));
                error = error-Agent1.DelayHistory(end-z);
                Agent1.DelayHistory(end-z) = tempdiff;
                if error<1 || z== (length(Agent1.DelayHistory) - 1)
                    break
                    
                end
                z = z+1;
            end
            Agent1.Queue = Agent1.Queue-diff;
        end
        if Count2 < num2(1)
            diff = num2(1)-Count2;
            Agent1.Queue = Agent1.Queue + diff;
            Agent1.DelayHistory(end-2) = Agent1.DelayHistory(end-2) + diff;
        end
        Agent1.Queue = max(Headcount-max(Agent2.Queue,Count2)-sum(Agent1.Active)-sum(Agent2.Active),numel(sens1Tot));
        error = Agent1.Queue - sum(Agent1.DelayHistory); %Check for discrepency in Count
        if error > 0 %If Queue is larger than DelayHistory
            Agent1.DelayHistory(end-2) = Agent1.DelayHistory(end-2) + error;
        elseif error < 0 %If DelayHistory is larger than Queue
            error = abs(error);
            z = 0;
            while error>0
                tempdiff = max(0,error-Agent1.DelayHistory(end-z));
                error = error-Agent1.DelayHistory(end-z);
                Agent1.DelayHistory(end-z) = tempdiff;
                if error<1 || z== (length(Agent1.DelayHistory) - 1)
                    break
                end
                z = z+1;
            end
        end
        Agent2.validSensors.Count = 0;
        if Agent1.Queue < Agent1.validSensors.saturationReset
            Agent1.validSensors.Saturated = 0;
        end
        
    elseif Agent1.validSensors.Saturated == 0 && Agent2.validSensors.Saturated == 1
        %% Scenario 3: Through Lane is UnSaturated, Left Lane is Saturated
        if Count1 > sum(num1(1:2)) %If Left Lane experiences more traffic than possible
            diff = Count1 - sum(num1(1:2)); %Reduce queue size of Through Lane, assume it's already added to queue
            num1(1) = Count1;
            % Reduce any
            error = diff;
            z = 0;
            while error>0
                tempdiff = max(0,error-Agent2.DelayHistory(end-z));
                error = error-Agent2.DelayHistory(end-z);
                Agent2.DelayHistory(end-z) = tempdiff;
                if error<1 || z== (length(Agent2.DelayHistory) - 1)
                    break
                end
                z = z+1;
            end
            Agent2.Queue = Agent2.Queue-diff;
        end
        if Count1 < num1(1)
            diff = num1(1)-Count1;
            Agent2.Queue = Agent2.Queue + diff;
            Agent2.DelayHistory(end-2) = Agent2.DelayHistory(end-2) + diff;
        end
        Agent2.Queue = max(Headcount-max(Agent1.Queue,Count1)-sum(Agent2.Active)-sum(Agent1.Active),numel(sens2Tot));
        error = Agent2.Queue - sum(Agent2.DelayHistory); %Check for discrepency in Count
        if error > 0 %If Queue is larger than DelayHistory
            Agent2.DelayHistory(end-2) = Agent2.DelayHistory(end-2) + error;
        elseif error < 0 %If DelayHistory is larger than Queue
            error = abs(error);
            z = 0;
            while error>0
                tempdiff = max(0,error-Agent2.DelayHistory(end-z));
                error = error-Agent2.DelayHistory(end-z);
                Agent2.DelayHistory(end-z) = tempdiff;
                if error<1 || z== (length(Agent2.DelayHistory) - 1)
                    break
                end
                z = z+1;
            end
        end
        Agent1.validSensors.Count = 0;
        if Agent2.Queue < Agent2.validSensors.saturationReset
            Agent2.validSensors.Saturated = 0;
        end
        
    elseif Agent1.validSensors.Saturated == 1 && Agent2.validSensors.Saturated == 1
        %% Scenario 4:Both Lanes are Saturated and we are completley blind
        Agent1.validSensors.Saturated = Agent1.validSensors.queueCount > Agent1.validSensors.saturationReset;
        Agent2.validSensors.Saturated = Agent2.validSensors.queueCount > Agent2.validSensors.saturationReset;
        % This is meant to re-allocate queue values and information to reflect
        % environment and changes if a lane becomes un-saturated
        if Agent1.validSensors.Saturated == 0
            diff = max(Agent1.Queue - Agent1.validSensors.queueCount,0);
            Agent1.Queue = Agent1.validSensors.queueCount;
            %diff = Headcount-Agent2.Queue-Agent1.Queue - sum(Agent1.Active)-sum(Agent2.Active);
            Agent2.Queue = Agent2.Queue + diff;
            z = 0;
            while diff>0
                tempdiff = max(0,Agent1.DelayHistory(end-z)-diff);
                diff = diff-Agent1.DelayHistory(end-z);
                delta = tempdiff;%abs(tempdiff-Agent2.DelayHistory(end-z));
                Agent1.DelayHistory(end-z) = tempdiff;
                Agent2.DelayHistory(end-z) = Agent2.DelayHistory(end-z) + delta;
                if diff<1 || z== (length(Agent1.DelayHistory) - 1)
                    break
                end
                z = z+1;
            end
        elseif Agent2.validSensors.Saturated == 0
            diff = max(Agent2.Queue - Agent2.validSensors.queueCount,0);
            Agent2.Queue = Agent2.validSensors.queueCount;
            Agent1.Queue = Agent1.Queue + diff;
            z = 0;
            while diff>0
                tempdiff = max(0,Agent2.DelayHistory(end-z)-diff);
                diff = diff-Agent2.DelayHistory(end-z);
                delta = tempdiff;
                Agent2.DelayHistory(end-z) = tempdiff;
                Agent1.DelayHistory(end-z) = Agent1.DelayHistory(end-z) + delta;
                if diff<1 || z== (length(Agent2.DelayHistory) - 1)
                    break
                end
                z = z+1;
            end
        end
    end
end
Agent1.validSensors.Count = 0;
Agent2.validSensors.Count = 0;
end