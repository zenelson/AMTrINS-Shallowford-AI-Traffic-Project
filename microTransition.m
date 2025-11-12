function [microT] = microTransition(Agent,Startup,state,varargin)
%microTransition create localized and more specific transitional models
%   Based upon the same transitional models, this version focuses on
%   creating a more detailed transitional model for micro-Dyna-Q learning
%   models.
T = zeros(256,256,8);
microT = zeros(1,256,8);
upState = [Agent.UpstreamProb.Southbound.ShortProb;
           Agent.UpstreamProb.Westbound.ShortProb;
           Agent.UpstreamProb.Northbound.ShortProb;
           Agent.UpstreamProb.Eastbound.ShortProb];
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

  
for i=1:8   %For each Action that is taken
    T(:,:,i) = tBuild(i,Startup,upState,upAction,downState,downAction);
    if any(isnan(T(:,:,i)))
        %save NanOut
        error('nan detcted')
    end
end

for i=1:8
    microT(:,:,i) = T(state,:,i);
end

end

