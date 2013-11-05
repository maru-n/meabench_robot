function HistogramISIn( SpikeTimes, N, Steps )
% ISI_N histogram plots 
% © Douglas Bakkum, 2013
%
%
%   HistogramISIn( SpikeTimes, N, Steps )
%        'SpikeTimes' [sec]   % Vector of spike times.
%        'N'                  % Vector of values for plotting ISI_N historgrams.
%        'Steps'      [sec]   % Vector of histogram edges.
%                   
%   Steps should be of uniform width on a log scale. Note that histograms
%   are smoothed using smooth.m with the default span and lowess method.
%
%
%   Example code:
%         SpikeTimes =  ---- ;             % Load spike times here.
%         N          = [2:10];             % Range of N to plot ISI_N histograms.
%         Steps      = 10.^[-5:.05:1.5];   % Create uniform steps for log plot.
%         HistogramISIn(SpikeTimes,N,Steps)
%

figure; hold on
map  = hsv(length(N));

cnt  = 0;
for FRnum = N
    cnt     = cnt + 1;
    ISI_N      = SpikeTimes( FRnum:end ) - SpikeTimes( 1:end-(FRnum-1) ); 
    n       = histc( ISI_N*1000, Steps*1000);
    n       = smooth(n,'lowess');
    plot(Steps*1000,n/sum(n),'.-','color',map(cnt,:))
end

xlabel 'ISI, T_i - T_{i-(N-1) _{ }} [ms]'
ylabel 'Probability [%]'
set(gca,'xscale','log')
set(gca,'yscale','log')


        