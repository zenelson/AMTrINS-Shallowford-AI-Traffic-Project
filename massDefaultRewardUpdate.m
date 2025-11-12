function [Agent] = massDefaultRewardUpdate(Agent,Caddy, decisionTime,a,b)
%massDefaultRewardUpdate Update Rewards
%   Update general rewards for each row-state for general training
NorthArrivalL = 1;
NorthArrivalT = 1;
EastArrivalL = 1;
EastArrivalT = 1;
SouthArrivalL = 1;
SouthArrivalT = 1;
WestArrivalL = 1;
WestArrivalT = 1;


for i=1:numel(Agent)
    x = (i-1)*8;
    legacyReward = Agent(i).Reward;
    historyCheck = Agent(i).pastSSA;
%% Determine if the direciton exists and set the max values
if ~isempty(Agent(i).Sensors.Southbound.Right)
    NFullValLeft = max(Caddy(5+x).Queue,4*numel(Agent(i).Sensors.Southbound.Left));
    NFullValThrough = max(Caddy(6+x).Queue,4*numel(Agent(i).Sensors.Southbound.Through));
else
    NFullValLeft = 0;
    NFullValThrough = 0;
end

if ~isempty(Agent(i).Sensors.Westbound.Right)
    EFullValLeft = max(Caddy(7+x).Queue,4*numel(Agent(i).Sensors.Westbound.Left));
    EFullValThrough = max(Caddy(8+x).Queue,4*numel(Agent(i).Sensors.Westbound.Through));
else
    EFullValLeft = 0;
    EFullValThrough = 0;
end

if ~isempty(Agent(i).Sensors.Northbound.Right)
    SFullValLeft = max(Caddy(1+x).Queue,4*numel(Agent(i).Sensors.Northbound.Left));
    SFullValThrough = max(Caddy(2+x).Queue,4*numel(Agent(i).Sensors.Northbound.Through));
else
    SFullValLeft = 0;
    SFullValThrough = 0;
end

if ~isempty(Agent(i).Sensors.Eastbound.Right)
    WFullValLeft = max(Caddy(3+x).Queue,4*numel(Agent(i).Sensors.Eastbound.Left));
    WFullValThrough = max(Caddy(4+x).Queue,4*numel(Agent(i).Sensors.Eastbound.Through));
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
        
        NcontL = NvalsL(startComp(5),endComp(5));
        NcontT = NvalsT(startComp(6),endComp(6));
        EcontL = EvalsL(startComp(7),endComp(7));
        EcontT = EvalsT(startComp(8),endComp(8));
        ScontL = SvalsL(startComp(1),endComp(1));
        ScontT = SvalsT(startComp(2),endComp(2));
        WcontL = WvalsL(startComp(3),endComp(3));
        WcontT = WvalsT(startComp(4),endComp(4));
        
        for act = 1:8
            totVals = -1.*[NcontL, NcontT, EcontL, EcontT,...
                ScontL, ScontT, WcontL, WcontT];
            Rewards(startState+1,endState+1,act) = sum(totVals.*actStates(act,:));
        end
        
    end
end
%For HistoryCheck, 0==Scenario hasn't been encountered, 1==Scenario has
%been encountered
Rewards(historyCheck==1)=0;
Agent.Reward = Rewards + historyCheck.*legacyReward;
end
end

