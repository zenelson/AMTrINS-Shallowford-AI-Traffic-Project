function [estService,ActivatedQueue,ActivatedShortProb,ActiveDelay] = ActivePredictor(Agent)
%ActivePredictor Attempts to estimate the queue for a lane that is active
%   Additional calculations for the queue and service rates of a lane that
%   has a green light and has a queue that is gradually moving away,
%   attempting to account for wave kinematics. Assumes the delay response
%   of each driver is approximately 1 second.
LengthMap = Agent.absVal;
vehLength = Agent.vehLength;

Agent.Queue = Agent.backup.Queue;
Agent.dur = Agent.backup.dur;
Agent.queueOG = Agent.backup.queueOG;
Agent.ActiveT = Agent.backup.Active;
if Agent.dur>0
    state = repmat('G',1,Agent.Cycle);
else
    state = append(repmat('r',1,3),repmat('G',1,Agent.Cycle-3));
end
[estQueue,ActiveT,~,~,dur,~] = validateProcV3(Agent.Queue,Agent.GapMap,Agent.ActiveT,...
    Agent.obsWindow,Agent.vehLength,Agent.vehGap,Agent.numLanes,1,Agent.absVal,...
    Agent.divisionPoint,Agent.Cycle,state,Agent.queueOG,Agent.dur);
serviceOld = serviceRateEst(Agent.Velocity,Agent.dur);
serviceNew = serviceRateEst(Agent.Velocity,dur);
estService = (serviceNew-serviceOld)*Agent.numLanes(1);
Agent.ActivatedQueue = max(0,estQueue-estService);
ActivatedQueue = Agent.ActivatedQueue;

gapMap = Agent.GapMap;
obsWindow = Agent.obsWindow;
Active = ActiveT;
numLanes = Agent.numLanes;
total = 0;
for i=1:length(gapMap)
    if gapMap(i)<=obsWindow
        total = total+Active(i);
    else
        obsLength = LengthMap(i)-(gapMap(i)-(obsWindow));
        [output,~] = probBuildv2(Active(i),obsLength,LengthMap(i),vehLength,numLanes(1));
        Active(i) = Active(i)-output;
        break
    end
end
rem = max(estQueue-estService+output+total,0);
total = 0;
obsWindow = 2*obsWindow;
for i=1:length(gapMap)
    if gapMap(i)<=obsWindow
        total = total+Active(i);
    else
        obsLength = LengthMap(i)-(gapMap(i)-(obsWindow));
        [~,queueMat] = probBuildv2(Active(i),obsLength,LengthMap(i),vehLength,numLanes(1));
        queueMat(:,1) = queueMat(:,1)+total+rem;
        break
    end
end
x = find(queueMat(:,1)>=4*numLanes(1));
if isempty(x)
    ActivatedShortProb = 0;
else
    ActivatedShortProb = sum(queueMat(x,2));
end
queueDiff = max(0,estQueue-Agent.backup.Queue);
ActiveFuture = circshift(Agent.DelayHistory,-1);
if ActiveFuture(end) > 0
    ActiveFuture(1) = ActiveFuture(1) + ActiveFuture(end);
end

service = estService;
if estService > 4
    discountWeight = Agent.consecutiveDiscount;
else
    discountWeight = 1;
end
z = 1;
while service>0
    ActiveFuture(z) = max(0,ActiveFuture(z)-service);
    service = service-ActiveFuture(z);
    z = z + 1;
    if z==length(ActiveFuture)
        break
    end
end

%ActiveFuture(end-1)=queueDiff;
ActiveFuture(end) = queueDiff;
ActiveDelay = ActiveFuture*Agent.DelayVal'*discountWeight;

end

