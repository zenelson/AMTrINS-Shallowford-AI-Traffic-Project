function [Agent,Caddy] = multiAgentManager(Agent,Caddy,alpha,beta)
%multiAgentManager Designed to clean up main program
%   Detailed explanation goes here
[Agent,Caddy] = massInactiveTracker(Agent,Caddy);
Agent = massDelayBuildComplexInactive(Agent,Caddy,alpha,beta);
Agent = massActiveDelayBuildComplex(Agent,Caddy,alpha,beta);
Agent = massDelayBuildComplexRow(Agent,Caddy,alpha,beta);
Agent = massActiveDelayBuildComplexRow(Agent,Caddy,alpha,beta);
Agent = massDefaultRewardUpdate(Agent,Caddy, 13,alpha,beta);

end

