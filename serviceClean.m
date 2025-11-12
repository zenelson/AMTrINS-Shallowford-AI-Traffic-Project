function [newqueue,numMap] = serviceClean(service,queue,numMap)
%serviceClean Remove vehicles from recorded data
%   This removes serviced vehicles from the referential data used for
%   assessing total delay penalties to each lane
if service > queue && ~isempty(numMap)
    newqueue = max(0,queue-service);
    service = service-queue;
    if numMap(1) < service && length(numMap) > 1
        numMap(2) = numMap(2)-(service-numMap(1));
        numMap(1) = 0;
    else
        numMap(1) = numMap(1) - service;
    end

else
    newqueue = queue-service;
end

end

