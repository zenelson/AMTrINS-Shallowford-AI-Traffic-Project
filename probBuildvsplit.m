function [output,compareMat] = probBuildvsplit(nVeh,obsLength,gapLength,vehLength,numLanes1,numLanes2,divisionPoint)
%probBuild Calculate probability of vehicles being within distance to join
%a queue
%   Program develops a matrix representing the number of vehicles that
%   could be served with the respective probability of achievement. The
%   program also utilizes dependent probability to calculate probabilities
%   based on changes caused by subsequent decisions of other vehicles.
%% Notice: 
%   Calculations may become less accurate if lane is congested to the point
%   that flow is nearly compact. However, liklihood is already very
%   unlikely and may be an impossible scenario.

%   Additionally, this algorithm may need special edits later to account
%   for conditional liklihood changes. Such as probBuild(2,200,203,5)
%   resulting in a probability of 0.9952 instead of 1 becuase the first
%   probability was < 1, despite other values being impossible. Possibly
%   set it up so the liklihood of all vehicles being serviced is the
%   difference of everything else.

%% Observations
% Total summation of probabilities seems to decrease with each additional
% vehicle added. May be due to potential error space that could occur if a
% vehicle is possibly skirting the edge or on the middle of the
% "observation" border. Could be remedied by making one of the "absolutes"
% a sum difference, possibly the "All Queued" option since all others have
% an intented "zero out" condition if probabilities are unrealistic.

%% Variables
%   nVeh: Number of vehicles in window [Integer]
%   obsLength: Length of observation window interacting with gap
%       (0-gapLength)
%   gapLength: Length of gap window being observed [Integer]
%   vehLength: 
%%

compareMat = zeros(nVeh+1,2);
totrat = 0:(nVeh-1);            %Ratio for total sequence
if obsLength + (nVeh*vehLength) > gapLength
    compareMat(1,:) = [nVeh,1];
    compareMat(2:end,1) = (nVeh-1):-1:0;
    output = nVeh;
else
    den = (divisionPoint*numLanes2) + ((gapLength-divisionPoint)*numLanes1);
    if divisionPoint > obsLength
        x = obsLength * numLanes2;
    elseif divisionPoint < obsLength
        x = divisionPoint*numLanes2 + (obsLength-divisionPoint)*numLanes1;
    elseif divisionPoint == obsLength
        x = obsPoint;
    end
    %totfull = prod((numLanes*obsLength)./((numLanes*gapLength)-(vehLength*totrat)));
    totfull = prod((x)./(den-(vehLength*totrat)));
    compareMat(1,:) = [nVeh,...
        min(totfull,1)];
    
    %numerator = (numLanes*(gapLength-obsLength)-(vehLength*totrat));
    %denominator = ((numLanes*gapLength)-(vehLength*totrat));
    denominator = den;
    numerator = x;
    %compareMat(end,:) = [0,...
    %prod((gapLength-obsLength-(vehLength*totrat)./(gapLength-(vehLength*totrat))))];
%    if ((gapLength-obsLength)*numLanes) < ((nVeh-1)*vehLength)
%        compareMat(end,:) = [0,0];%-Inf];
%    else
        compareMat(end,:) = [0,prod(numerator./denominator)];
%    end
    if nVeh > 1
        for i=(nVeh-1):-1:1         %i represents number of vehicles in observation window
            
            ii = nchoosek(1:nVeh,i);
            k = size(ii,1);
            out = zeros(k,nVeh);
            out(sub2ind([k,nVeh],(1:k)'*ones(1,i),ii))=1;
            
            for j=1:k
                fullRatio = find(out(j,:))-1;
                emptyRatio = find(~out(j,:))-1;
                
                %den = (divisionPoint*numLanes2) + ((gapLength-divisionPoint)*numLanes1);
                if divisionPoint > obsLength
                    full_num = obsLength * numLanes2;
                    empty_num = (gapLength-divisionPoint)*numLanes1 + (divisionPoint-obsLength)*numLanes2;
                elseif divisionPoint < obsLength
                    full_num = divisionPoint*numLanes2 + (obsLength-divisionPoint)*numLanes1;
                    empty_num = (gapLength-divisionPoint)*numLanes1;
                elseif divisionPoint == obsLength
                    full_num = obsLength*numLanes2;
                    empty_num = (gapLength-obsLength)*numLanes1;
                end
                %full_den = den - (vehLength*fullRatio);
                
                %full_num = obsLength*numLanes;
                %full_den = (numLanes*gapLength) - (vehLength*fullRatio);
                full_den = den - (vehLength*fullRatio);
                prob_full = prod(full_num./full_den);
                
                %negLength = numLanes*(gapLength-obsLength);
                %empty_num = negLength-vehLength*emptyRatio;
                %empty_den = (numLanes*gapLength)-vehLength*emptyRatio;
                empty_den = den - (vehLength*emptyRatio);
                prob_empty = prod(empty_num./empty_den);
                
                compareMat(nVeh-i+1,1) = i;
                compareMat(nVeh-i+1,2) = compareMat(nVeh-i+1,2)+(prob_full*prob_empty);
                
            end
            
            
            
            
%             full_num = obsLength*numLanes;
%             full_den = (numLanes*gapLength) - (vehLength*(0:(i-1)));
%             prob_full = min(prod(full_num./full_den),1);
%             %any(prob_full>1)=1;
%             
%             negLength = numLanes*(gapLength-obsLength);% - (i*vehLength);
%             empty_num = negLength-vehLength*((i):(nVeh-1));
%             empty_den = (numLanes*gapLength)-vehLength*((i):(nVeh-1));
%             prob_empty = prod(empty_num./empty_den);
%             
%             compareMat(nVeh-i+1,1) = i;
%             remLength = negLength - (i*vehLength);  %Remaining Length
%             necLength = (nVeh-i-1)*vehLength;         %Necessary Length
%             if remLength < necLength
%                 prob_empty = 0;%-Inf;
%             end
%             numopts = factorial(nVeh)/(factorial(i)*factorial(nVeh-i));
%             compareMat(nVeh-i+1,2) = numopts*(prob_full*prob_empty);         %Thought it would be factorial, but isn't
%             compareMat(1,2) = 1 - sum(compareMat(2:end,2));
        end
    end
    [~,index] = max(compareMat(:,2));
    output = compareMat(index,1);
end
end

