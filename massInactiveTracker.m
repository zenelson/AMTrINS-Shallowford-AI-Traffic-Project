function [Agent,Caddy] = massInactiveTracker(Agent,Caddy)
%massInactiveTracker Updates all agents
%   Creates the delay metrics for future and inactive lanes
ActionArray = [0,1,0,0,0,1,0,0;...
    1,0,0,0,1,0,0,0;...
    1,1,0,0,0,0,0,0;...
    0,0,0,0,1,1,0,0;...
    0,0,0,1,0,0,0,1;...
    0,0,1,0,0,0,1,0;...
    0,0,1,1,0,0,0,0;...
    0,0,0,0,0,0,1,1];
for i=1:1
    Agent(i).inactiveTrack.Count = Agent(i).inactiveTrack.Count.*ActionArray(Agent(i).oldAction,:)...
        + ~ActionArray(Agent(i).oldAction,:);
    
    tempArray = Agent(i).inactiveTrack.Count >= Agent(i).inactiveTrack.actionTrigger;
    
    Agent(i).inactiveTrack.discountTracker = Agent(i).inactiveTrack.discountTracker...
        + tempArray*Agent(i).inactiveTrack.discountWindow;
    
    Agent(i).inactiveTrack.discountTracker = min(Agent(i).inactiveTrack.discountTracker,...
        Agent(i).inactiveTrack.discountWindow);
    
    weights = (Agent(i).inactiveTrack.discountTracker~=0).*Agent(i).inactiveTrack.discountWeight;
    
    x = (i-1)*8;
    Caddy(1+x).DelayFuture = Caddy(1+x).DelayFuture + weights(1).*Caddy(1+x).DelayFuture;
    Caddy(2+x).DelayFuture = Caddy(2+x).DelayFuture + weights(2).*Caddy(1+x).DelayFuture;
    Caddy(3+x).DelayFuture = Caddy(3+x).DelayFuture + weights(3).*Caddy(1+x).DelayFuture;
    Caddy(4+x).DelayFuture = Caddy(4+x).DelayFuture + weights(4).*Caddy(1+x).DelayFuture;
    Caddy(5+x).DelayFuture = Caddy(5+x).DelayFuture + weights(5).*Caddy(1+x).DelayFuture;
    Caddy(6+x).DelayFuture = Caddy(6+x).DelayFuture + weights(6).*Caddy(1+x).DelayFuture;
    Caddy(7+x).DelayFuture = Caddy(7+x).DelayFuture + weights(7).*Caddy(1+x).DelayFuture;
    Caddy(8+x).DelayFuture = Caddy(8+x).DelayFuture + weights(8).*Caddy(1+x).DelayFuture;
    
    Agent(i).inactiveTrack.discountTracker = max(Agent(i).inactiveTrack.discountTracker-1,0);
end
end

