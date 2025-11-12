function [Agent] = massActiveDelayBuildComplex(Agent,Caddy,a,b)
%massActiveDelayBuildComplex Calculate delays for active traffic lanes
%   Create delay builds for active lanes
for i=1:numel(Agent)
    x= (i-1)*8;
NorthArrivalL = Caddy(1+x).ActiveDelay;
NorthArrivalT = Caddy(2+x).ActiveDelay;
EastArrivalL = Caddy(3+x).ActiveDelay;
EastArrivalT = Caddy(4+x).ActiveDelay;
SouthArrivalL = Caddy(5+x).ActiveDelay;
SouthArrivalT = Caddy(6+x).ActiveDelay;
WestArrivalL = Caddy(7+x).ActiveDelay;
WestArrivalT = Caddy(8+x).ActiveDelay;
%% Determine if the direciton exists and set the max values
if ~isempty(Agent(i).Sensors.Southbound.Right)
    NFullValLeft = Caddy(1+x).ActivatedQueue;
    NFullValThrough = Caddy(2+x).ActivatedQueue;
else
    NFullValLeft = 0;
    NFullValThrough = 0;
end

if ~isempty(Agent(i).Sensors.Westbound.Right)
    EFullValLeft = Caddy(3+x).ActivatedQueue;
    EFullValThrough = Caddy(4+x).ActivatedQueue;
else
    EFullValLeft = 0;
    EFullValThrough = 0;
end

if ~isempty(Agent(i).Sensors.Northbound.Right)
    SFullValLeft = Caddy(5+x).ActivatedQueue;
    SFullValThrough = Caddy(6+x).ActivatedQueue;
else
    SFullValLeft = 0;
    SFullValThrough = 0;
end

if ~isempty(Agent(i).Sensors.Eastbound.Right)
    WFullValLeft = Caddy(7+x).ActivatedQueue;
    WFullValThrough = Caddy(8+x).ActivatedQueue;
else
    WFullValLeft = 0;
    WFullValThrough = 0;
end

%% Apply Logic

% 0 = FULL, 1 = EMPTY
NvalsL = [a*NFullValLeft+b*NorthArrivalL, 0;
    a*max(NFullValLeft,NorthArrivalL), 0];
NvalsT = [a*NFullValThrough+b*NorthArrivalT, 0;
    a*max(NFullValThrough,NorthArrivalT), 0];

SvalsL = [a*SFullValLeft+b*SouthArrivalL, 0;
    a*max(SFullValLeft,SouthArrivalL), 0];
SvalsT = [a*SFullValThrough+b*SouthArrivalT, 0;
    a*max(SFullValThrough,SouthArrivalT), 0];

EvalsL = [a*EFullValLeft+b*EastArrivalL, 0;
    a*max(EFullValLeft,EastArrivalL), 0];
EvalsT = [a*EFullValThrough+b*EastArrivalT, 0;
    a*max(EFullValThrough,EastArrivalT), 0];

WvalsL = [a*WFullValLeft+b*WestArrivalL, 0;
    a*max(WFullValLeft,WestArrivalL), 0];
WvalsT = [a*WFullValThrough+b*WestArrivalT, 0;
    a*max(WFullValThrough,WestArrivalT), 0];

actStates = [0,1,0,0,0,1,0,0;
    1,0,0,0,1,0,0,0;
    1,1,0,0,0,0,0,0;
    0,0,0,0,1,1,0,0;
    0,0,0,1,0,0,0,1;
    0,0,1,0,0,0,1,0;
    0,0,1,1,0,0,0,0;
    0,0,0,0,0,0,1,1];
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

Agent(i).macroRAct = Rewards;
end
end

