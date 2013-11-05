function Burst_RS = RankSurpriseBurstDetector(tn,limit,RSalpha)
%"Rank Surprise" method for burst detection. Requires statistical toolbox
%of Matlab 6.5 or any program computing the Gaussian CDF.
%
%USE : [Burst_RS.RS,Burst_RS.length,Burst_RS.start]=burst(tn,limit,RSalpha)
%
%INPUT :  tn - spike times
%         limit - ISI value not to include in a burst
%         RSalpha - minimum surprise value to consider
%
%OUTPUT : Burst_RS.RS - "rank surprise" values for each burst detected
%         Burst_RS.length - burst length for each burst detected (in spikes)
%         Burst_RS.start – Spike number of burst start for each burst detected
 
%% Checking input
 
%risk level
if nargin<3,
    RSalpha=-log(0.01);  % -log(prob) level ; i.e. 'S' surprise value
%%%%    RSalpha=-log(0.9);  % db *****************
                            % -log(prob) level ; i.e. 'S' surprise value
                            % prob is prob being in the rank distribution ?
end;
 
%% General parameters
 
%limit for using the real distribution
q_lim=30;
%minimum length of a burst in spikes
l_min=5; % 3;   db ************************
 
%% General vectors
 
%vector (-1)^k
alternate=ones(400,1);
alternate(2:2:end)=-1;
%log factorials
log_fac=cumsum(log(1:q_lim));
%to make tn an horizontal vector
tn=tn(:)';
 
%% Ranks computation
 
%compute the ISI
ISI=diff(tn);
N=length(ISI);
%ISI value not to include in a burst
if nargin<2,
    %percentile 75% (default)
    %limit=prctile(ISI,75);
    limit=.1; % [sec] db ************* 
end;

% %compute ranks
% R=val2rk(ISI);

values = ISI;
    % function [ranks]=val2rk(values)
    %Convert values to ranks, with mean of ranks for tied values. Alternative
    %and faster version of "tiedrank" in statistical toolbox of Matlab 6-7.
    lp=length(values);
    [y,cl]=sort(values);
    rk(cl)=(1:lp);
    [y,cl2]=sort(-values);
    rk2(cl2)=(1:lp);
    ranks=(lp+1-rk2+rk)/2;
R=ranks;





%% Find sequences of ISI under 'limit'
 
% ISI = ISI(1:1000); % db ************************** takes LONG time, so maybe can get ranks on all data and just detect in small section


ISI_limit=diff(ISI<limit);
%first time stamp of these intervals
begin_int=find(ISI_limit==1)+1;
%manage the first ISI
if ISI(1)<limit,
    begin_int=[1 begin_int];%the first IS is under limit
end;
%last time stamp of these intervals
end_int=find(ISI_limit==-1);
%manage the last ISI
if length(end_int)<length(begin_int),
    end_int=[end_int N];
end;
%length of intervals of interest
length_int=end_int-begin_int+1;

 
%% Initializations
Burst_RS.RS=[];
Burst_RS.length=[];
Burst_RS.start=[];
 
%% Going through the intervals of interest
indic=0;
for n_j=begin_int,
    indic=indic+1;
    
    %if ~mod(indic,round(length(begin_int)/100)), fprintf('\t%i%%\n',round(100*indic/length(begin_int))); end
    %fprintf('\t%i\n',indic); 
    
    p_j=length_int(indic);
    subseq_RS=[];
    %test each set of spikes
    for i=0:p_j-(l_min-1),
        %length of burst tested
        q=l_min-2;
        while (q<p_j-i)
            q=q+1;
            %statistic
            u=sum(R(n_j+i:n_j+i+q-1));
            u=floor(u);
            if q<q_lim,
                %exact discrete distribution
                k=0:(u-q)/N;
                length_k=length(k);
                prob=exp((sum(log(u-repmat(k,q,1)*N-repmat((0:q-1)',1,length_k)))...
                  -log_fac([1 k(2:end)])-log_fac(q-k))-q*log(N))*alternate(1:length_k);
            else
                %approximate Gaussian distribution
                prob=normcdf((u-q*(N+1)/2)/sqrt(q*(N^2-1)/12));
            end;
            RS=-log(prob);
            %archive results for each subsequence [RSstatistic beginning length]
            if RS>RSalpha,
                subseq_RS(end+1,:)=[RS i q];
            end;
        end;
    end;
 
    %vet results archive to extract most significant bursts
    if ~isempty(subseq_RS),
        %sort RS for all subsequences
        subseq_RS=-sortrows(-subseq_RS,1);
 
        while ~isempty(subseq_RS),
            %extract most surprising burst
            current_burst=subseq_RS(1,:);
            Burst_RS.RS(end+1)=current_burst(1);
            Burst_RS.length(end+1)=current_burst(3)+1;%number of ISI involved + 1
            Burst_RS.start(end+1)=n_j+current_burst(2);
            %remove most surprising burst from the set
            %subseq_RS=subseq_RS(2:end,:);
            %keep only other bursts non-overlapping with this burst
            subseq_RS=subseq_RS(subseq_RS(:,2)+subseq_RS(:,3)-...
              1<current_burst(2)|subseq_RS(:,2)>current_burst(2)+current_burst(3)-1,:);
        end;
    end;
end;
 
%sort bursts by ascending time
[Burst_RS.start,ind_sort]=sort(Burst_RS.start);
Burst_RS.RS=Burst_RS.RS(ind_sort);
Burst_RS.length=Burst_RS.length(ind_sort);
 
%% Utility - Rank computation
%  
% function [ranks]=val2rk(values)
% %Convert values to ranks, with mean of ranks for tied values. Alternative
% %and faster version of "tiedrank" in statistical toolbox of Matlab 6-7.
% lp=length(values);
% [y,cl]=sort(values);
% rk(cl)=(1:lp);
% [y,cl2]=sort(-values);
% rk2(cl2)=(1:lp);
% ranks=(lp+1-rk2+rk)/2;
%  















































