function [P_A,P_S] = Prop_Calculate_MicroV2(T,Q,state)
%Prop_Calc Calculates Propensity Values
%   Based on all available possible states and actions' Q value
%   combinations, what is the likelihood that we take some certain action
%   and end up in some state... (should not need to know the current state)


Q = Q(state,:);

% average or likelihood that action 1 or 2 is selected based on all
% possible Q values (value for taking that action in any possible state)
Q_max = max(Q);
Q =  Q - Q_max;
P_A = exp((Q))./sum(exp((Q)));
% we could also straight-up use softmax to calculate the state
% probabilities I think? 
probs = P_A;

% likelihood of ending in a certain state based on all possible actions and
% all possible prior states.

P_S = zeros(1,256);
Q=ones(1,1);
for i=1:8
    X = Q*T(:,:,i); %X is 1x256 long
    A=(probs(i).*X);
    B=sum(X);
    P_S = P_S + A./B;

end

% We could start with estimate and "learn" or update gradually the state
% probabilities over time. 

end

