function [Q, V, policy, mean_discrepancy] = MDPTestMicroV2(X, R, discount, N,~,T,microT,microR,state,ratio,limit)
%MDPTestMicroV2 Runs Dyna-Q learning on an intersection to bolster learning
%rate
    
    S=256;
    A=8;

    % Initializations
    Q = zeros(S,A);
    Q(state,:)=1;
    mean_discrepancy = [];
    V=0;
    policy=0;
    validchoices=X;
    
    sPreRolled = randi([1,numel(validchoices)],1,(N/100)+10); 
    sNewPreRolled = rand(1,N); 
    si = 2; 
    s = validchoices(sPreRolled(1)); 
    randaction=randi([1,A],1,N);
    pn = rand(1,N);
    actionHist = zeros(1,N);
    for n=1:N/2
        
        % Reinitialisation of trajectories every 100 transitions
        if (mod(n,100)==0); s = validchoices(sPreRolled(si)); 
            si= si+1; 
        end
        
        % Action choice : greedy with increasing probability
        if (pn(n) < ratio(n))
            [~,a] = max(Q(s,:));
        else
            a=randaction(n);
        end
        
        s_new = fastSampleExperimental(sNewPreRolled(n),T(s,:,a));%,S);
        
        if iscell(R)
            r = R{a}(s,s_new);
        elseif ndims(R) == 3
            r = R(s,s_new,a);
        else
            r = R(s,a);
        end
        
        % Updating the value of Q
        % Decaying update coefficient (1/sqrt(n+2)) can be changed
        delta = -0.0001 + r + discount*max(max(Q(s_new,:)),limit) - max(Q(s,a),limit);
        dQ = (1/sqrt(n+2))*delta;
        Q(s,a) = max(Q(s,a),limit) + dQ;
        
        % Current state is updated
        s = s_new;
        
        
    end

    for n=1:N
        s = state;
        if (pn(n) < ratio(n))
            [~,a] = max(Q(s,:));
        else
            a=randaction(n);
        end
    actionHist(n+N/2) = a;
    s_new = fastSampleExperimental(sNewPreRolled(n),microT(1,:,a));%,S);
    R = microR;
    if iscell(R)
        r = R{a}(s,s_new);
    elseif ndims(R) == 3
        r = R(s,s_new,a);
    else
        r = R(s,a);
    end
    delta = -0.0001 + r + discount*max(max(Q(s_new,:)),limit) - max(Q(s,a),limit);
    dQ = delta;
    Q(s,a) = max(Q(s,a),limit) + dQ;
    end
end

