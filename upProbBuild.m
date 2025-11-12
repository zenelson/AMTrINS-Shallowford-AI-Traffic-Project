function [upProbMat,stateProb] = upProbBuild(queueMat,oldActive,queue,Count,numLanes,vehLength,vehGap,obsWindow,GapMap,absVal)
%upProbBuild Creates probability matrix to estimate liklihood of a full
%transition

% Checks various conditions to assist how many of each vehicle may join the
% queue
% Please note that this program is somewhat computationally costly and may
% benefit from being replaced with another AI program, possibly PINN. 
% 
% If wondering why it wasn't done yet, please bear in mind making the first
% traffic AI was a headache and a half, and adding another AI on top of the
% first AI would have taken a whole lot longer


stateProb = zeros(2,2);    %Placeholder while state calculations are made
stateProb(1,1) = 1;
%% Input Variables Necessary
% queueMat - Matrix containing all relevant Queue Update probability values
%   from prior update ["Based on the prior state's service rate and influx
%   rate, this is the liklihood of X amount of vehicles joining the static
%   queue"] [Note: The matrix is in descending order (i.e. The first row
%   represents all vehicles joining the queue with the final row representing
%   no vehicles joining the queue)]

% activeMap - Array containing all currently active (i.e.
%   Non-processed/Non-Queued) vehicles along a roadway

% queue - Total Number of vehicles considered to be waiting to cross an
%   intersection and are either idle (Static) or approaching the
%   queue/intersection (Dynamic)

% count - Number of vehicles assessed to have recently entered the roadway
%   from a source

% numLanes - Number of lanes associated with a roadway (Necessary for
% calculation of a "Full State")

%vehLength - Estimated Length of Vehicle

%vehGap - Estimated inter-vehicular gap

%obsWindow - Observation Window implemented for observing/monitoring
%traffic densities along roadway

%GapMap - List of breaking points between various segments in a system

%absVal - Absolute Values of GapMap
%% Procedure
% Initialize upstream probability table

%upProbMat = zeros(5,2);
%upProbMat(1:5,1) = 100:-25:0;
upProbMat = zeros((4*numLanes + 1),2);
upProbMat(:,1) = linspace(0,100,(4*numLanes + 1)); %Meant to scale with multi-lane setups
% Cycle-Update active array
remainder = oldActive(1); %
actMap = circshift(oldActive,-1);
actMap(end) = Count;
% Begin processing each of the possible values from queueMat
for i=1:size(queueMat,1)
    %Create Temporary vehicle map
    tmpMap = actMap;
    %Remove prospective number of vehicles from closest segment
    %Thought: Maybe add catch/check in case we reach a <0 scenario
    %Add respective values to vehicle queue
    tmpQueue = queue + queueMat(i,1);
    %Process the starting position based on current/estimated queue
    if tmpQueue >= (numLanes*4)
        type = 1;
        stateProb(1,2) = queueMat(i,2)*1;
        upStart = 4*vehLength + 3*vehGap;
        % Further edits/testing pending
    elseif (queue + remainder) >= (numLanes*4)
        type = 2;
        stateProb(1,2) = queueMat(i,2)*1;
        upStart = 180;
    else
        type = 3;
        %state = 0;
        upStart = obsWindow;
    end
    %% Develop Prediction Arrays
    if type==1 %Enough cars are idle to start after the 4th car.
        if tmpQueue >= (2*4*numLanes)
            upProbMat(1,2) = upProbMat(1,2) + queueMat(i,2);
        else
            limiter = upStart + obsWindow;
            X = find(GapMap < limiter);
            if isempty(X)
                X = 1;
            end
            %Consider creating safeguard value (GapMap(end)) if X returns
            %an out of bounds error?
            guaranteed = 0;     %Number of upstream vehicles measured guaranteed based on fully encompassed behavior
            for j=1:X(1)
                if GapMap(j) < limiter
                    guaranteed = guaranteed + tmpMap(j);
                else
                    obsLength = GapMap(j)-limiter; %absVal(j)-(GapMap(j)-(limiter)); %Need to check for accuracy
                    [~,Mat1] = probBuildv2(tmpMap(j),obsLength,absVal(j),vehLength,numLanes);
                end
            end
        end
    elseif type==2 %Enough Vehicles in sensor region for "Full State"
        guaranteed = 0;
        limiter = upStart + obsWindow;
        X = find(GapMap > limiter);
        if isempty(X)
            X = 1;
        end
        for j=1:X(1)
            if GapMap(j) < limiter
                guaranteed = guaranteed + tmpMap(j);
            else
                obsLength = limiter - GapMap(1); %May Need to be modified to be more robust
                [~,Mat1] = probBuildv2(tmpMap(j),obsLength,absVal(j),vehLength,numLanes);
            end
        end
    elseif type==3 %Not enouch vehicles for "Full State". This is the largest measurable range
        guaranteed = 0;
        limiter = upStart;% + obsWindow;
        obsLength = GapMap(1)-limiter;
        [~,Mat1] = probBuildv2(tmpMap(1),obsLength,absVal(1),vehLength,numLanes);
        if length(tmpMap) < 2
            Mat2 = [0,1];
        elseif limiter*2 >= GapMap(end)
            obsLength2 = min(obsWindow-obsLength,absVal(2));
            [~,Mat2] = probBuildv2(tmpMap(2),obsLength2,absVal(2),vehLength,numLanes);
        else
            obsLength2 = obsWindow - obsLength; %Remainder of observation window
            [~,Mat2] = probBuildv2(tmpMap(2),obsLength2,absVal(2),vehLength,numLanes);
        end
        
    else
        error('Invalid Type Present')
    end
    %% Assess State/Upstream Probabilities
    if (type==1 || type==2) && (tmpQueue < (2*4*numLanes))
        Mat1(:,1) = Mat1(:,1) + guaranteed;
        for k=1:size(Mat1,1)
            if (Mat1(k,1)+1) > size(upProbMat,1)
                upProbMat(end,2) = upProbMat(end,2) + queueMat(i,2)*Mat1(k,2);
            else
                upProbMat(Mat1(k,1)+1,2) = upProbMat(Mat1(k,1)+1,2) + queueMat(i,2)*Mat1(k,2);
                %upProbMat(Mat1(k,1),2) = upProbMat(Mat1(k,1),2) + queueMat(i,2)*Mat1(k,2);
            end
        end
    elseif type==3
        MatBoth = zeros((size(Mat1,1)*size(Mat2,1)),2);
        iter = 1;
        for m=1:size(Mat1,1)
            for n=1:size(Mat2,1)
                MatBoth(iter,1) = Mat1(m,1)+Mat2(n,1) + guaranteed;
                MatBoth(iter,2) = Mat1(m,2)*Mat2(n,2);
                iter = iter+1;
            end
        end
        for k=1:size(MatBoth,1)
            if MatBoth(k,1) >= size(upProbMat,1)
                upProbMat(end,2) = upProbMat(end,2) + queueMat(i,2)*MatBoth(k,2);
            else
                upProbMat(MatBoth(k,1)+1,2) = upProbMat(MatBoth(k,1)+1,2) + queueMat(i,2)*MatBoth(k,2);
            end
        end
        MatInv = Mat1;

        MatInv(:,1) = MatInv(:,1) + queue + remainder;
        for m=1:size(MatInv)
            if MatInv(m,1) >= 4*numLanes %If Full
                stateProb(1,2) = stateProb(1,2) + queueMat(i,2)*MatInv(m,2);
            else %If Empty
                stateProb(2,2) = stateProb(2,2) + queueMat(i,2)*MatInv(m,2);
            end
        end
    end
end
end