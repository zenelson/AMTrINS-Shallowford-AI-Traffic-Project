function cleanupSUMO()
try
traci.close()
!taskkill /im sumo-gui.exe /t /f
clc
catch
    warning('SUMO or TRACI closed improperly. Restarting to force-close'); 
%    traci_start('InfRd.sumocfg');
    traci.close();
    !taskkill /im sumo-gui.exe /t /f
    clc
end
end