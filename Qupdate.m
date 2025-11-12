function new_Q = Qupdate(old_state,old_action,new_state,r,Q,learnRate,discountFactor,limit)
%Qupdate Update the Q value of the agent
new_Q = Q;
if new_state ~= 0
    delta = r + discountFactor*max(max(Q(new_state,:)),limit)-max(Q(old_state,old_action),limit);
    dQ = learnRate*delta;
    new_Q(old_state,old_action) = Q(old_state,old_action) + dQ;
end
end
