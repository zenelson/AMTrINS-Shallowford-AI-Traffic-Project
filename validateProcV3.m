function [queue,numMap,oldMap,queueMat,dur,queueOG] = validateProcV3(queue,gapMap,numMap,obsWindow,vehLength,vehGap,numLanes,sensorRange,absVal,divisionPoint,cycle,state,queueOG,dur)
%validateProcV3 Attempt to predict the number of incoming vehicles
%
%   This program attempts to estimate the amount of roadway that a vehicle
%   may need to brake in order to reach a stop and join a queue. This
%   amount of roadway is overlayed, starting at the end of the currently
%   estimated queue length, with the map of estiamted vehicles positions,
%   to attempt to estiamte the incoming flow of vehicles that may join a
%   queue. This also includes estimates if the queue is inactive and if
%   actively serviced by a green light.
%   
%% Variables
% queue[int] = Current queue measured along source
% gapMap[array-float] = Array of gaps along a roadway with the respective
% length of each gap. Meant to account for road length and average velocity
% obsLength[int] = Length of observation window leading from queue outwards
% vehLength[int] = Vehicle Length. Approx ~ 5 m
% vehGap[int] = Minimum intervehicle gap. Approx ~ 2.5 m
% sensorRange[int] = Length of TSC camera measurement Range. Approx ~ 180 m
%% Method
oldqueue = queue;
oldMap = numMap;    %Added 8/23/21
delay = count(state,'r');
%x = queue*vehLength + max(0,(queue-1)*vehGap);   %Calculate Queue Length

LengthMap = absVal;
stateChar = char(state);
if (strcmp(stateChar(1),'r') && (contains(state,["G","g"])))
    delay = count(state,'r');
    [Range,v_final,v_init,x] = queueObsLengthV3(queueOG,dur,delay,1,queue,cycle,0,numLanes(1));
    dur = dur + 13;
elseif  (contains(state,["G","g"])) && ~contains(state,'r')% if R -> G or G -> G
    [Range,v_final,v_init,x] = queueObsLengthV3(queueOG,dur,delay,1,queue,cycle,0,numLanes(1));
%elseif Range == 0 %No predicted slowdown
    dur = dur + 13;
elseif (contains(state,'r') && ~contains(state,["G","g"])) || ...
        (strcmp(stateChar(end),'r') && contains(state,["G","g"]))%All Red
    delay = 0;
    [Range,v_final,v_init,x] = queueObsLengthV3(queueOG,dur,delay,1,queue,cycle,count(state,'r'),numLanes(1));
    dur = 0;
end
obsWindow = Range;

if x < sensorRange
    x_start = 1;              
    obsWindow = (obsWindow - sensorRange) + x;  
else
    x_start = sum(gapMap<x)+1;
    obsWindow = obsWindow + x;
end
if Range > 0
    for i=1:x_start:length(gapMap)
        if gapMap(i) <= (obsWindow+x)
            queue = queue + numMap(i);
            x = queue*vehLength + max(0,(queue-1)*vehGap);
            numMap(i) = 0;
            oldMap = numMap;   
            queueMat = [numMap(i),1];
        else
            obsLength = LengthMap(i)-(gapMap(i)-(obsWindow+x));
            if divisionPoint < gapMap(i) && divisionPoint > max(gapMap(i)-absVal(i),0)
                [output,queueMat] = probBuildvsplit(numMap(i),obsLength,LengthMap(i),vehLength,numLanes(1),numLanes(2),divisionPoint); %Edited 11/5/21
            elseif divisionPoint > gapMap(i)
                [output,queueMat] = probBuildv2(numMap(i),obsLength,LengthMap(i),vehLength,numLanes(2));
            elseif divisionPoint < gapMap(i) && divisionPoint < max(gapMap(i)-absVal(i),0)
                [output,queueMat] = probBuildv2(numMap(i),obsLength,LengthMap(i),vehLength,numLanes(1));
            end
            numMap(i) = numMap(i)-output;
            queue = queue + output;
            queueOG = queueOG + output;
            if output == numMap(i) && numMap(i) ~= 0
                x = queue*vehLength + max(0,(queue-1)*vehGap);
            else
                break
            end
            if output == 0 && v_final >= 17.88
                queueOG = 0;
            elseif strcmp(stateChar(end),'r') && queueOG > 0
                queueOG = oldqueue;
            end
        end
    end
else
    queue = queue;
    numMap = numMap;
    queueMat = [0,1];
end
if strcmp(stateChar(end),'r') && queueOG > 0
    queueOG = oldqueue;
end
end

