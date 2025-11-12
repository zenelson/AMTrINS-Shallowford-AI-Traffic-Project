function [filedata] = SUMOCaddyV2(filedata,startTime)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
source = pwd;
netData = append(source,'\',filedata.Net);
routeData = append(source,'\',filedata.Route);
addData = append(source,'\',filedata.Add1,',',source,'\',filedata.Add2);

docNode = com.mathworks.xml.XMLUtils.createDocument('configuration');
configuration = docNode.getDocumentElement;
entry_node = docNode.createElement('Input');

net_node = docNode.createElement('net-file');
net_node.setAttribute('value',netData);

route_node = docNode.createElement('route-files');
route_node.setAttribute('value',routeData);

add_node = docNode.createElement('additional-files');
add_node.setAttribute('value',addData);

configuration.appendChild(entry_node);
entry_node.appendChild(net_node);
entry_node.appendChild(route_node);
entry_node.appendChild(add_node);
% Possibly Add Processing Data?
proc_node = docNode.createElement('Processing');
tele_node = docNode.createElement('time-to-teleport');
tele_node.setAttribute('value',num2str(-1));
configuration.appendChild(proc_node);
proc_node.appendChild(tele_node);
%Time/Initialization event
timeProduct = docNode.createElement('Time');
configuration.appendChild(timeProduct);
timeStart = docNode.createElement('begin');
timeStart.setAttribute('value',num2str(startTime*3600));
timeProduct.appendChild(timeStart);
% End Processing Data Attempt
if isfile(append(filedata.Name,'.sumocfg'))
    delete(append(filedata.Name,'.sumocfg'))
end
if ~isfile(append(filedata.Name,'_Legacy.sumocfg'))
    xmlwrite(append(filedata.Name,'_Legacy.sumocfg'),docNode);
end
xmlwrite(append(filedata.Name,'.sumocfg'),docNode);
end

