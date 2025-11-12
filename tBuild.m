function [bigMatrix] = tBuild(Action,Startup,upS,upA,downS,downA)
%tBuild Create a 256x256 transitional matrix for a given action
%   Creates and calculates all possible transitional liklihoods for given
%   states and dependent on a specific action
persistent map
% 1: Southbound
% 2: Westbound
% 3: Northbound
% 4: Eastbound

up = [1,1,2,2,3,3,4,4];         %References the starting position (upstream)
down = [4,1,1,2,2,3,3,4];       %References the ending position (downstream)
actionval = [0 1 0 0 0 1 0 0;   %Determines if a transition is relevant based on selected action and start/end points
    1 0 0 0 1 0 0 0;
    1 1 0 0 0 0 0 0;
    0 0 0 0 1 1 0 0;
    0 0 0 1 0 0 0 1;
    0 0 1 0 0 0 1 0;
    0 0 1 1 0 0 0 0;
    0 0 0 0 0 0 1 1];

iter = [0,2,0,2,0,2,0,2];

bigMatrix = ones(256,256);      %Construct initial transition matrix array

%Purpose of map: Appears to create a 256x256 matrix for each of the 8 State
%sources (Southbound-Left, Southbound-Through, etc.)
%Values of 4: Full to Full?
%Values of 3: Empty to Full?
%Values of 2: Full to Empty?
%Values of 1: Empty to Empty?
if isempty(map)                 %Create map if nonexistent?
    map = zeros(256,256,8);
    for i = 1:1:8               %For every sub-state
        [map(:,:,i)] = mapBuilder(i);
    end
end

for i=1:8       %For each State configuration
    tmpMat = matrixbuilder(upS(up(i),:),upA(up(i),:),downS(down(i),:),downA(down(i),:),actionval(Action,i),iter(i));    %Build a portion of the matrix
    bigMatrix = bigMatrix.*tmpMat(map(:,:,i));  %Update the matrix with new parts
end


    function [mapOut] = mapBuilder(mapNo)
        outMapStart = repmat(~Startup(:,mapNo)+1,1,256);
        outMapEnd   = repmat(~Startup(:,mapNo)'+1,256,1);
        
        mapOut = (outMapEnd-1).*2+outMapStart;
    end


    function [output] = matrixbuilder(upS,upA,downS,downA,act,iter)
        x = iter+1;         %Is Action 2 correct for this application?
        if act == 1         %If Action is Active
            P_Full = (upS(x+1)*upA(1))+(downS(1)*downA(2))-(upS(x+1)*upA(1)*downS(1)*downA(2));
            P_F_E = upS(x+1)*upA(1);
        else                %If Action is Inactive (Faces Red Light)
            P_Full = 1;
            P_F_E = upS(x);
        end
        output = [P_Full,(1-P_Full);
            P_F_E,(1-P_F_E)];
    end



end



