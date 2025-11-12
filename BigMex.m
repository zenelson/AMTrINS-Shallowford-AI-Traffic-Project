function [newagent,er] = BigMex(newagent,learnRate,discountFactor,seed,ratio,numagent)
%BigMex Run specified Dyna-Q learning models
%   This program runs different versions of Dyna-Q learning based on
%   conditions such as different traffic conditions or testing different
%   scenarios
er = zeros(1,numagent);
for i=1:numagent
    if newagent.NS > 1 && newagent.EW == 0
        [new_Qs, ~, ~, ~] = MDPTestPedNS(newagent(i).validChoices, newagent(i).Reward, discountFactor, 1000,seed,newagent(i).T,newagent(i).microT,newagent(i).microR,newagent(i).state,ratio,newagent.limit,newagent.macroRInact,newagent.macroRAct);
    elseif newagent.EW > 1 && newagent.NS == 0
        [new_Qs, ~, ~, ~] = MDPTestPedEW(newagent(i).validChoices, newagent(i).Reward, discountFactor, 1000,seed,newagent(i).T,newagent(i).microT,newagent(i).microR,newagent(i).state,ratio,newagent.limit,newagent.macroRInact,newagent.macroRAct);
    elseif newagent.EW > 1 && newagent.NS > 1
        [new_Qs, ~, ~, ~] = MDPTestPedNSEW(newagent(i).validChoices, newagent(i).Reward, discountFactor, 1000,seed,newagent(i).T,newagent(i).microT,newagent(i).microR,newagent(i).state,ratio,newagent.limit,newagent.macroRInact,newagent.macroRAct);
    else
        [new_Qs, ~, ~, ~] = MDPTestMicroV2(newagent(i).validChoices, newagent(i).Reward, discountFactor, 1000,seed,newagent(i).T,newagent(i).microT,newagent(i).microR,newagent(i).state,ratio,newagent.limit);
    end
     %Added to process normalizing error
     nullVal = new_Qs>=0;
     new_Qs(nullVal) = newagent(i).Q(nullVal);
     newagent(i).Q = newagent(i).Q + learnRate.*(new_Qs-newagent(i).Q);
    [Pa,Ps] = Prop_Calculate_MicroV2(newagent(i).microT,newagent(i).Q,newagent(i).state);
    delta_Pa = max(abs(Pa-newagent(i).ProbA));
    delta_Ps = max(abs(Ps-newagent(i).ProbS));
    newagent(i).ProbS = Ps;
    newagent(i).ProbA = Pa; 
    er(i) = max([delta_Pa,delta_Ps]);
end
end

