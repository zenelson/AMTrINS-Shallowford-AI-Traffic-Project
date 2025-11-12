clc
clearvars
cleanupSUMO();
%% Summary
% This is PredictiveTestbench.m, a program designed to serve as a testing
% grounds for the current iteration of the Shallowford project. This
% version has removed the Pseudonodes utilized in prior versions in favor
% of a more simplified probabalistic approach. This program will test the
% environment but only with a single intersection to simplfy computational
% costs and reduce necessity of negotiation, as the program should be
% required to stand on its own two feet as a single entity with the
% capacity to work with others.
%% New Control Options
queueRewardOption = 0;  %Select 1 to activate Queue-based Rewards
postDynaOption = 0;     %Select 1 to activate postDyna for state-specific Dyna-Q learning
%% Initialize Variables (Caddies)

load('CaddySetEightMk2.mat','Caddy')
%load('CaddySetSeven.mat','Caddy')
% Vehicle Data
Vehicle.minGap = 2.5;   %Minimum gap between vehicles (Waiting)
Vehicle.Length = 5;     %Average Length of vehicle
estQueue = 0;

Split(1).ID = 'South8';
Split(1).oldData = {};
Split(1).newData = {};
%Split(1).Ratio = 0.72;%0.74;
%Split(1).Ratio = 1.0; %Should create an "all Through" traffic behavior
Split(1).Ratio = 0.72;

Split(2).ID = 'West2';%'West2';
Split(2).oldData = {};
Split(2).newData = {};
Split(2).Ratio = 0.91;%0.95;%0.91;

Split(3).ID = 'North8';%'North8';
Split(3).oldData = {};
Split(3).newData = {};
Split(3).Ratio = 0.64;%0.54;%0.64;

Split(4).ID = 'East19';
Split(4).oldData = {};
Split(4).newData = {};
Split(4).Ratio = 0.72;%0.72;%0.76;

for i=1:4
    Split(i).errorMargin = 0.15;
    Split(i).UpdateWeight = 0.15; 
    Split(i).newRatio = Split(i).Ratio;
    Split(i).headCount = 0;
    Split(i).newVeh = 0;
end
for i=1:8
Caddy(i).Sensors.flowCount = zeros(1,11);
Caddy(i).waitList = zeros(1,30);
Caddy(i).waitTime = 13:13:(13*30);
Caddy(i).delay=0;
Caddy(i).oldService = 0;
Caddy(i).longProb = 0.25*ones(1,10);
Caddy(i).maxDelay = 0;
Caddy(i).dur = 0;
Caddy(i).queueOG = 0;
Caddy(i).divisionPoint = 0;
Caddy(i).ActiveDelay = 0;
end
PedAI(1).Name = 'Southbound';
PedAI(1).EdgeID = 'South8';
PedAI(1).Walkarea = ':Junction8_w0';
PedAI(2).Name = 'Westbound';
PedAI(2).EdgeID = 'East20';
PedAI(2).Walkarea = ':Junction8_w2';
PedAI(3).Name = 'Northbound';
PedAI(3).EdgeID = 'South8EX';
PedAI(3).Walkarea = ':Junction8_w3';
PedAI(4).Name = 'Eastbound';
PedAI(4).EdgeID = 'East19';
PedAI(4).Walkarea = ':Junction8_w3';
for i=1:4
    %Used in Version V2b (Medium Pedestrian Traffic & PM vehicles)
    PedAI(i).DelayVal = (10*exp(([0,1,2,3,6,8,10,12,14,16])));
    PedAI(i).data = {'Empty'};
    PedAI(i).currentDelay = 0;
    PedAI(i).inactiveDelay = 0;
    PedAI(i).activeDelay = 0;
    PedAI(i).waitlist = zeros(1,numel(PedAI(i).DelayVal));
end

newData(1).data = {};
newData(2).data = {};
newData(3).data = {};
newData(4).data = {};
newData(5).data = {};
newData(6).data = {};
newData(7).data = {};
newData(8).data = {};
%% Initialize Variables (agentOpts)
% agentOpts is a set of values meant to activate various factors and
% mechanics for the Reinforcement Learning aspect of the code
agentOpts.DoctoringSetting=2;
agentOpts.preProcessQ = 1;
agentOpts.rewardType = 'Delay';
agentOpts.decayDelay = 1;
agentOpts.decayRate = 0;
agentOpts.explorationRate = 0.1;
agentOpts.learnRate = 0.4;
agentOpts.rewardLearnRate = 0.2;
agentOpts.discountFactor = 0.9; %Default: 0.9
agentOpts.actionTime = 'afterNegotiations';
agentOpts.negMaxTime = 13;
agentOpts.negMaxIter = 5;
agentOpts.negThreshold = 0.005;
agentOpts.signalTime = 13;  %Previously at 15, but set to 13 for sake of consistency
agentOpts.checkpoint = 2;
agentOpts.checkPointTest = 0;
agentOpts.decayWeight = 0.8;
agentOpts.decayType = 'Constant';
agentOpts.convergTest = 1;
agentOpts.filenameIter = 1;
agentOpts.modelMode = 'Freeform';
agentOpts.timeLimit = 1800;
agentOpts.updateTime = 1*agentOpts.signalTime;
agentOpts.updateMethod = 'CMA';
agentOpts.startingServiceEstimates = [4,2];
agentOpts.warmupTime = 0;
agentOpts.TestWindow = 300;
agentOpts.checkTest = 1;

DynaOpts.multiStep = 23;
DynaOpts.numGames = 20;
DynaOpts.onlyUseRealExp = 0;
DynaOpts.useGradients = 0;
DynaOpts.solveIt = true;
agentOpts.TrafficFlow = 'Mid';
ratio = (1-(1./log((1:10000)+2)));
%ratio = 0.5;
%% Initialize Variables (Agent)
% For this test, only one agent(Traffic Signal) will be utilized. This is
% meant to assess the performative nature of the Caddies along with more
% rigorous validation of the performance of the Agent's Reinforcement
% Learning code.
load('MicroShallowford_ZN.mat','Agent')
Agent(2:end)=[];
Agent(1).ID = {'Junction8'};
% INSERT ADDITIONALS TO INCUR THAT AGENT PROBABILITIES ARE SET TO CADDY
% VALUES
alpha = 0.5; %Queue Weight
beta = 0.5;  %Delay Weight
gamma = 1; %Pedestrian Weight
delta = 0;   %Consecutive Discount [0: no discount at all, 1: 100% discount]
Theta = 0.5; %Ratio for Pedestrians and Vehicles (0=All Vehicle/1=All Pedestrian)
rewardWeight = 15;
Agent(1).QLimit = -inf; %Defaul is -inf
%Agent(2).QLimit = -inf;
emergencyDiscount = 0.9; %Default is 0.9-Alternate is 0.

discountWindow = 2; %How many decision cycles would we like a discount to last?
actionTrigger = 9; %How many cycles does it need to be inactive to activate?
discountBoost = 1; %How much of an increase in penalty [1=100% increase]

%inactiveDelayBoost Values
for i=1:1
Agent(i).inactiveTrack.Count = [0,0,0,0,0,0,0,0];
Agent(i).inactiveTrack.discountTracker = [0,0,0,0,0,0,0,0];
Agent(i).inactiveTrack.discountWindow = discountWindow;
Agent(i).inactiveTrack.actionTrigger = actionTrigger;
Agent(i).inactiveTrack.discountWeight = discountBoost;
end

%%
for i=1:16
    Caddy(i).consecutiveDiscount = 1-delta;
    Caddy(i).urgentCheck = 0;
end
%beta = 1-alpha;
%% Initialize Values
for i=1:1

Agent(i).Q = initQ(256,8,agentOpts.signalTime,[1,1,1,2,1,1,1,2],([0,0,0,0,0,0,0,0]./7200));
Agent(i).Reward = DelayBuildComplexV2(Agent(i),agentOpts.startingServiceEstimates,agentOpts.signalTime,([1,1,1,1,1,1,1,1]),alpha,beta);
Agent(i).Reward = Agent(i).Reward.*rewardWeight;
oldReward = Agent(i).Reward;
end
firstPhase = agentOpts.signalTime;
phaseTime = agentOpts.signalTime;
%Temporary Location for convenience
savefileName='Junction_Eight_TestV12Mk3.mat';
rewardSaveFile='Junction_Eight_Test_RewardsV1.mat';
dynalearnRate = 0.4;
Theta = 0.55;
%% Variable Speedup
for i=1:1
Agent(i).validChoices = [];
Agent(i).T = [];
Startup = dec2bin(255:-1:0,8);
Agent(i).validChoices = 1:256;
iter = 1;
Agent(i).StateHistory = zeros(1,256);
Agent(i).ActionHistory = zeros(1,8);
Agent(i).oldAction = 0;
Agent(i).Actiontaken(1) = 0;
Agent(i).State = 0;
end
%% Additional Settings
method = agentOpts.rewardType;
AgentQueues = zeros(1,8);
serviceEstimate = agentOpts.startingServiceEstimates;
decayDelay = agentOpts.decayDelay;
decayRate = agentOpts.decayRate;
explorationRate = agentOpts.explorationRate;
learnRate = agentOpts.learnRate;
rewardLearnRate = agentOpts.rewardLearnRate;
discountFactor = agentOpts.discountFactor;
actionTime = agentOpts.actionTime;
neg_max = agentOpts.negMaxIter*2;

pastSA = zeros(1,256,8);
pastSSA = zeros(256,256,8);
oldstate = zeros(1,1);
old_action = zeros(1,1);
state = zeros(1,1);
action = ones(1,1);
n_exchanges = 0;
NegotiationCount = zeros(1,277);
%arrCount = zeros(1,length(sourceIndexList)); % May need to be overhauled or replaced
timeTrack = 1;
step = 1;
totalCount = zeros(10,7201);
totalCount2 = totalCount;
data = struct([]);
negotiationAudit = struct([]);
MidJunctionState = struct([]);
MidJunctionAction = struct([]);
stateAudit = struct([]);
timecheck = 0;
%% Routing Data
NT = '2021-06-01NTJunc8_V2.rou.xml';
NL = '2021-06-01NLJunc8_V2.rou.xml';
WT = '2021-06-01WTJunc8_V3.rou.xml';
WL = '2021-06-01WLJunc8_V2.rou.xml';
ST = '2021-06-01STJunc8_V2.rou.xml';
SL = '2021-06-01SLJunc8_V2.rou.xml';
ET = '2021-06-01ETJunc8_V2.rou.xml';
EL = '2021-06-01ELJunc8_V2.rou.xml';
Route = strjoin({NT,NL,SL,ST,EL,ET,WL,WT},',');
startTime = 17;
endTime = (startTime*3600) + 3601;
%% %% Main Program
% Attempts have been made to incorporate the Caddies into the simulation
% with minimal interference/disruption of the legacy code.
sumoSet.Net = 'Junction8Pedestrian.net.xml';
sumoSet.Route = Route;
sumoSet.Add1 = 'Junc8ValidateSensor.add.xml';
sumoSet.Add2 = 'V5ValidateSensor.add.xml';
sumoSet.Name = 'Junc7TestingMk1';
sumoSet = SUMOCaddyV2(sumoSet,startTime);
%savefileName='SoloSanityTest.mat';
%% File Naming

agentOpts.sourcePath = append(pwd,'\',sumoSet.Name,'.sumocfg');
%% For GUI
%traci.start(['sumo-gui -c ' '"' agentOpts.sourcePath '"' ' --start']);
%% For Non-GUI
traci.start(['sumo -c ' '"' agentOpts.sourcePath '"' ' --start']);
%% Begin Program
while traci.simulation.getMinExpectedNumber() > 0 && timecheck <= 3601
    traci.simulation.step();
    list = traci.simulation.getEmergencyStoppingVehiclesIDList;
    timecheck = traci.simulation.getTime()-(startTime*3600);
    %% Install VSMUpdate.m [Experimental]
    if rem(timecheck,agentOpts.signalTime)==0
        [Caddy,Split,upProbMat,stateProb] = VSMUpdateV6(Split,Caddy,timecheck,agentOpts.signalTime);
    else
        [Caddy,~,~,~] = VSMUpdateV6(Split,Caddy,timecheck,agentOpts.signalTime);
    end
    %% Take First Action
    if timecheck == (firstPhase + agentOpts.warmupTime)
        for k=1:1
            state = caddyStateMaker(Caddy(1+8*(k-1)).state,Caddy(2+8*(k-1)).state,Caddy(3+8*(k-1)).state,Caddy(4+8*(k-1)).state,Caddy(5+8*(k-1)).state,Caddy(6+8*(k-1)).state,Caddy(7+8*(k-1)).state,Caddy(8+8*(k-1)).state);
            action = epsigreed(state,Agent(k).Q,explorationRate);
            Agent(k).StateHistory(state) =Agent(k).StateHistory(state)+1;
            Agent(k).lastState = state;
            Agent(k).State = state;
            Agent(k).lastAction = action;
            takefirstaction(Agent(k).ID{1},action)
            Agent(k).Actiontaken(iter)=action;
            desiredAction = action;
            n_exchanges = n_exchanges + 1;
            ConvergenceCounter = 0;
            ConvergenceIter = 1:277;
        end
    end
    
    %% All Subsequent Actions
    if rem(timecheck,phaseTime) == 0 && timecheck ~= firstPhase
        iter = iter + 1;
        for k=1:1
            if queueRewardOption == 1
                %Note: May be buggy
                flowArray = [substate(1).Queue,substate(2).Queue,substate(3).Queue,substate(4).Queue,substate(5).Queue,substate(6).Queue,substate(7).Queue,substate(8).Queue];
                Agent(k).Reward = DelayBuildComplexQueue(Agent(k),agentOpts.startingServiceEstimates,flowArray);
            end
            old_state = Agent(k).lastState;
            old_action = Agent(k).lastAction;
            Agent(k).oldAction = old_action;
            state = caddyStateMaker(Caddy(1+8*(k-1)).state,Caddy(2+8*(k-1)).state,Caddy(3+8*(k-1)).state,Caddy(4+8*(k-1)).state,Caddy(5+8*(k-1)).state,Caddy(6+8*(k-1)).state,Caddy(7+8*(k-1)).state,Caddy(8+8*(k-1)).state);
            Agent(k).StateHistory(state) = Agent(k).StateHistory(state)+1;
            Agent(k).lastState = state;
            Agent(k).State = state;
            if queueRewardOption == 0
                recievedR = 0;
                for i=1+8*(k-1):8*k
                    Caddy(i).Delay = Caddy(i).DelayHistory*Caddy(i).DelayVal';
                    Caddy(i).DelayFuture = Caddy(i).DelayFuture*Caddy(i).DelayVal';
                    criticalDelay = find(fliplr(Caddy(i).DelayHistory),1,'last')*phaseTime > 35;%60;
                    urgentDelay = find(fliplr(Caddy(i).DelayHistory),1,'last')*phaseTime > 90;%60;
                    Caddy(i).DiscountTrigger = find(fliplr(Caddy(i).DelayHistory),1,'last')*phaseTime > 150;
                    if isempty(criticalDelay)
                        criticalDelay = false;
                    end
                    if Caddy(i).state == 0 && criticalDelay == 1 %find(fliplr(Caddy(i).DelayHistory))*phaseTime > 60%(length(Caddy(i).DelayHistory)-find(Caddy(i).DelayHistory,1))*phaseTime > 60
                        Caddy(i).state = 1;
                        state = caddyStateMaker(Caddy(1+8*(k-1)).state,Caddy(2+8*(k-1)).state,Caddy(3+8*(k-1)).state,Caddy(4+8*(k-1)).state,Caddy(5+8*(k-1)).state,Caddy(6+8*(k-1)).state,Caddy(7+8*(k-1)).state,Caddy(8+8*(k-1)).state);
                    end
                    if urgentDelay == 1
                        Caddy(i).DelayFuture = Caddy(i).DelayFuture*3;
                        Caddy(i).urgentCheck = 1;
                    end
                    recievedR = recievedR - (1-Theta)*(alpha*Caddy(i).oldQueue + beta*Caddy(i).Delay*Caddy(i).state);
                end
                %PEDESTRIAN BITS
                PedAI = totalPedDelayCount(PedAI);
                for x=1:4
                    [PedAI(x).currentDelay,futureArray,activeArray] = delayCalc_Ped(PedAI(x).data,PedAI(x).DelayVal,gamma);
                    PedAI(x).inactiveDelay = sum(futureArray);
                    PedAI(x).activeDelay = sum(activeArray);
                    recievedR = recievedR - Theta*PedAI(x).currentDelay;
                end
                if PedAI(1).currentDelay > 0 || PedAI(3).currentDelay > 0
                    Caddy(2).state = 1;
                    state = caddyStateMaker(Caddy(1).state,Caddy(2).state,Caddy(3).state,Caddy(4).state,Caddy(5).state,Caddy(6).state,Caddy(7).state,Caddy(8).state);
                end
                if PedAI(2).currentDelay > 0 || PedAI(4).currentDelay > 0
                    Caddy(8).state = 1;
                    state = caddyStateMaker(Caddy(1).state,Caddy(2).state,Caddy(3).state,Caddy(4).state,Caddy(5).state,Caddy(6).state,Caddy(7).state,Caddy(8).state);
                end
                if PedAI(4).currentDelay > 0
                end
                
                [Agent(k).Reward,~,~] = RewardUpdate(Agent(k).Reward,old_state,state,action,recievedR,rewardLearnRate);
                if pastSSA(old_state,state,action)==0
                    pastSSA(old_state,state,action)=1;
                end
                if pastSA(1,old_state,old_action)==0
                    pastSA(1,old_state,old_action) = recievedR;
                else
                    pastSA(1,old_state,old_action) = (pastSA(1,old_state,old_action)+recievedR)/2;
                end
                Agent(k).Q = Qupdate(old_state,old_action,state,recievedR,Agent(1).Q,learnRate(1),discountFactor,Agent(1).QLimit);
                Agent(k).pastSSA = pastSSA;
            end
        end
            %% Update Upstream Probabilities
            Agent(1).UpstreamProb.Northbound.State = [Caddy(5).stateProb, (1-Caddy(5).stateProb),Caddy(6).stateProb,(1-Caddy(6).stateProb)];
            Agent(1).UpstreamProb.Southbound.State = [Caddy(1).stateProb, (1-Caddy(1).stateProb),Caddy(2).stateProb,(1-Caddy(2).stateProb)];
            Agent(1).UpstreamProb.Eastbound.State = [Caddy(7).stateProb,(1-Caddy(7).stateProb),Caddy(8).stateProb,(1-Caddy(8).stateProb)];
            Agent(1).UpstreamProb.Westbound.State = [Caddy(3).stateProb,(1-Caddy(3).stateProb),Caddy(4).stateProb,(1-Caddy(4).stateProb)];
            
            Agent(1).UpstreamProb.Northbound.ShortProb = [Caddy(5).shortProb, Caddy(5).ActivatedShortProb,Caddy(6).shortProb,(Caddy(6).ActivatedShortProb)];
            Agent(1).UpstreamProb.Southbound.ShortProb = [Caddy(1).shortProb, (Caddy(1).ActivatedShortProb),Caddy(2).shortProb,(Caddy(2).ActivatedShortProb)];
            Agent(1).UpstreamProb.Eastbound.ShortProb = [Caddy(7).shortProb,(Caddy(7).ActivatedShortProb),Caddy(8).shortProb,(Caddy(8).ActivatedShortProb)];
            Agent(1).UpstreamProb.Westbound.ShortProb = [Caddy(3).shortProb,(Caddy(3).ActivatedShortProb),Caddy(4).shortProb,(Caddy(4).ActivatedShortProb)];
            
%             
            %% Add Pedestrian Delay Weights
            Caddy = PedDelayCompiler(PedAI,Caddy,Theta);
            %% Transitional Probability/Dyna-Q
            %numServed = zeros(1,8);
            err(1:2) = inf;
            thresh = agentOpts.negThreshold;
            tout = agentOpts.negMaxTime;
            emptySum = 0;
            neg_max = agentOpts.negMaxIter*2;
            n_neg=0;
            %% Pending for Modification/removal
            
            [Agent,Caddy] = multiAgentManager(Agent,Caddy,alpha,beta);
            
            negotiationAudit(iter).Eight = zeros(neg_max,8);
            negotiationAudit(iter).Nine = zeros(neg_max,8);
            stateAudit(iter).Eight = zeros(neg_max,256);
            stateAudit(iter).Nine = zeros(neg_max,256);
            MidJunctionState(iter).Eastbound = zeros(1,neg_max);
            MidJunctionState(iter).Westbound = zeros(1,neg_max);
            MidJunctionAction(iter).Eastbound = zeros(1,neg_max);
            MidJunctionAction(iter).Westbound = zeros(1,neg_max);
            Archive1 = Agent(1);
            %Archive2 = Agent(2);
            ArchiveSplit = Split;
            ArchiveCaddy = Caddy;
            ArchiveAgent = Agent;
            thresh = 0.05;
            while max(err) > thresh && n_neg < neg_max
                %Agent = negotiationManager(Agent,2,Startup,Split,Caddy);
                n_neg = n_neg+1;
                for i=1:1
                    state = Agent(i).State;
                    [T] = bigTransition(Agent(i),Startup);
                    [microT] = microTransition(Agent(i),Startup,state);
                    Agent(i).T = T;
                    Agent(i).microT = microT;
                    %er = 0;
                    rng('shuffle');
                    seed = rng();
                    [Agent(i),er] = BigMexInterface(Agent(i),dynalearnRate,0.9,seed,ratio,1,state);
                    if postDynaOption == 1
                        postQ = dynaPost(state,Agent(i).Reward,discountFactor,20,Agent(1).T);
                        nullVal = postQ>=0;
                        postQ(nullVal) = Agent(1).Q(nullVal);
                        Agent(i).Q = Agent(i).Q + learnRate.*(postQ-Agent(i).Q);
                    end
                    % Update Agent 1 Upstream probabilities here!
                    err(i) = max(er);
                end
            end
            if max(err) < thresh
                ConvergenceCounter = ConvergenceCounter + 1;
                ConvergenceIter(iter) = 0;
            end
            NegotiationCount(iter) = n_neg;
            for i=1:1
                state = Agent(i).State;
                old_action = Agent(i).oldAction;
                action = epsigreed(state,Agent(i).Q,explorationRate,agentOpts.modelMode,old_action);
                % COMMENTED ON 8/15/2022 TO REPLACE/UPDATE ACTION PROGRAMMING
                %         taketranaction(Agent(1).ID{1},action,old_action)
                %Pedestrian Safety Portion
                %         NSPedCheck = numel(traci.edge.getLastStepPersonIDs(':Junction8_c1'));
                %         EWPedCheck = numel(traci.edge.getLastStepPersonIDs(':Junction8_c0'));
                Agent(i).desiredAction = action;
                %         if NSPedCheck > 0 && (action ~= 1 || action~= 3)
                %             if Agent(1).Q(state,1) > Agent(1).Q(state,3)
                %                 action = 1;
                %             else
                %                 action = 3;
                %             end
                %         elseif EWPedCheck > 0 && (action ~= 5 || action~= 8)
                %             if Agent(1).Q(state,5) > Agent(1).Q(state,8)
                %                 action = 5;
                %             else
                %                 action = 8;
                %             end
                %         end
                
                
                Agent(i).Actiontaken(iter)=action;
                if i==1
                    [Caddy] = queueReset(Caddy,action);
                    [Caddy] = shortEdgeCleanup(Caddy,1);
                elseif i==2
                    [Caddy] = queueResetAgentNine(Caddy,action);
                    [Caddy] = shortEdgeCleanup(Caddy,9);
                end
                
            end
            n_exchanges = n_exchanges + 1;
            for i=1:16
                if Caddy(i).Queue == 0
                    Caddy(i).DelayHistory = Caddy(i).DelayHistory.*0;
                    Caddy(i).Delay = 0;
                    Caddy(i).maxDelay = 0;
                end
            end
    end
        pedestrianHeadcount = numel(traci.person.getIDList);
        for i=1:1
            currPhase = traci.trafficlights.getPhase(Agent(1).ID{1}); 
            actionManagerV6(Agent(i).ID{1},Agent(i).Actiontaken(iter),Agent(i).oldAction,timecheck,phaseTime,firstPhase,PedAI)
            if ~isfield(Agent,'desiredAction')
                desiredAction = action;
            else
                desiredAction = Agent(i).desiredAction;
            end
            Agent(i).lastAction = desiredAction;
        end
    if step < 2
        headcount = struct;
        headcount(step).Enter = traci.simulation.getDepartedIDList;
        headcount(step).time = step;
        headcount(step).Exit = traci.simulation.getArrivedIDList;
        actionHistory = zeros(1,555);
        stateHistory = zeros(1,555);
        phaseHistory = zeros(1,3600);
        ThroughputMod(1).Southbound = zeros(1,7201);
        ThroughputMod(1).Westbound=zeros(1,7201);
        ThroughputMod(1).Northbound=zeros(1,7201);
        ThroughputMod(1).Eastbound=zeros(1,7201);
        ThroughputMod(1).SouthboundString(1)={'Empty'};
        ThroughputMod(1).WestboundString(1)={'Empty'};
        ThroughputMod(1).NorthboundString(1)={'Empty'};
        ThroughputMod(1).EastboundString(1)={'Empty'};
        ThroughputMod(2).Southbound = zeros(1,7201);
        ThroughputMod(2).Westbound=zeros(1,7201);
        ThroughputMod(2).Northbound=zeros(1,7201);
        ThroughputMod(2).Eastbound=zeros(1,7201);
        ThroughputMod(2).SouthboundString(1)={'Empty'};
        ThroughputMod(2).WestboundString(1)={'Empty'};
        ThroughputMod(2).NorthboundString(1)={'Empty'};
        ThroughputMod(2).EastboundString(1)={'Empty'};
        %     delayCount(1).data = {'Empty'};
        %     delayCount(1).maxCount = zeros(1,7201);
        %     delayCount(1).totalCOunt = zeros(1,7201);
        %     delayCount(2).data = {'Empty'};
        %     delayCount(2).maxCount = zeros(1,7201);
        %     delayCount(2).totalCOunt = zeros(1,7201);
        %     delayCount(3).data = {'Empty'};
        %     delayCount(3).maxCount = zeros(1,7201);
        %     delayCount(3).totalCOunt = zeros(1,7201);
        %     delayCount(4).data = {'Empty'};
        %     delayCount(4).maxCount = zeros(1,7201);
        %     delayCount(4).totalCOunt = zeros(1,7201);
        for x=16:-1:1
            delayCounter(x).data = {'Empty'};
            delayCounter(x).maxCount = zeros(1,7201);
            delayCounter(x).totalCount = zeros(1,7201);
            delayCounter(x).avgCount = zeros(1,7201);
            delayCounter(x).peakCount = zeros(1,7201);
        end
        for x=4:-1:1
            delayPedCounter(x).data = {'Empty'};
            delayPedCounter(x).maxCount = zeros(1,7201);
            delayPedCounter(x).totalCount = zeros(1,7201);
            delayPedCounter(x).avgCount = zeros(1,7201);
        end
        delayCounter(1).Name = 'SouthboundLeft';
        delayCounter(2).Name = 'SouthboundThrough';
        delayCounter(3).Name = 'WestboundLeft';
        delayCounter(4).Name = 'WestboundThrough';
        delayCounter(5).Name = 'NorthboundLeft';
        delayCounter(6).Name = 'NorthboundThrough';
        delayCounter(7).Name = 'EastboundLeft';
        delayCounter(8).Name = 'EastboundThrough';
        delayCounter(9).Name = 'SouthboundLeft2';
        delayCounter(10).Name = 'SouthboundThrough2';
        delayCounter(11).Name = 'WestboundLeft2';
        delayCounter(12).Name = 'WestboundThrough2';
        delayCounter(13).Name = 'NorthboundLeft2';
        delayCounter(14).Name = 'NorthboundThrough2';
        delayCounter(15).Name = 'EastboundLeft2';
        delayCounter(16).Name = 'EastboundThrough2';
        
        delayPedCounter(1).Name = 'Southbound';
        delayPedCounter(1).EdgeID = 'South8';
        delayPedCounter(2).Name = 'Westbound';
        delayPedCounter(2).EdgeID = 'East20';
        delayPedCounter(3).Name = 'Northbound';
        delayPedCounter(3).EdgeID = 'South8EX';
        delayPedCounter(4).Name = 'Eastbound';
        delayPedCounter(4).EdgeID = 'East19';
        %     DelayMod(1).Delay = zeros(1,7201);
        %     DelayMod(2).Delay = zeros(1,7201);
        %     DelayMod(3).Delay = zeros(1,7201);
        %     DelayMod(4).Delay = zeros(1,7201);
        %     DelayMod(5).Delay = zeros(1,7201);
        %     DelayMod(6).Delay = zeros(1,7201);
        %     DelayMod(7).Delay = zeros(1,7201);
        %     DelayMod(8).Delay = zeros(1,7201);
        %     DelayMod(1).IndDelay = zeros(1,7201);
        %     DelayMod(2).IndDelay = zeros(1,7201);
        %     DelayMod(3).IndDelay = zeros(1,7201);
        %     DelayMod(4).IndDelay = zeros(1,7201);
        %     DelayMod(5).IndDelay = zeros(1,7201);
        %     DelayMod(6).IndDelay = zeros(1,7201);
        %     DelayMod(7).IndDelay = zeros(1,7201);
        %     DelayMod(8).IndDelay = zeros(1,7201);
    end
    if step >= 2
        headcount(step).Enter = traci.simulation.getDepartedIDList;
        headcount(step).time = step;
        headcount(step).Exit = traci.simulation.getArrivedIDList;
        phaseHistory(step) = traci.trafficlights.getPhase(Agent(1).ID{1}); 
        %AGENT 1 THROUGHPUT
        
        %   North
        newNorthboundString = traci.edge.getLastStepVehicleIDs('North7EX');
        ThroughputMod(1).Northbound(step) = numel(newNorthboundString)-numel(intersect(newNorthboundString,ThroughputMod(1).NorthboundString));
        ThroughputMod(1).NorthboundString = newNorthboundString;
        %   East
        newEastboundString = traci.edge.getLastStepVehicleIDs('East18');
        ThroughputMod(1).Eastbound(step) = numel(newEastboundString)-numel(intersect(newEastboundString,ThroughputMod(1).EastboundString));
        ThroughputMod(1).EastboundString = newEastboundString;
        %   South
        newSouthboundString = traci.edge.getLastStepVehicleIDs('South7EX');
        ThroughputMod(1).Southbound(step) = numel(newSouthboundString)-numel(intersect(newSouthboundString,ThroughputMod(1).SouthboundString));
        ThroughputMod(1).SouthboundString = newSouthboundString;
        %   West
        newWestboundString = traci.edge.getLastStepVehicleIDs('West5');
        ThroughputMod(1).Westbound(step) = numel(newWestboundString)-numel(intersect(newWestboundString,ThroughputMod(1).WestboundString));
        ThroughputMod(1).WestboundString = newWestboundString;
        totalCount(1,step) = ThroughputMod(1).Northbound(step)+ThroughputMod(1).Eastbound(step)...
            +ThroughputMod(1).Southbound(step)+ThroughputMod(1).Westbound(step);
        
%         %AGENT 2 THROUGHPUT
%         
%         %   North
%         newNorthboundString = traci.edge.getLastStepVehicleIDs('North9EX');
%         ThroughputMod(2).Northbound(step) = numel(newNorthboundString)-numel(intersect(newNorthboundString,ThroughputMod(1).NorthboundString));
%         ThroughputMod(2).NorthboundString = newNorthboundString;
%         %   East
%         newEastboundString = traci.edge.getLastStepVehicleIDs('East21');
%         ThroughputMod(2).Eastbound(step) = numel(newEastboundString)-numel(intersect(newEastboundString,ThroughputMod(1).EastboundString));
%         ThroughputMod(2).EastboundString = newEastboundString;
%         %   South
%         newSouthboundString = traci.edge.getLastStepVehicleIDs('South9EX');
%         ThroughputMod(2).Southbound(step) = numel(newSouthboundString)-numel(intersect(newSouthboundString,ThroughputMod(1).SouthboundString));
%         ThroughputMod(2).SouthboundString = newSouthboundString;
%         %   West
%         newWestboundString = traci.edge.getLastStepVehicleIDs('West2');
%         ThroughputMod(2).Westbound(step) = numel(newWestboundString)-numel(intersect(newWestboundString,ThroughputMod(1).WestboundString));
%         ThroughputMod(2).WestboundString = newWestboundString;
%         totalCount2(2,step) = ThroughputMod(2).Northbound(step)+ThroughputMod(2).Eastbound(step)...
%             +ThroughputMod(2).Southbound(step)+ThroughputMod(2).Westbound(step);
        
        
        for x=1:8
            [peakCount] = peakDelayCount(delayCounter(x).data,Caddy(x));
            delayCounter(x).peakCount(step) = peakCount;
            [recentMaxCount,recentTotalCount,delayCounter(x).data] = totalDelayCountV2(delayCounter(x).data,Caddy(x));
            delayCounter(x).maxCount(step) = recentMaxCount;
            delayCounter(x).totalCount(step) = recentTotalCount;
            arr = ['L','T','L','T','L','T','L','T'];
            arrinput = rem(x,8);
            if arrinput==0
                arrinput = 8;
            end
            
            delayCounter(x).avgCount(step) = delayCounter(x).totalCount(step)/sum(contains(delayCounter(x).data(:,1),arr(arrinput)));%traci.edge.getLastStepVehicleNumber(Caddy(x).edgeID{1});
            delayCounter(x).queueCount(step) = sum(contains(delayCounter(x).data(:,1),arr(arrinput)));
        end
        %PEDESTRIAN BIT
        delayPedCounter = totalPedDelayCount(delayPedCounter);
        for x=1:4
            delayPedCounter(x).maxCount(step) = delayPedCounter(x).recentPedMax;
            delayPedCounter(x).totalCount(step) = delayPedCounter(x).recentPedTotal;
            delayPedCounter(x).avgCount(step) = delayPedCounter(x).totalCount(step)/numel(delayPedCounter(x).data);%/sum(contains(delayPedCounter(x).data(:,1),arr(x)));
        end
        
        %     DelayMod(1).Delay(step) = Caddy(1).delay;
        %     DelayMod(2).Delay(step) = Caddy(2).delay;
        %     DelayMod(3).Delay(step) = Caddy(3).delay;
        %     DelayMod(4).Delay(step) = Caddy(4).delay;
        %     DelayMod(5).Delay(step) = Caddy(5).delay;
        %     DelayMod(6).Delay(step) = Caddy(6).delay;
        %     DelayMod(7).Delay(step) = Caddy(7).delay;
        %     DelayMod(8).Delay(step) = Caddy(8).delay;
        %     DelayMod(1).IndDelay(step) = Caddy(1).maxDelay;
        %     DelayMod(2).IndDelay(step) = Caddy(2).maxDelay;
        %     DelayMod(3).IndDelay(step) = Caddy(3).maxDelay;
        %     DelayMod(4).IndDelay(step) = Caddy(4).maxDelay;
        %     DelayMod(5).IndDelay(step) = Caddy(5).maxDelay;
        %     DelayMod(6).IndDelay(step) = Caddy(6).maxDelay;
        %     DelayMod(7).IndDelay(step) = Caddy(7).maxDelay;
        %     DelayMod(8).IndDelay(step) = Caddy(8).maxDelay;
    end
    step = step + 1;
    if rem(timecheck,phaseTime) == 0 %This is to track multiple Diagnostic Variables
        if timecheck == firstPhase
            primeAudit = struct;
            for i=1:1
                primeAudit(i).State = zeros(1,277);
                primeAudit(i).Action = zeros(1,277);
                primeAudit(i).Q_Values = zeros(277,8);
            end
            subAudit = struct;
            headcount = struct;
            for i=1:8
                subAudit(i).Rewards_Inactive = zeros(1,277);
                subAudit(i).Rewards_Active = zeros(1,277);
                subAudit(i).Delay_Value = zeros(1,277);
                subAudit(i).Count_Queue = zeros(1,277);
                subAudit(i).Count_Delay = zeros(1,277);
                subAudit(i).TotalDelay = zeros(1,277);
            end
        end
        for i=1:1
            primeAudit(i).State(n_exchanges) = Agent(i).State;
            primeAudit(i).Action(n_exchanges) = Agent(i).lastAction;
            state = Agent(i).State;
            primeAudit(i).Q_Values(n_exchanges,:) = Agent(i).Q(state,:);
        end
        for i=1:8
            subAudit(i).Rewards_Inactive(n_exchanges) = sum(Caddy(i).DelayFuture);
            subAudit(i).Rewards_Active(n_exchanges) = Caddy(i).ActiveDelay;
            subAudit(i).Delay_Value(n_exchanges) = Caddy(i).DelayHistory*Caddy(i).DelayVal';
            subAudit(i).Count_Queue(n_exchanges) = Caddy(i).Queue;
            subAudit(i).Count_Delay(n_exchanges) = sum(Caddy(i).DelayHistory);
            subAudit(i).TotalDelay(n_exchanges) = fliplr(Caddy(i).DelayHistory)*Caddy(i).DelayRef';
        end
    end
    if rem(timecheck,phaseTime) == 0 %&& timecheck ~= firstPhase
        actionHistory(n_exchanges) = action;
        stateHistory(n_exchanges) = state;
        if timecheck == firstPhase
            DelayMod(1).Delay = zeros(1,277);
            DelayMod(2).Delay = zeros(1,277);
            DelayMod(3).Delay = zeros(1,277);
            DelayMod(4).Delay = zeros(1,277);
            DelayMod(5).Delay = zeros(1,277);
            DelayMod(6).Delay = zeros(1,277);
            DelayMod(7).Delay = zeros(1,277);
            DelayMod(8).Delay = zeros(1,277);
            DelayMod(1).IndDelay = zeros(1,277);
            DelayMod(2).IndDelay = zeros(1,277);
            DelayMod(3).IndDelay = zeros(1,277);
            DelayMod(4).IndDelay = zeros(1,277);
            DelayMod(5).IndDelay = zeros(1,277);
            DelayMod(6).IndDelay = zeros(1,277);
            DelayMod(7).IndDelay = zeros(1,277);
            DelayMod(8).IndDelay = zeros(1,277);
            SplitReview(1).Ratio = zeros(1,277);
            SplitReview(2).Ratio = zeros(1,277);
            SplitReview(3).Ratio = zeros(1,277);
            SplitReview(4).Ratio = zeros(1,277);
            SplitReview(1).newRatio = zeros(1,277);
            SplitReview(2).newRatio = zeros(1,277);
            SplitReview(3).newRatio = zeros(1,277);
            SplitReview(4).newRatio = zeros(1,277);
        end
        DelayMod(1).Delay(n_exchanges) = Caddy(1).delay;
        DelayMod(2).Delay(n_exchanges) = Caddy(2).delay;
        DelayMod(3).Delay(n_exchanges) = Caddy(3).delay;
        DelayMod(4).Delay(n_exchanges) = Caddy(4).delay;
        DelayMod(5).Delay(n_exchanges) = Caddy(5).delay;
        DelayMod(6).Delay(n_exchanges) = Caddy(6).delay;
        DelayMod(7).Delay(n_exchanges) = Caddy(7).delay;
        DelayMod(8).Delay(n_exchanges) = Caddy(8).delay;
        DelayMod(1).IndDelay(n_exchanges) = Caddy(1).maxDelay;
        DelayMod(2).IndDelay(n_exchanges) = Caddy(2).maxDelay;
        DelayMod(3).IndDelay(n_exchanges) = Caddy(3).maxDelay;
        DelayMod(4).IndDelay(n_exchanges) = Caddy(4).maxDelay;
        DelayMod(5).IndDelay(n_exchanges) = Caddy(5).maxDelay;
        DelayMod(6).IndDelay(n_exchanges) = Caddy(6).maxDelay;
        DelayMod(7).IndDelay(n_exchanges) = Caddy(7).maxDelay;
        DelayMod(8).IndDelay(n_exchanges) = Caddy(8).maxDelay;
        SplitReview(1).Ratio(n_exchanges) = Split(1).Ratio;
        SplitReview(2).Ratio(n_exchanges) = Split(2).Ratio;
        SplitReview(3).Ratio(n_exchanges) = Split(3).Ratio;
        SplitReview(4).Ratio(n_exchanges) = Split(4).Ratio;
        SplitReview(1).newRatio(n_exchanges) = Split(1).newRatio;
        SplitReview(2).newRatio(n_exchanges) = Split(2).newRatio;
        SplitReview(3).newRatio(n_exchanges) = Split(3).newRatio;
        SplitReview(4).newRatio(n_exchanges) = Split(4).newRatio;
    end
end

newReward = Agent(1).Reward;
save(rewardSaveFile,'oldReward','newReward')

%save('SoloTestbenchDynaUpdatev1.mat','ThroughputMod')
save(savefileName,'ThroughputMod','DelayMod','delayCounter','actionHistory','SplitReview','primeAudit','subAudit','delayPedCounter','negotiationAudit','ConvergenceCounter','stateAudit','ConvergenceIter','NegotiationCount','headcount')
traci.close()
cleanupSUMO();
%% Additional Functions
function state = caddyStateMaker(sub1,sub2,sub3,sub4,sub5,sub6,sub7,sub8)
part_state(1) = sub1;%sub2;
part_state(2) = sub2;%sub1;
part_state(3) = sub3;%sub4;
part_state(4) = sub4;%sub3;
part_state(5) = sub5;%sub6;
part_state(6) = sub6;%sub5;
part_state(8) = sub8;%sub7;
part_state(7) = sub7;%sub8;

tmp_state = [part_state(1),part_state(2),part_state(3),part_state(4),part_state(5),part_state(6),part_state(7),part_state(8)];
tmp_state = double(~tmp_state); %Expectation is this may resolve the "inverted states" issue
tmp_state = num2str(tmp_state);
tmp_state(isspace(tmp_state))='';
state = bin2dec(tmp_state)+1;
end
function a = epsigreed(s,Q,exp,varargin)
pn = rand(1);
if ~isempty(varargin)

    if strcmp(varargin{1},'Predicted')
        act = varargin{2};
        arr = [1,2,3,4,5,6,7,8,1];
        Q = [Q(:,arr(act)),Q(:,arr(act))];
        if pn>= exp
            [~,newact] = max(Q(s,:));
        else
            newact = randi([1,size(Q,2)]);
        end
        a = arr(varargin{2} + (newact-1));
        %end
    else
        if pn >= exp
            [~,a] = max(Q(s,:));
        else
            a = randi([1,size(Q,2)]);
        end
    end
else
% epsilon greedy typically has a set "exploration rate" which does not need
% to increase over time?
if pn >= exp
    [~,a] = max(Q(s,:));
else
    a = randi([1,size(Q,2)]);
end
end
end

function takefirstaction(agent,action)
traci.trafficlights.setPhase(agent,(2*action)-1)
end

function taketranaction(agent,action,oldaction)
if action==oldaction    %If new action taken is the same are the prior
    traci.trafficlights.setPhase(agent,(action*2)-1)
    traci.trafficlights.setPhaseDuration(agent,13000)
else                    %If a new action is being taken
    iter = 1:2:15;
    %traci.trafficlights.setPhase(agent,iter(oldaction))
    traci.trafficlights.setPhase(agent,iter(oldaction)-1)
end
end
function actionManager(agent,action,oldaction,timecheck,phaseTime,firstPhase)
if timecheck >= phaseTime + firstPhase
    if action == oldaction
        if rem(timecheck,phaseTime)==0
            currPhase = traci.trafficlights.getPhase(agent);
            if currPhase == 1
                traci.trafficlights.setPhase(agent,34)
                pedPurge(20,PedAI(1).Walkarea,PedAI(1).EdgeID,'SouthPed_')
                pedPurge(20,PedAI(3).Walkarea,PedAI(3).EdgeID,'NorthPed_')
            elseif currPhase == 5
                traci.trafficlights.setPhase(agent,32)
                pedPurge(20,PedAI(1).Walkarea,PedAI(1).EdgeID,'SouthPed_')
                pedPurge(20,PedAI(3).Walkarea,PedAI(3).EdgeID,'NorthPed_')
            elseif currPhase == 34
                traci.trafficlights.setPhase(agent,1)
            elseif currPhase == 32
                traci.trafficlights.setPhase(agent,5)
            elseif currPhase == 9
                traci.trafficlights.setPhase(agent,35)
                pedPurge(20,PedAI(2).Walkarea,PedAI(2).EdgeID,'WestPed_')
                pedPurge(20,PedAI(4).Walkarea,PedAI(4).EdgeID,'EastPed_')
            elseif currPhase == 15
                traci.trafficlights.setPhase(agent,33)
                pedPurge(20,PedAI(2).Walkarea,PedAI(2).EdgeID,'WestPed_')
                pedPurge(20,PedAI(4).Walkarea,PedAI(4).EdgeID,'EastPed_')
            elseif currPhase == 35
                traci.trafficlights.setPhase(agent,9)
            elseif currPhase == 33
                traci.trafficlights.setPhase(agent,15)
            end

            %             if currPhase==5
            %                 traci.trafficlights.setPhase(agent,32)
            %             elseif currPhase == 32
            %                 traci.trafficlights.setPhase(agent,5)
            %             elseif currPhase == 15
            %                 traci.trafficlights.setPhase(agent,33)
            %             elseif currPhase == 33
            %                 traci.trafficlights.setPhase(agent,15)
            %             else
            traci.trafficlights.setPhase(agent,(action*2)-1);
            %end
        end
    else
        if rem(timecheck,phaseTime)==0
            currPhase = traci.trafficlights.getPhase(agent);
            if oldaction==1
                if action==4
                    traci.trafficlights.setPhase(agent,16)
                elseif action==3
                    if currPhase == 1
                        traci.trafficlights.setPhase(agent,39)
                    elseif currPhase == 34
                        traci.trafficlights.setPhase(agent,24)
                    else
                        error('Potential Timing Error Detected')
                    end
                else
                    traci.trafficlights.setPhase(agent,0)
                end
            elseif oldaction == 2
                if action==4
                    traci.trafficlights.setPhase(agent,17)
                elseif action==3
                    traci.trafficlights.setPhase(agent,25)
                else
                    traci.trafficlights.setPhase(agent,2)
                end
            elseif oldaction == 3
                if action==1
                    if currPhase == 32
                        traci.trafficlights.setPhase(agent,18)
                    elseif currPhase == 5
                        traci.trafficlights.setPhase(agent,36)
                    else
                        error('Potential Timing Error Detected')
                    end
                elseif action==2
                    traci.trafficlights.setPhase(agent,26)
                else
                    traci.trafficlights.setPhase(agent,4)
                end
            elseif oldaction == 4
                if action==1
                    traci.trafficlights.setPhase(agent,19)
                elseif action==2
                    traci.trafficlights.setPhase(agent,27)
                else
                    traci.trafficlights.setPhase(agent,6)
                end
            elseif oldaction == 5
                if action==8
                    if currPhase == 35
                        traci.trafficlights.setPhase(agent,20)
                    elseif currPhase == 9
                        traci.trafficlights.setPhase(agent,38)
                    else
                        error('Potential Timing Error Detected')
                    end
                elseif action==7
                    traci.trafficlights.setPhase(agent,28)
                else
                    traci.trafficlights.setPhase(agent,8)
                end
            elseif oldaction == 6
                if action==7
                    traci.trafficlights.setPhase(agent,21)
                elseif action==8
                    traci.trafficlights.setPhase(agent,29)
                else
                    traci.trafficlights.setPhase(agent,10)
                end
            elseif oldaction == 7
                if action==5
                    traci.trafficlights.setPhase(agent,22)
                elseif action==6
                    traci.trafficlights.setPhase(agent,30)
                else
                    traci.trafficlights.setPhase(agent,12)
                end
            elseif oldaction == 8
                if action==5
                    if currPhase == 33
                        traci.trafficlights.setPhase(agent,23)
                    elseif currPhase == 15
                        traci.trafficlights.setPhase(agent,38)
                    else
                        error('Potential Timing Error Detected')
                    end
                elseif action==6
                    traci.trafficlights.setPhase(agent,31)
                else
                    traci.trafficlights.setPhase(agent,14)
                end
            else
                error('Unknown Action Requested')
            end
        elseif rem(timecheck,phaseTime)==3
            currPhase = traci.trafficlights.getPhase(agent);
            if currPhase == 39 && oldaction == 1
                traci.trafficlights.setPhase(agent,32)
            elseif currPhase == 36 && oldaction == 3
                traci.trafficlights.setPhase(agent,34)
            elseif currPhase == 37 && oldaction == 5
                traci.trafficlights.setPhase(agent,33)
            elseif currPhase == 38 && oldaction == 8
                traci.trafficlights.setPhase(agent,35)
            elseif currPhase == 18 && oldaction == 3
                traci.trafficlights.setPhase(agent,1)
            elseif currPhase == 24 && oldaction == 1
                traci.trafficlights.setPhase(agent,5)
            elseif currPhase == 23 && oldaction == 8
                traci.trafficlights.setPhase(agent,9)
            elseif currPhase == 20 && oldaction == 5
                traci.trafficlights.setPhase(agent,15)
            else
                traci.trafficlights.setPhase(agent,(action*2)-1)
            end
        end
    end
end


end