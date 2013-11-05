function [bpB, bpA] = ums2000_setup;
% [bpB, bpA] = ums2000_setup;
%
% (See the code for the band frequencies and other parameters.)
%
% To run the filter use:
%   data = filtfilt(bpB,bpA,data); 
%
% Other notes:
%  h = dfilt.df2(B,A);                   % plot freq response of filter
%  fvtool(h,'FrequencyScale','log')      % plot freq response of filter
%  freqz(h)                              
%
%  freqz(bpB,bpA,[],Fs)                  % plot freq response of filter
%
%
%  easyspec(data,Fs);                    % David's spectrum favorite
%  frequencyAnalysis(data,Fs,'onesided') % Felix's freq analysis function
%


Fs        = 20000;                      % sampling rate
Wp        = [ 200  3000] * 2 / Fs;      % pass band
Ws        = [ 100  5000] * 2 / Fs;      % transition zone
[N,Wn]    = buttord(Wp,Ws,3,20);        % determines filter parameters
[bpB,bpA] = butter(N,Wn);               % builds filter

