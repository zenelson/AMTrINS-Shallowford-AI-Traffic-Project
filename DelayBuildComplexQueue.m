function [Reward] = DelayBuildComplexQueue(Agent,serviceEstimates,flowArray)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% NorthArrival = 0.1;
% EastArrival = 0.4;
% SouthArrival = 0.1;
% WestArrival = 0.4;
NorthQueueL = flowArray(5);
NorthQueueT = flowArray(6);
EastQueueL = flowArray(7);
EastQueueT = flowArray(8);
SouthQueueL = flowArray(1);
SouthQueueT = flowArray(2);
WestQueueL = flowArray(3);
WestQueueT = flowArray(4);
%% Determine if the direciton exists and set the max values
if ~isempty(Agent.Sensors.Southbound.Right)
    NFullValLeft = serviceEstimates(1)*numel(Agent.Sensors.Southbound.Left);
    NFullValThrough = serviceEstimates(1)*numel(Agent.Sensors.Southbound.Through);
else
    NFullValLeft = 0;
    NFullValThrough = 0;
end

if ~isempty(Agent.Sensors.Westbound.Right)
    EFullValLeft = serviceEstimates(1)*numel(Agent.Sensors.Westbound.Left);
    EFullValThrough = serviceEstimates(1)*numel(Agent.Sensors.Westbound.Through);
else
    EFullValLeft = 0;
    EFullValThrough = 0;
end

if ~isempty(Agent.Sensors.Northbound.Right)
    SFullValLeft = serviceEstimates(1)*numel(Agent.Sensors.Northbound.Left);
    SFullValThrough = serviceEstimates(1)*numel(Agent.Sensors.Northbound.Through);
else
    SFullValLeft = 0;
    SFullValThrough = 0;
end

if ~isempty(Agent.Sensors.Eastbound.Right)
    WFullValLeft = serviceEstimates(1)*numel(Agent.Sensors.Eastbound.Left);
    WFullValThrough = serviceEstimates(1)*numel(Agent.Sensors.Eastbound.Through);
else
    WFullValLeft = 0;
    WFullValThrough = 0;
end

%% Apply Logic

% 0 = FULL, 1 = EMPTY
NvalsL = [NorthQueueL, 0;
    NFullValLeft, 0];
NvalsT = [NorthQueueT, 0;
    NFullValThrough, 0];

SvalsL = [SouthQueueL, 0;
    SFullValLeft, 0];
SvalsT = [SouthQueueT, 0;
    SFullValThrough, 0];

EvalsL = [EastQueueL, 0;
    EFullValLeft, 0];
EvalsT = [EastQueueT, 0;
    EFullValThrough, 0];

WvalsL = [WestQueueL, 0;
    WFullValLeft, 0];
WvalsT = [WestQueueT, 0;
    WFullValThrough, 0];

actStates = [0,1,0,0,0,1,0,0;
    1,0,0,0,1,0,0,0;
    1,1,0,0,0,0,0,0;
    0,0,0,0,1,1,0,0;
    0,0,0,1,0,0,0,1;
    0,0,1,0,0,0,1,0;
    0,0,1,1,0,0,0,0;
    0,0,0,0,0,0,1,1];
actStates = ~actStates; %Should rectify the "Reward Inversion" bug
Rewards = zeros(256,256,8);
for startState = 0:255
    startComp = 1 + dec2bin(startState,8);
    for endState = 0:255
        endComp = 1 + dec2bin(endState,8);
        
        NcontL = NvalsL(startComp(1),endComp(1));
        NcontT = NvalsT(startComp(2),endComp(2));
        EcontL = EvalsL(startComp(3),endComp(3));
        EcontT = EvalsT(startComp(4),endComp(4));
        ScontL = SvalsL(startComp(5),endComp(5));
        ScontT = SvalsT(startComp(6),endComp(6));
        WcontL = WvalsL(startComp(7),endComp(7));
        WcontT = WvalsT(startComp(8),endComp(8));
        
        for act = 1:8
            totVals = -1.*[NcontL, NcontT, EcontL, EcontT,...
                ScontL, ScontT, WcontL, WcontT];
            Rewards(startState+1,endState+1,act) = sum(totVals.*actStates(act,:));
        end
        
    end
end

Reward = Rewards;

end

