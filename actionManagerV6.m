function actionManagerV6(agent,action,oldaction,timecheck,phaseTime,firstPhase,PedAI)
%actionManagerV6 Process necessary traffic configurations
%   Customize and modify the configuration of a traffic signal controller
%   to match specific configurations made by the agent to more accurately
%   model transitional states. This also ensures safeguards that actions
%   that could harm pedestrians are overruled and avoided, favoring the
%   next best option that avoids harm.
if timecheck >= phaseTime + firstPhase
    if rem(timecheck,phaseTime)==0 %If Actions are the Same
        currPhase = traci.trafficlights.getPhase(agent);
        if action == oldaction
            if currPhase == 46
                traci.trafficlights.setPhase(agent,34)
                pedPurge(20,PedAI(1).Walkarea,PedAI(1).EdgeID,'SouthPed_')
                pedPurge(20,PedAI(3).Walkarea,PedAI(3).EdgeID,'NorthPed_')
            elseif currPhase == 44
                traci.trafficlights.setPhase(agent,32)
                pedPurge(20,PedAI(1).Walkarea,PedAI(1).EdgeID,'SouthPed_')
                pedPurge(20,PedAI(3).Walkarea,PedAI(3).EdgeID,'NorthPed_')
            elseif currPhase == 34
                traci.trafficlights.setPhase(agent,1)
            elseif currPhase == 32
                traci.trafficlights.setPhase(agent,5)
            elseif currPhase == 47
                traci.trafficlights.setPhase(agent,35)
                pedPurge(20,PedAI(2).Walkarea,PedAI(2).EdgeID,'WestPed_')
                pedPurge(20,PedAI(4).Walkarea,PedAI(4).EdgeID,'EastPed_')
            elseif currPhase == 45
                traci.trafficlights.setPhase(agent,33)
                pedPurge(20,PedAI(2).Walkarea,PedAI(2).EdgeID,'WestPed_')
                pedPurge(20,PedAI(4).Walkarea,PedAI(4).EdgeID,'EastPed_')
            elseif currPhase == 35
                traci.trafficlights.setPhase(agent,9)
            elseif currPhase == 33
                traci.trafficlights.setPhase(agent,15)
            else
                traci.trafficlights.setPhase(agent,(action*2)-1);
            end
        else %If Actions are Changing
            if oldaction==1
                if currPhase == 46
                    pedPurge(20,PedAI(1).Walkarea,PedAI(1).EdgeID,'SouthPed_')
                    pedPurge(20,PedAI(3).Walkarea,PedAI(3).EdgeID,'NorthPed_')
                end
                if action==4
                    traci.trafficlights.setPhase(agent,16)
                elseif action==3
                    if currPhase == 46 || currPhase == 1
                        traci.trafficlights.setPhase(agent,43)
                    elseif currPhase == 34
                        traci.trafficlights.setPhase(agent,24)
                    else
                        error('Potential Timing Error Detected')
                    end
                else
                    traci.trafficlights.setPhase(agent,0)
                end
            elseif oldaction == 2
                if action==4
                    traci.trafficlights.setPhase(agent,17)
                elseif action==3
                    traci.trafficlights.setPhase(agent,25)
                else
                    traci.trafficlights.setPhase(agent,2)
                end
            elseif oldaction == 3
                if currPhase == 44
                    pedPurge(20,PedAI(1).Walkarea,PedAI(1).EdgeID,'SouthPed_')
                    pedPurge(20,PedAI(3).Walkarea,PedAI(3).EdgeID,'NorthPed_')
                end
                if action==1
                    if currPhase == 32
                        traci.trafficlights.setPhase(agent,18)
                    elseif currPhase == 44
                        traci.trafficlights.setPhase(agent,40)
                    else
                        error('Potential Timing Error Detected')
                    end
                elseif action==2
                    traci.trafficlights.setPhase(agent,26)
                else
                    traci.trafficlights.setPhase(agent,4)
                end
            elseif oldaction == 4
                if action==1
                    traci.trafficlights.setPhase(agent,19)
                elseif action==2
                    traci.trafficlights.setPhase(agent,27)
                else
                    traci.trafficlights.setPhase(agent,6)
                end
            elseif oldaction == 5
                if currPhase == 47
                    pedPurge(20,PedAI(2).Walkarea,PedAI(2).EdgeID,'WestPed_')
                    pedPurge(20,PedAI(4).Walkarea,PedAI(4).EdgeID,'EastPed_')
                end
                if action==8
                    if currPhase == 35
                        traci.trafficlights.setPhase(agent,20)
                    elseif currPhase == 47
                        traci.trafficlights.setPhase(agent,41)
                    else
                        error('Potential Timing Error Detected')
                    end
                elseif action==7
                    traci.trafficlights.setPhase(agent,28)
                else
                    traci.trafficlights.setPhase(agent,8)
                end
            elseif oldaction == 6
                if action==7
                    traci.trafficlights.setPhase(agent,21)
                elseif action==8
                    traci.trafficlights.setPhase(agent,29)
                else
                    traci.trafficlights.setPhase(agent,10)
                end
            elseif oldaction == 7
                if action==5
                    traci.trafficlights.setPhase(agent,22)
                elseif action==6
                    traci.trafficlights.setPhase(agent,30)
                else
                    traci.trafficlights.setPhase(agent,12)
                end
            elseif oldaction == 8
                if currPhase == 45
                    pedPurge(20,PedAI(2).Walkarea,PedAI(2).EdgeID,'WestPed_')
                    pedPurge(20,PedAI(4).Walkarea,PedAI(4).EdgeID,'EastPed_')
                end
                if action==5
                    if currPhase == 33
                        traci.trafficlights.setPhase(agent,23)
                    elseif currPhase == 45
                        traci.trafficlights.setPhase(agent,42)
                    else
                        error('Potential Timing Error Detected')
                    end
                elseif action==6
                    traci.trafficlights.setPhase(agent,31)
                else
                    traci.trafficlights.setPhase(agent,14)
                end
            else
                error('Unknown Action Requested')
            end
        end
    elseif rem(timecheck,phaseTime)==3
        NSPedCheck = numel(traci.edge.getLastStepPersonIDs(':Junction8_c1'));
        EWPedCheck = numel(traci.edge.getLastStepPersonIDs(':Junction8_c0'));
        if NSPedCheck > 1 && (action ~= 1 && action ~= 3)
            traci.trafficlights.setPhase(agent,34)
        elseif EWPedCheck > 1 && (action ~=5 && action ~= 8)
            traci.trafficlights.setPhase(agent,35)
        else
            currPhase = traci.trafficlights.getPhase(agent);
            if currPhase == 43
                traci.trafficlights.setPhase(agent,32)
            elseif currPhase == 40
                traci.trafficlights.setPhase(agent,34)
            elseif currPhase == 41
                traci.trafficlights.setPhase(agent,33)
            elseif currPhase == 42
                traci.trafficlights.setPhase(agent,35)
            else
                traci.trafficlights.setPhase(agent,(action*2)-1);
            end
        end
    elseif rem(timecheck,phaseTime)==10
        if action == 1
            traci.trafficlights.setPhase(agent,46)
        elseif action == 3
            traci.trafficlights.setPhase(agent,44)
        elseif action == 5
            traci.trafficlights.setPhase(agent,47)
        elseif action == 8
            traci.trafficlights.setPhase(agent,45)
        end
    end
end
end

