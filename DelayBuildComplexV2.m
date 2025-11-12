function [Reward] = DelayBuildComplexV2(Agent,serviceEstimates, decisionTime,flowArray,a,b)
%DelayBuildComplexV2 Create initial reward values based on delays
%   The program imports recorded/approximated flow values from flowArray in
%   relation to relevant lanes. The program assesses the estimated penalty
%   from any of these lanes being left as 'Full' based on estimated flow
%   rates and creates a reward matrix of StatexStatexAction for usage 
NorthArrivalL = flowArray(5);
NorthArrivalT = flowArray(6);
EastArrivalL = flowArray(7);
EastArrivalT = flowArray(8);
SouthArrivalL = flowArray(1);
SouthArrivalT = flowArray(2);
WestArrivalL = flowArray(3);
WestArrivalT = flowArray(4);
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
NvalsL = [a*NFullValLeft+b*NFullValLeft*decisionTime*NorthArrivalL, 0;
    a*NFullValLeft, 0];
NvalsT = [a*NFullValThrough+b*NFullValThrough*decisionTime*NorthArrivalT, 0;
    a*NFullValThrough, 0];

SvalsL = [a*SFullValLeft+b*SFullValLeft*decisionTime*SouthArrivalL, 0;
    a*SFullValLeft, 0];
SvalsT = [a*SFullValThrough+b*SFullValThrough*decisionTime*SouthArrivalT, 0;
    a*SFullValThrough, 0];

EvalsL = [a*EFullValLeft+b*EFullValLeft*decisionTime*EastArrivalL, 0;
    a*EFullValLeft, 0];
EvalsT = [a*EFullValThrough+b*EFullValThrough*decisionTime*EastArrivalT, 0;
    a*EFullValThrough, 0];

WvalsL = [a*WFullValLeft+b*WFullValLeft*decisionTime*WestArrivalL, 0;
    a*WFullValLeft, 0];
WvalsT = [a*WFullValThrough+b*WFullValThrough*decisionTime*WestArrivalT, 0;
    a*WFullValThrough, 0];

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
    startComp = dec2bin(startState,8);
    startComp = startComp=='1'; 
    startComp = startComp + 1;
    for endState = 0:255
        endComp = dec2bin(endState,8);
        endComp = endComp=='1';
        endComp = endComp + 1;
        
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

