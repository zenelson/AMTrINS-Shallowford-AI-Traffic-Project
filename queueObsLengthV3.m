function [Range,v_final,v_init,finalX] = queueObsLengthV3(queueOG,dur,delay,headway,queue,window,count,numLanes)
%queueObsLengthV3 Estimate total amount of roadway needed for a vehicle at
%full speed to reach the end of a queue
%   This program utilizes simple physics equations and various conditions
%   to attempt to assess the total amount of roadway that a vehicle may
%   need to safely join a queue without causing a collision
time_to_accl = 17.88/2.6; %Time for an idle vehicle to accelerate to 
                            %top speed 
initX = queueOG*5 + max(0,queueOG-1)*2.5; %Initial position of vehicle 
                                            % in idle queue
runTime = max(dur-delay,0);    % Total time the queue has been exposed 
                                % to green lights

queueOG = ceil(queueOG/numLanes);
queue = ceil(queue/numLanes);
if dur==0
    window = window-delay;
end
if queueOG > 0
    %% Initial Velocity
    activeTime = max(0,runTime-queueOG); %Account for delays from Queue Length
    init_accelRuntime = min(time_to_accl,activeTime); %Determine how long
                                                         % it's had time
                                                         % to accelerate
    v_init = 2.6*init_accelRuntime; %Estimate initial velocity in 
                                        % observation window
    %% Initial Position
    x_init = initX - v_init*max(runTime-init_accelRuntime,0)...
        -(0.5*2.6*init_accelRuntime*init_accelRuntime); %Re-assess init 
                                            % position after certain time
    %% Final Velocity
    final_accelRuntime = min(time_to_accl,activeTime+window);
    v_final = 2.6*final_accelRuntime;
    %% Final Position
    alpha = time_to_accl-init_accelRuntime;    %Measure how much longer 
                                                % does the car need to 
                                                % reach peak speed
    alpha = min(window,alpha);  %Check in case it cannot accelerate in time
    if v_init < 17.88
        x_accel = v_init*alpha + 0.5*2.6*alpha*alpha;
    else
        x_accel = 0;
    end
    if alpha == window %If vehicle had to accelerate during entire window
        x_vel = 0;
    else
        x_vel = 17.88*(window-alpha);
    end
    x_final = (x_init-x_accel-x_vel);
    finalX = max(0,x_final);
else
    x_init = 0;
    x_final = 0;
    v_init = 17.88;
    v_final = 17.88;
    finalX = x_final;
end
%% Range Calculations
if (count == 0 && v_init == 17.88) 
    Range = 0;
elseif count == 0  && v_init < 17.88
    Range = rangeBuilder(v_init,v_final,x_init,x_final,headway);
elseif count > 0
    time_decel = 17.88/4.5;
    length_decel = (17.88*time_decel) - (0.5*4.5*time_decel*time_decel) ...
        + 2.5;
    if queue > 0
        x_final = queue*5 + max(0,(queue-1)*2.5);
    else
        x_final = 0;
    end
    Range = 17.88*window + length_decel - (x_init-x_final);
end 


    function output = rangeBuilder(v_init,v_final,x_init,x_final,headway)
        if v_final == 17.88
            time=(17.88-v_init)/2.6;
            time = floor(time);
            v_inter = v_init+2.6*time;
            x_inter = x_init-(v_init*time)-(0.5*2.6*time*time);
        else
            time = 5;
            v_inter = v_final;
            x_inter = x_final;
        end
        %% Deceleration of Lead
        lead_decel = v_inter/4.5;
        lead_dist = v_inter*lead_decel - (0.5*4.5*lead_decel*lead_decel);
        %% Deceleration of Follower
        foll_decel = 17.88/4.5;
        foll_dist = 17.88*foll_decel - (0.5*4.5*foll_decel*foll_decel) + ...
            17.88*headway;
        %% Range Calculation
        output = foll_dist - lead_dist + 2.5 + 5 + 17.88*time ...
            - (x_init-x_inter); %Range should be connected to 
                                % x_init in probability calculations
    end
end

