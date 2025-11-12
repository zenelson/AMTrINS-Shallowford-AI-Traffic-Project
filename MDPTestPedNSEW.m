function [Q, V, policy, mean_discrepancy] = MDPTestPedNSEW(X, R, discount, N,~,T,microT,microR,state,ratio,limit,activeR,inactiveR)
%MDPTestPedNSEW Run Dyna-Q learning scenarios for pedestrian traffic

%   This program runs the Dyna-Q learning scenario while accounting for
%   pedestrians crosswalks in all four cardinal directions
    
    S=256;
    A=8;

    % Initializations
    Q = zeros(S,A);
    mean_discrepancy = [];
    V=0;
    policy=0;
    

    
    %
    validchoices=X;
    
    sPreRolled = randi([1,numel(validchoices)],1,(N/100)+10); 
    sNewPreRolled = rand(1,N); 
    si = 2; 
    s = validchoices(sPreRolled(1)); 
    randaction=randi([1,A],1,N);
    pn = rand(1,N);
    %% Traditional Long-Term
    for n=1:N
        
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
        
        s_new = fastSample(sNewPreRolled(n),T(s,:,a),S);
        
        if iscell(R)
            r = R{a}(s,s_new);
        elseif ndims(R) == 3
            r = R(s,s_new,a);
        else
            r = R(s,a);
        end
        
        % Updating the value of Q
        % Decaying update coefficient (1/sqrt(n+2)) can be changed
        delta = r + discount*max(max(Q(s_new,:)),limit) - max(Q(s,a),limit);
        dQ = (1/sqrt(n+2))*delta;
        Q(s,a) = max(Q(s,a),limit) + dQ;
        
        % Current state is updated
        s = s_new;
        
        
    end
    %% Modified Short-Term
    for n=1:N
        s = state;
        if (pn(n) < ratio(n))
            [~,a] = max(Q(s,:));
        else
            a=randaction(n);
        end
    
    s_new = fastSample(sNewPreRolled(n),microT(1,:,a),S);
    R = microR;
    if iscell(R)
        r = R{a}(s,s_new);
    elseif ndims(R) == 3
        r = R(s,s_new,a);
    else
        r = R(s,a);
    end
    if a == 1 || a==3
        Q_new = max(Q(s_new,1),Q(s_new,3));
        delta = r + discount*max(Q_new,limit) - max(Q(s,a),limit);
    elseif a == 5 || a == 8
        Q_new = max(Q(s_new,5),Q(s_new,8));
        delta = r + discount*max(Q_new,limit) - max(Q(s,a),limit);
    else
        delta = r + discount*max(max(Q(s_new,:)),limit) - max(Q(s,a),limit);
    end
    dQ = delta;%(1/sqrt(n+2))*delta;
    Q(s,a) = max(Q(s,a),limit) + dQ;
    end
end

