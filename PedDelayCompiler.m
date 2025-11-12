function [Caddy] = PedDelayCompiler(PedAI,Caddy,Theta)
%PedDelayCompiler Create delay peanlties for pedestrians
%   Utilizing similar vehicle delay metrics to process total delay-based
%   penalties for pedestrians left inactive at intersections
Caddy(2).DelayFuture = (1-Theta)*Caddy(2).DelayFuture + Theta*PedAI(1).inactiveDelay + Theta*PedAI(3).inactiveDelay;

Caddy(8).DelayFuture = (1-Theta)*Caddy(8).DelayFuture + Theta*PedAI(2).inactiveDelay + Theta*PedAI(4).inactiveDelay;

end

