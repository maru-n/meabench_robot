function [up_y up_x]=reconstruct(y,factor)
% Douglas Bakkum
%
% [up_y up_x]=RECONSTRUCT(y,factor)
%
% Method to reconstruct signals (i.e. spike waveform) at higher sampling
% rates based on the Nyquist-Shannon sampling theorem and the
% Whitaker-Shannon interpolation formula.
%  y      = sampled signal (col), can use multiple traces (rows)
%  factor = (reconstructed sample rate) / (original sample rate)
%
%  up_y   = upsampled signal
%  up_x   = new indices such that plot(up_x,up_y) will overlay plot(y)
%


len=size(y,2);

upsamp=1/factor:1/factor:len;
up_y=zeros(size(y,1),length(upsamp));
rng=50; % decrease range of values used to calculate upsampled data point. This makes the calculation an approximation but reduces computational time for long data sets.
cnt=0;
for u=upsamp
    cnt=cnt+1;
    for s = 1:len
        up_y(:,cnt)=up_y(:,cnt)+(y(:,s)-y(:,1))*sinc((u-s)/1);
    end
    up_y(:,cnt)=up_y(:,cnt)+y(:,1);
%     ll = max([ 1  floor(u)-rng-1]);
%     ul = min([len  ceil(u)+rng  ]);
%     for s = ll:ul
%         up_y(:,cnt)=up_y(:,cnt)+(y(:,s)-y(:,ll))*sinc((u-s)/1);
%     end
%     up_y(:,cnt)=up_y(:,cnt)+y(:,ll);
end

up_x=[1:size(y,2)*factor]/factor;