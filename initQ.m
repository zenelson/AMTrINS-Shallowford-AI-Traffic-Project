function [Q] = initQ(numStates,numActions,decisionTime,numLanes,arrivalRate)
%initQ Modify Q-Values to reflect expected environment from SUMO traffic
%simulations
%   This program is meant to go through the output of all actions and apply
%   a baseline penalty for each lane that is not being serviced.

%Additional Note: The assessPenalty subfunction currently has the Active
%lanes IDs commented out as their default value was 0. However, these
%values are kept archived for customization.
%% Initialize Values
Q = zeros(numStates,numActions);
totalStates = dec2bin((numStates-1):-1:0,numActions);
%% Process every State-Action Pair for every possible State
for s=1:numStates
    for a=1:numActions
        Q(s,a) = assessPenalty(totalStates(s,:),decisionTime,numLanes,arrivalRate,a);
    end
end
%% Subfunction - assessPenalty
    function output = assessPenalty(binaryVal,decisionTime,numLanes,arrivalRate,action)
        if action==1
            %Active = [2,6];
            Inactive = [1,3,4,5,7,8];
        elseif action==2
            %Active = [1,5];
            Inactive = [2,3,4,6,7,8];
        elseif action==3
            %Active = [1,2];
            Inactive = [3,4,5,6,7,8];
        elseif action==4
            %Active = [5,6];
            Inactive = [1,2,3,4,7,8];
        elseif action==5
            %Active = [4,8];
            Inactive = [1,2,3,5,6,7];
        elseif action==6
            %Active = [3,7];
            Inactive = [1,2,4,5,6,8];
        elseif action==7
            %Active = [3,4];
            Inactive = [1,2,5,6,7,8];
        elseif action==8
            %Active = [7,8];
            Inactive = [1,2,3,4,5,6];
        else
            error('Invalid Action Selected')
        end
        subActivePenalty = zeros(1,2);
        for i=1:2
            subActivePenalty(i)=0;
        end
        ActivePenalty = sum(subActivePenalty);
        subInactivePenalty = zeros(1,6);
        for i=1:6
            subfactor = Inactive(i);
            if binaryVal(subfactor)==1      %If the Substate is Full
                subInactivePenalty(i) = 4*decisionTime*numLanes(subfactor)+arrivalRate(subfactor)*decisionTime;
            elseif binaryVal(subfactor)==0  %If the Substate is Empty
                subInactivePenalty(i) = arrivalRate(subfactor)*decisionTime;
            end
        end
        InactivePenalty = sum(subInactivePenalty);
        output = -1*(ActivePenalty+InactivePenalty);
    end

end

