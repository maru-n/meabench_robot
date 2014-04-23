fn='/home/bakkum/Desktop/031007-spikefile/031007_B.spikeform'



y=loadspikeform(fn); 
                    % need to change size to 44 !
                    % need to change freq to 25 !
                    

        T = y.T;
        L = y.L;
        C = y.C;
        H = y.H;
        W = y.W;
       Th = y.Th;
        E = y.E;
     clid = y.clid;
      PTS = y.PTS;
     P_hw = y.P_hw;
    P_num = y.P_num;
      P_t = y.P_t;
     CLID = y.CLID;


plot(T,'.')


probe=47; 


plot(T,P_hw,'.')

xx=find(P_hw==47);
plot(diff(T(xx)),'.')



xx=find(P_hw==10);
plot(diff(T(xx)),'.')


% E=6  -- context
% E=16 -- probe
% E=2  -- pts?
xx=find(E==6);
plot(diff(T(xx)),'.')



%%

clear fn; 

% DIV10
clear fn; tit='DIV10 pre media change'
fn{1}='/home/bakkum/glucose/Glu1_AM_1_200912131614.csv';


%
clear fn; tit='DIV1 post media change'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_200912141751.csv';
fn{2}='/home/bakkum/glucose/Glu7_AM_2_200912141751.csv';
fn{3}='/home/bakkum/glucose/Glu3_AM_3_200912141751.csv';
%
clear fn; tit='DIV3 pre media change'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_200912171517.csv';
fn{2}='/home/bakkum/glucose/Glu7_AM_2_200912171517.csv';
fn{3}='/home/bakkum/glucose/Glu3_AM_3_200912171517.csv';


clear fn; tit='DIV4 post media change'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_200912171553.csv';
fn{2}='/home/bakkum/glucose/Glu7_AM_2_200912171553.csv';
fn{3}='/home/bakkum/glucose/Glu3_AM_3_200912171553.csv';


% long term recording DIV1-3
clear fn; tit='DIV1-3 long term'
fn{1}='/home/bakkum/glucose/Glu6_AM_1_200912141837.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_200912141837.csv';
fn{3}='/home/bakkum/glucose/Glu4_AM_3_200912141837.csv';
fn{4}='/home/bakkum/glucose/Glu5_AM_4_200912141837.csv';


% long term recording DIV4-6
clear fn; tit='DIV4-6 long term'
fn{1}='/home/bakkum/glucose/Glu6_AM_1_200912171635.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_200912171635.csv';
fn{3}='/home/bakkum/glucose/Glu4_AM_3_200912171635.csv';
fn{4}='/home/bakkum/glucose/Glu5_AM_4_200912171635.csv';


% long term recording DIV8 (26hrs44min)
clear fn; tit='DIV8 long term'
fn{1}='/home/bakkum/glucose/Glu6_AM_1_200912211208.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_200912211208.csv';
fn{3}='/home/bakkum/glucose/Glu4_AM_3_200912211208.csv';
fn{4}='/home/bakkum/glucose/Glu5_AM_4_200912211208.csv';



%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% ---- NEW PLATING - 12/22/2009 --- %
clear all
COMB=1;     if COMB, volt=[{0} {0} {0} {0}]; end  % combine voltage readings for each channel

% long term recording DIV1-3 (66hrs4min)
clear fn; tit='091223 DIV1-3 long term'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_200912231707.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_200912231707.csv';
fn{3}='/home/bakkum/glucose/Glu5_AM_3_200912231707.csv';
fn{4}='/home/bakkum/glucose/Glu6_AM_4_200912231707.csv';
if COMB, for i=1:length(fn), volt{i}=[volt{i} loadglucosevoltage(fn{i})]; end; end


% ~~ media change ~~ %  ????? maybe not changed here ?

% long term recording DIV4-5 
clear fn; tit='091226 DIV4-5 long term'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_200912261412.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_200912261412.csv';
fn{3}='/home/bakkum/glucose/Glu5_AM_3_200912261412.csv';
fn{4}='/home/bakkum/glucose/Glu6_AM_4_200912261412.csv';
if COMB, for i=1:length(fn), volt{i}=[volt{i} 0]; end; end
if COMB, for i=1:length(fn), volt{i}=[volt{i} loadglucosevoltage(fn{i})]; end; end
% long term recording DIV6
clear fn; tit='091228 DIV6 long term'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_200912282002.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_200912282002.csv';
fn{3}='/home/bakkum/glucose/Glu5_AM_3_200912282002.csv';
fn{4}='/home/bakkum/glucose/Glu6_AM_4_200912282002.csv';
if COMB, for i=1:length(fn), volt{i}=[volt{i} 0]; end; end
if COMB, for i=1:length(fn), volt{i}=[volt{i} loadglucosevoltage(fn{i})]; end; end

% ~~ media change ~~ %

% long term recording DIV7
clear fn; tit='091229 DIV7 long term'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_200912291447.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_200912291447.csv';
fn{3}='/home/bakkum/glucose/Glu5_AM_3_200912291447.csv';
fn{4}='/home/bakkum/glucose/Glu6_AM_4_200912291447.csv';
if COMB, for i=1:length(fn), volt{i}=[volt{i} 0]; end; end
if COMB, for i=1:length(fn), volt{i}=[volt{i} loadglucosevoltage(fn{i})]; end; end
% long term recording DIV8-9
clear fn; tit='091230 DIV8-9 long term'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_200912302056.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_200912302057.csv';
fn{3}='/home/bakkum/glucose/Glu5_AM_3_200912302057.csv';
fn{4}='/home/bakkum/glucose/Glu6_AM_4_200912302057.csv';
if COMB, for i=1:length(fn), volt{i}=[volt{i} 0]; end; end
if COMB, for i=1:length(fn), volt{i}=[volt{i} loadglucosevoltage(fn{i})]; end; end
% long term recording DIV10-12
clear fn; tit='100102 DIV10-12 long term'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_201001020119.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_201001020119.csv';
fn{3}='/home/bakkum/glucose/Glu5_AM_3_201001020119.csv';
fn{4}='/home/bakkum/glucose/Glu6_AM_4_201001020119.csv';
if COMB, for i=1:length(fn), volt{i}=[volt{i} 0]; end; end
if COMB, for i=1:length(fn), volt{i}=[volt{i} loadglucosevoltage(fn{i})]; end; end


% ~~ media change ~~ %

% long term recording DIV13-14
clear fn; tit='100104 DIV13-14 long term'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_201001041215.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_201001041215.csv';
fn{3}='/home/bakkum/glucose/Glu5_AM_3_201001041215.csv';
fn{4}='/home/bakkum/glucose/Glu6_AM_4_201001041215.csv';
if COMB, for i=1:length(fn), volt{i}=[volt{i} 0]; end; end
if COMB, for i=1:length(fn), volt{i}=[volt{i} loadglucosevoltage(fn{i})]; end; end

% long term recording DIV15-17
clear fn; tit='100106 DIV15-17 long term'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_201001061755.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_201001061755.csv';
fn{3}='/home/bakkum/glucose/Glu5_AM_3_201001061755.csv';
fn{4}='/home/bakkum/glucose/Glu6_AM_4_201001061755.csv';
if COMB, for i=1:length(fn), volt{i}=[volt{i} 0]; end; end
if COMB, for i=1:length(fn), volt{i}=[volt{i} loadglucosevoltage(fn{i})]; end; end

% long term recording DIV18-19
clear fn; tit='100109 DIV18-19 long term'
fn{1}='/home/bakkum/glucose/Glu2_AM_1_201001091145.csv';
fn{2}='/home/bakkum/glucose/Glu1_AM_2_201001091145.csv';
fn{3}='/home/bakkum/glucose/Glu5_AM_3_201001091145.csv';
fn{4}='/home/bakkum/glucose/Glu6_AM_4_201001091145.csv';
if COMB, for i=1:length(fn), volt{i}=[volt{i} 0]; end; end
if COMB, for i=1:length(fn), volt{i}=[volt{i} loadglucosevoltage(fn{i})]; end; end


if COMB, tit='glucose sensor recordings'; end

figure
hold off
clr=jet(length(volt)*2);
%for i=length(fn):-1:1
for i=1:length(volt)
% volt1=loadglucosevoltage(fn{i});
% plot(volt,'color',clr(i,:)); hold on
x=[1:length(volt{i})]/60/60;
plot(x,volt{i},'color',clr(i,:)); hold on
end
title(tit); legend show


%%
save('/home/bakkum/Desktop/GlucoseSensorVoltRecording.mat','volt')


%%




