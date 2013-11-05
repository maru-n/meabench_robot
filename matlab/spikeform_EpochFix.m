function spike = spikeform_EpochFix(Info, spike)
% Douglas Bakkum
% spike = spikeform_EpochFix(Info, spike)
%   Enter fixes for the epoch encoding code) into this file. Then 
%   run to fix spike.E encoding.
%
%   The 'Info' structure must include the field Info.Exptitle.
%   The 'spike' structure is given by running the FormatSpikeData code
%   and running loadspikeform.m


dac_info = 127; % DAC channel with epoch information

if( strcmp(Info.Exptitle,'090315-E3') )
   TMP=find(spike.E==112); spike.E(TMP)=0; 
elseif( strcmp(Info.Exptitle,'090528-A') )
   TMP=find(spike.E==127); spike.E(TMP)=29; 
elseif( strcmp(Info.Exptitle,'090606-A') )
   TMP=find(spike.E==0 & spike.T<1652); spike.E(TMP)=-1; %% maybe get this from not having DAC centered before first pulse
   TMP=find(spike.E>=127);        spike.E(TMP)=-1; 
   TMP=find(spike.E==7 & spike.T>2200); spike.E(TMP)=10;
end
%if( strcmp(Info.Exptitle,'090609-A') )
%   TMP=find(spike.E==0 & spike.T<1191); spike.E(TMP)=-1; 
%   TMP=find(spike.E==65 & spike.T>5790); spike.E(TMP)=97;
%end
if( strcmp(Info.Exptitle,'090609-B') )
   TMP=find(spike.E==0   & spike.T<8970);    spike.E(TMP)=-1; %% maybe get this from not having DAC centered before first pulse
   TMP=find(spike.E==127 & spike.T<11660); spike.E(TMP)=44; 
   TMP=find(spike.E>=127);           spike.E(TMP)=-1; 
   TMP=find(spike.E==84  & spike.T>15287);  spike.E(TMP)=-1; 
   TMP=find(spike.E==84  & spike.T<12000);  spike.E(TMP)=-1;
elseif( strcmp(Info.Exptitle,'090609-E') )
   %TMP=find(E==22 & T>22000); E(TMP)=33;
   %TMP=find(E==84 & T<27000); E(TMP)=-1;
   TMP=find(spike.E>=126); spike.E(TMP)=-1;
elseif( strcmp(Info.Exptitle,'090611-A') )
   TMP=find(spike.E==127 & spike.T>6000); spike.E(TMP)=45;
   TMP=find(spike.E>=126); spike.E(TMP)=-1;
elseif( strcmp(Info.Exptitle,'090611-B') )
   spike.spike.E(:)=4;
   Info.Parameter.ConfigNumber=1;
elseif( strcmp(Info.Exptitle,'090612-A') )
   TMP=find(spike.E==127 & spike.T>22000 & spike.T<22600); spike.E(TMP)=87; 
   TMP=find(spike.E>=127);           spike.E(TMP)=-1; 
elseif( strcmp(Info.Exptitle,'090613-A') )
   TMP=find(spike.E==127 & spike.T>9000  & spike.T<10000); spike.E(TMP)=38; 
   TMP=find(spike.E==127 & spike.T>24500 & spike.T<25500); spike.E(TMP)=101; 
   TMP=find(spike.E>=127);           spike.E(TMP)=-1; 
elseif( strcmp(Info.Exptitle,'090614-A') )
   TMP=find(spike.E>=127);           spike.E(TMP)=-1; 
   TMP=find(spike.E==0 & spike.T<471);     spike.E(TMP)=-1; 
elseif( strcmp(Info.Exptitle,'090615-A') )
   TMP=find(spike.E==127 & spike.T<4300); spike.E(TMP)=21;
   TMP=find(spike.E>=126); spike.E(TMP)=-1;
elseif( strcmp(Info.Exptitle,'090618-A') )
   TMP=find(spike.E==127 & spike.T>8400 & spike.T<8530); spike.E(TMP)=52; 
   TMP=find(spike.E>=127);           spike.E(TMP)=-1; 
elseif( strcmp(Info.Exptitle,'090618-B') )
   TMP=find(spike.E==127 & spike.T>22650 & spike.T<23100); spike.E(TMP)=60; 
   TMP=find(spike.E>=127);           spike.E(TMP)=-1; 
elseif( strcmp(Info.Exptitle,'090622-A') )
   TMP=find(spike.E>=127);           spike.E(TMP)=-1; 
elseif( strcmp(Info.Exptitle,'090718-A') )
   TMP=find(spike.E>=127);           spike.E(TMP)=-1; 
   TMP=find(spike.E==63 & spike.T<12500);  spike.E(TMP)=37; 
elseif( strcmp(Info.Exptitle,'090803-A') )
   TMP=find(spike.E==127 & spike.T>22500 & spike.T<23500); spike.E(TMP)=58; 
   TMP=find(spike.E>=127);           spike.E(TMP)=-1; 
elseif( strcmp(Info.Exptitle,'100409-A') )
   TMP=find(spike.E==511); spike.E(TMP)=23; 
elseif( strcmp(Info.Exptitle,'101231-C') )
   TMP=find(spike.E==511); spike.E(TMP)=40; 
elseif( strcmp(Info.Exptitle,'110516-C') || strcmp(Info.Exptitle,'110513-C_s'))
    XX=find(spike.C==dac_info & spike.P_hw==dac_info & spike.E>=0);
    for i=1:length(XX)-1
        TT=find(spike.T>=spike.T(XX(i)) & spike.T<spike.T(XX(i+1)) & spike.E>=0);
        spike.E(TT)=spike.E(XX(i));
    end    
        TT=find(spike.T>=spike.T(XX(end)) & spike.E>=0);
        spike.E(TT)=spike.E(XX(end));    
elseif( strcmp(Info.Exptitle,'110517-A') )
   TMP=find(spike.E==0 & spike.T>9400); spike.E(TMP)=spike.E(TMP-4); 
elseif( strcmp(Info.Exptitle,'100110-F') )
   TMP=find(spike.E==0 & spike.T>1500); spike.E(TMP)=76; 
elseif( strcmp(Info.Exptitle,'100110-G') )
   TMP=find(spike.E==0 & spike.T>2600); spike.E(TMP)=22; 
end


if( strcmp(Info.Exptitle,'091230-B') )
   TMP=find(spike.E==0  & spike.T< 5398 & spike.T> 5390); spike.E(TMP)=8;
   TMP=find(spike.E==63 & spike.T<13405 & spike.T>13390); spike.E(TMP)=61;
   TMP=find(spike.E==0  & spike.T<11200 & spike.T>11170); spike.E(TMP)=11;
   TMP=find(spike.E==0  & spike.T<12449 & spike.T>12445); spike.E(TMP)=40;
   
   TMP=find(spike.E>=0  & spike.T>10646); spike.E(TMP)=spike.E(TMP)+126;
   TMP=find(spike.E>=0  & spike.T>15722); spike.E(TMP)=spike.E(TMP)+126;
elseif( strcmp(Info.Exptitle,'100101-B') )
    spike.T(10313607:end)=spike.T(10313607:end)+9000;
elseif( strcmp(Info.Exptitle,'100101-B') )
   %TMP=find(spike.E==0  & spike.T< 5398 & spike.T> 5390); spike.E(TMP)=8;
elseif( strcmp(Info.Exptitle,'100101-C') )
   TMP=find(spike.E==63 & spike.T< 3635 & spike.T> 3590); spike.E(TMP)=0;
   TMP=find(spike.E==0  & spike.T< 5470 & spike.T> 5462); spike.E(TMP)=36;
   TMP=find(spike.E==0  & spike.T< 7361 & spike.T> 7359); spike.E(TMP)=73;
   TMP=find(spike.E==0  & spike.T< 7952 & spike.T> 7950); spike.E(TMP)=84;
   TMP=find(spike.E==0  & spike.T< 9825 & spike.T> 9822); spike.E(TMP)=120;
   TMP=find(spike.E==63 & spike.T< 8765 & spike.T> 8760); spike.E(TMP)=-1;
   
   TMP=find(spike.E>=0  & spike.T>10101); spike.E(TMP)=spike.E(TMP)+126;
elseif( strcmp(Info.Exptitle,'100101-D') )
%    TMP=find(spike.E==63 & spike.T< 3976 & spike.T> 3970); spike.E(TMP)=20;
%    TMP=find(spike.E==0  & spike.T< 2078 & spike.T> 2076); spike.E(TMP)=4;
%    TMP=find(spike.E==0  & spike.T< 3109 & spike.T> 3104); spike.E(TMP)=12;
%    TMP=find(spike.E==0  & spike.T< 4297 & spike.T> 4291); spike.E(TMP)=22;
%    TMP=find(spike.E==0  & spike.T< 9696 & spike.T> 9686); spike.E(TMP)=68;
%    TMP=find(spike.E==0  & spike.T<10400 & spike.T>10380); spike.E(TMP)=74;
%    TMP=find(spike.E==0  & spike.T<10526 & spike.T>10520); spike.E(TMP)=75;
%    TMP=find(spike.E==0  & spike.T<11802 & spike.T>11798); spike.E(TMP)=86;
%    TMP=find(spike.E==63 & spike.T<16486 & spike.T>16485); spike.E(TMP)=0;
%    TMP=find(spike.E==34 & spike.T<28465 & spike.T>28455); spike.E(TMP)=98;
   
   TMP=find(spike.E>=0  & spike.T>16481); spike.E(TMP)=spike.E(TMP)+126;
   TMP=find(spike.E>=0  & spike.T>29657); spike.E(TMP)=spike.E(TMP)+126;
elseif( strcmp(Info.Exptitle,'100103-B') )
   TMP=find(spike.E==63 & spike.T>  229 & spike.T<  232); spike.E(TMP)=0;
   TMP=find(spike.E==63 & spike.T>17955 & spike.T<17958); spike.E(TMP)=21;
   TMP=find(spike.E==0  & spike.T> 2934 & spike.T< 2940); spike.E(TMP)=23;
   TMP=find(spike.E==0  & spike.T> 3198 & spike.T< 3200); spike.E(TMP)=25;
   TMP=find(spike.E==0  & spike.T> 4150 & spike.T< 4154); spike.E(TMP)=33;
   TMP=find(spike.E==0  & spike.T> 5266 & spike.T< 5268); spike.E(TMP)=42;
   TMP=find(spike.E==0  & spike.T> 5748 & spike.T< 5750); spike.E(TMP)=46;
   TMP=find(spike.E==0  & spike.T> 6848 & spike.T< 6852); spike.E(TMP)=55;
   TMP=find(spike.E==0  & spike.T> 7931 & spike.T< 7933); spike.E(TMP)=64;
   TMP=find(spike.E==0  & spike.T> 9644 & spike.T< 9647); spike.E(TMP)=78;
   TMP=find(spike.E==0  & spike.T>10843 & spike.T<10845); spike.E(TMP)=88;
   TMP=find(spike.E==0  & spike.T>11675 & spike.T<11678); spike.E(TMP)=95;
   TMP=find(spike.E==0  & spike.T>15177 & spike.T<15179); spike.E(TMP)=124;
   TMP=find(spike.E==0  & spike.T>15304 & spike.T<15306); spike.E(TMP)=125;
   TMP=find(spike.E==0  & spike.T>15936 & spike.T<15939); spike.E(TMP)=4;
   TMP=find(spike.E==0  & spike.T>18297 & spike.T<18299); spike.E(TMP)=24;
   TMP=find(spike.E==0  & spike.T>18407 & spike.T<18409); spike.E(TMP)=25;
   TMP=find(spike.E==0  & spike.T>18658 & spike.T<18659); spike.E(TMP)=26;
   TMP=find(spike.E==0  & spike.T>18780 & spike.T<18850); spike.E(TMP)=27;
   
   TMP=find(spike.E>=0  & spike.T>15345); spike.E(TMP)=spike.E(TMP)+126;
   
elseif( strcmp(Info.Exptitle,'100109-B') )   
   TMP=find(spike.E>=0  & spike.T>18180); spike.E(TMP)=spike.E(TMP)+126;
   TMP=find(spike.E>=0  & spike.T>27495); spike.E(TMP)=spike.E(TMP)+126;
elseif( strcmp(Info.Exptitle,'100109-C') )   
   TMP=find(spike.E==0  & spike.T>16273 & spike.T<16276); spike.E(TMP)=34;
   TMP=find(spike.E==0  & spike.T>20923 & spike.T<20925); spike.E(TMP)=89;
   TMP=find(spike.E==0  & spike.T>22512 & spike.T<22524); spike.E(TMP)=105;
   TMP=find(spike.E>=0  & spike.T>13318); spike.E(TMP)=spike.E(TMP)+126;
   TMP=find(spike.E>=0  & spike.T>23502); spike.E(TMP)=spike.E(TMP)+126;
end

     
%   TMP=find(spike.E==511); spike.E(TMP)=-1; 
 