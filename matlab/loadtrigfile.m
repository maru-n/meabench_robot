function trig=loadtrigfile(trigfile,fig)
% trig = LOADTRIGFILE(trigfile,plot) 
%          Douglas Bakkum 2012
%      Extract data from an Meabench trigfile.raw.trig text file. 
%      Returns structure 'trig':
%   trig.N   - index Number
%   trig.T   - trig Time
%   trig.E   - trig Epoch
%
 trigl=load(trigfile,'-ascii');
 trig.N=trigl(:,1); % number (some may have been dropped)
 trig.T=trigl(:,2); % time
 if size(trigl,2)>2
    trig.E=trigl(:,3); % epoch
    % fix for single config, set epoch to zero to help later analysis code
    if length(unique(trig.E))==1
         trig.E = trig.E*0;  
    end
 end
 fprintf('\n--> %i triggers found.\n\n',length(trig.N));
 

