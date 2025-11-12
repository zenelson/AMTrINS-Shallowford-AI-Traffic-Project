function [agent,er] = BigMexInterface(agent,learnRate,discountFactor,seed,ratio,numagent,state)
%BigMexInterface Preload relevant data for the BigMex program
%   This portion of the code handles the Dyna-Q portion of the algorithm
%   and this was to assist in making programs more readable for development
%   purposes
newagent=struct();
for i=1:numagent
    newagent(i).ProbA=agent(i).ProbA;
    newagent(i).ProbS=agent(i).ProbS;
    newagent(i).Q=agent(i).Q;
    newagent(i).T=agent(i).T;
    newagent(i).microT = agent(i).microT;
    newagent(i).microR = agent(i).microR;
    newagent(i).validChoices=agent(i).validChoices;
    newagent(i).Reward=agent(i).Reward;
    newagent(i).state = state;
    newagent(i).limit = agent(i).QLimit;
    newagent(i).macroRInact = agent(i).macroRInact;
    newagent(i).macroRAct = agent(i).macroRAct;
    newagent(i).NS = 0;%agent(i).Safety.NS;
    newagent(i).EW = 0;%agent(i).Safety.EW;
end
[outagent,er] = BigMex(newagent,learnRate,discountFactor,seed,ratio,numagent);
for i=1:numagent
    agent(i).ProbA=outagent.ProbA;
    agent(i).ProbS=outagent.ProbS;
    agent(i).Q=outagent.Q;
end
end

