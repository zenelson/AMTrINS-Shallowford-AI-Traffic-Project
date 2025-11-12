function [T] = bigTransition(Agent,Startup,varargin)
%bigTransition Create generalized transition model
%   Create the transitional models for all possible instances for Dyna-Q
%   learning
T = zeros(256,256,8);

upState = [Agent.UpstreamProb.Southbound.State;
           Agent.UpstreamProb.Westbound.State;
           Agent.UpstreamProb.Northbound.State;
           Agent.UpstreamProb.Eastbound.State];
upAction = [Agent.UpstreamProb.Southbound.Action;
            Agent.UpstreamProb.Westbound.Action;
            Agent.UpstreamProb.Northbound.Action;
            Agent.UpstreamProb.Eastbound.Action];

downState = [Agent.DownstreamProb.Southbound.State;
             Agent.DownstreamProb.Westbound.State;
             Agent.DownstreamProb.Northbound.State;
             Agent.DownstreamProb.Eastbound.State];
downAction = [Agent.DownstreamProb.Southbound.Action;
              Agent.DownstreamProb.Westbound.Action;
              Agent.DownstreamProb.Northbound.Action;
              Agent.DownstreamProb.Eastbound.Action];

if ~isempty(varargin)
    arr = [1,2,3,4,5,6,7,8,1];
    for i=arr(varargin{1}):arr(varargin{1}+1)
        T(:,:,i) = tBuildUnrolled_mex(i,Startup,upState,upAction,downState,downAction);
    if any(isnan(T(:,:,i)))
        %save NanOut
        error('nan detcted')
    end
    end
else
    
for i=1:8   %For each Action that is taken
    T(:,:,i) = tBuild(i,Startup,upState,upAction,downState,downAction);
    if any(isnan(T(:,:,i)))
        %save NanOut
        error('nan detcted')
    end
end
end
% If sim pauses


end

