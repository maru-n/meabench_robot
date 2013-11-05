function y=loadspike(fn,range,freq)
% y=LOADSPIKE(fn) loads spikes from given filename into structure y
% with members
%   time    (1xN) (in samples)
%   channel (1xN)
%   height  (1xN)
%   width   (1xN)
%   context (75xN)
%   thresh  (1xN)
% y=LOADSPIKE(fn,range,freq_khz) converts times to seconds and width to
% milliseconds using the specified frequency, and the height and
% context data to microvolts by multiplying by RANGE/2048.
% As a special case, range=0..3 is interpreted as a MultiChannel Systems 
% gain setting:
% 
% range value   electrode range (uV)    auxillary range (mV)
%      0               3410                 4092
%      1               1205                 1446
%      2                683                  819.6
%      3                341                  409.2
% 
% "electrode range" is applied to channels 0..59, auxillary range is
% applied to channels 60..63.
% In this case, the frequency is set to 25 kHz unless specified.

% matlab/loadspike.m: part of meabench, an MEA recording and analysis tool
% Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


if nargin<2
  range=nan;
end
if nargin<3
  freq=nan;
end

fid = fopen(fn,'rb');
if (fid<0)
  error('Cannot open the specified file');
end
sz=84; %% was 82 in Atlanta...; sizeof(spikeinfo)
raw = fread(fid,[sz inf],'uint16');
fclose(fid);

ti0 = raw(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
ti1 = raw(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
ti2 = raw(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
ti3 = raw(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
y.time = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)));

y.channel = raw(5,:);

hi0 = raw(6,:); idx = find(hi0>32768); hi0(idx) = hi0(idx);%-65536;
y.height = hi0;
y.width = raw(7,:);
y.context = raw(8:81,:);
y.thresh = raw(82,:);
y.last1 = raw(83,:); %appears no data here
y.last2 = raw(84,:); %appears no data here


    if isnan(freq)
      freq = 20.0;
    end
       
    
     uvperdigi = 1;%11.7/16 * 1000/958.558;% 11.7mV/8-bit (3V range); meabench uses 12-bit (mcs convention) -- 16=2^12 / 2^8; 1000 to put into uV; 958 is standard CMOS gain (A1-30, A2-30 A3-bypass)
     mvperdigi = 11.7/16; % aux
     
%      isaux = find(y.C>=126);
%      iselc = find(y.C<126);
%      y.height(iselc) = y.height(iselc)  .* uvperdigi;
%      y.thresh(iselc) = y.thresh(iselc)  .* uvperdigi;
%      y.height(isaux) = y.height(isaux)  .* mvperdigi;
%      y.thresh(isaux) = y.thresh(isaux)  .* mvperdigi;
    
     y.time = y.time ./ (freq*1000);
     y.width = y.width ./ freq;
  
  
