function [Caddy] = shortEdgeCleanup(Caddy,startPoint)
%shortEdgeCleanup Sort out data between negotiating agents
%   This version is still in development
for i=startPoint:(startPoint+7)
    if isempty(Caddy(i).GapMap)
        %Reset whole thing like it was a serviced lane!
        Caddy(i).Queue = Caddy(i).backup.Queue;
        Caddy(i).DelayHistory = Caddy(i).backup.DelayHistory;
    end
end
end

