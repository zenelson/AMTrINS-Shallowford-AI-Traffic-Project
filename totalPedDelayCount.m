function [PedAI] = totalPedDelayCount(PedAI)
%totalPedDelayCount Assess Pededestrian Data
%   Generate relevant information regarding pedestrians at intersections in
%   a manner similar to vehicles
dataset = traci.person.getIDList();
northCell = cell(numel(dataset),2);
northCell(:,2) = num2cell(zeros(numel(dataset),1));
southCell = northCell;
eastCell = northCell;
westCell = northCell;
for i=1:numel(dataset)
    if contains(dataset{i},'WestPed')
        [Lia,Loc] = ismember(dataset{i},PedAI(2).data(:,1));
        if Lia==true
            westCell{i,2} = PedAI(2).data{Loc,2};
        end
            vel = traci.person.getSpeed(dataset{i});
            if vel <=0.1
                westCell{i,2} = westCell{i,2} + 1;
                westCell{i,1} = dataset{i};
            end
    elseif contains(dataset{i},'EastPed')
        [Lia,Loc] = ismember(dataset{i},PedAI(4).data(:,1));
        if Lia==true
            eastCell{i,2} = PedAI(4).data{Loc,2};
        end
            vel = traci.person.getSpeed(dataset{i});
            if vel<=0.1
                eastCell{i,2} = eastCell{i,2} + 1;
                eastCell{i,1} = dataset{i};
            end
    elseif contains(dataset{i},'NorthPed')
        [Lia,Loc] = ismember(dataset{i},PedAI(3).data(:,1));
        if Lia==true
            northCell{i,2} = PedAI(3).data{Loc,2};
        end
            vel = traci.person.getSpeed(dataset{i});
            if vel<=0.1
                northCell{i,2} = northCell{i,2} + 1;
                northCell{i,1} = dataset{i};
            end
    elseif contains(dataset{i},'SouthPed')
        [Lia,Loc] = ismember(dataset{i},PedAI(1).data(:,1));
        if Lia==true
            southCell{i,2} = PedAI(1).data{Loc,2};
        end
            vel = traci.person.getSpeed(dataset{i});
            if vel<=0.1
                southCell{i,2} = southCell{i,2} + 1;
                southCell{i,1} = dataset{i};
            end
    else
        error('Something weird is happening with the ID List')
    end
end
northCell = northCell(~cellfun(@isempty,northCell(:,1)),:);
eastCell = eastCell(~cellfun(@isempty,eastCell(:,1)),:);
westCell = westCell(~cellfun(@isempty,westCell(:,1)),:);
southCell = southCell(~cellfun(@isempty,southCell(:,1)),:);
PedAI(1).data = southCell;
PedAI(2).data = westCell;
PedAI(3).data = northCell;
PedAI(4).data = eastCell;
for i=1:4
    count = cell2mat(PedAI(i).data(:,2));
    if isempty(count)
        PedAI(i).recentPedMax = 0;
        PedAI(i).recentPedTotal = 0;
        PedAI(i).data = {'empty'};
    else
        PedAI(i).recentPedMax = max(count);
        PedAI(i).recentPedTotal = sum(count);
    end
end
end

