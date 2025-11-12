function [Reward,rawGradient,learnGradient] = RewardUpdate(Reward,startState,endState,action,ObservedReward,LearnRate,rawGradient,learnGradient)
%RewardUpdate Update the values of the Reward Matrix
Reward(startState,endState,action) = Reward(startState,endState,action)...
                + LearnRate*(ObservedReward - Reward(startState,endState,action)); 
            
rawGradient(startState,endState,action) = ObservedReward - Reward(startState,endState,action);  
learnGradient(startState,endState,action) = LearnRate*(ObservedReward - Reward(startState,endState,action));
end