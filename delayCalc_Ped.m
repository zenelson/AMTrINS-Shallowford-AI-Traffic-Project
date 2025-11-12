function [calcDelay,arrayVal,activearray] = delayCalc_Ped(pedData,DelayVal,gamma)
%delayCalc_Ped Generate pedestrian delay values
%   Replicate delay metrics similar to vehicles, but for pedestrian traffic
calcDelay = 0;
array = zeros(1,numel(DelayVal));
if size(pedData,2)>1
    for i=1:size(pedData,1)
        index = min(floor(pedData{i,2}/13)+1,numel(DelayVal));
        if index > 0
            calcDelay = calcDelay + gamma*DelayVal(index);
            array(index) = array(index) + 1;
        end
    end
    
    if isempty(array)
        activearray = 0;
        arrayVal = 0;
    else
        array = circshift(array,1);
        array(end) = array(end) + array(1);
        array(1) = 0;
        arrayVal = 0;
        for i=1:length(array)
            arrayVal = arrayVal + gamma*DelayVal(i)*array(i);
        end
        activearray = array;
        x = 24;
        for i=1:length(activearray)
            activearray(i) = max(0,activearray(i)-x);
            x = x-activearray(i);
            if x < 0
                break
            end
        end
        futureval = 0;
        for i=1:length(activearray)
            futureval = futureval + gamma*activearray(i)*DelayVal(i);
        end
        activearray = futureval;
    end
else
    calcDelay = 0;
    arrayVal = 0;
    activearray = 0;
end
end

