function map=mkpj(n,scheme)
% MKPJ Returns a perceptually improved Jet colormap
%   MKPJ (N,SCHEME) returns an Nx3 colormap. 
%   usage: map=mkpj(n,scheme);
%
% JUSTIFICATION: rainbow, or spectrum color schemes are considered a poor
% choice for scientific data display by many in the scientific community
% (see for example reference 1 and 3) in that they introduce artifacts 
% that mislead the viewer. "The rainbow color map appears as if its separated
% into bands of almost constant hue, with sharp transitions between hues. 
% Viewers perceive these sharp transitions as sharp transitions in the data,
% even when this is not the casein how regularly spaced (interval) data are
% displayed (quoted from reference 1). The default Matlab Jet is no exception.
% Please see examples in my previous FEX submission "Perceptually improved
% colormaps".
% This submission is intended to share the results of my work to create a
% more perceptually balanced, Jet colormap. Please see output arguments section
% for more details.
% A full series of posts on improved colormaps will appear on my blog at
% http://mycarta.wordpress.com/
%
%
%   arguments: (input)
%   scheme - can be one of the following strings:
%     'JetI'  
%       The new, more perceptually balanced, Jet color map. 
%       This explanation should be read in conjunction with the submitted figure 
%       "JET_idea_after_scaling_final_L_plt.png"
%       The idea to improve the default jet came to me after seeing the human
%       wavelenght discrimination curve from Gregory (1964) in the paper by 
%       Welland et al. (2006).
%       The top display in the figure is the standard Matlab Jet. Below it, 
%       second display, is the Luminance versus wavelenght profile. This is
%       essentially the same as plot you would find in the left plot of 
%       figure 3 in Rogowitz and Kalvin (2001). In the third display I reproduced
%       Gregory's curve. It's considering these two together that brought the
%       Eureka moment (though it took me a few experiments and some calculations
%       to line them up properly). The idea was: "can I use this curve to
%       dynamically stretch the rainbow where transitions are too sharp 
%       (basically around the cyan and yellow), compared to everywhere else?".
%       The answer is yes, it can be done. In practice this amounted to calculate
%       the "inverted" function in the fourth display. Assuming a distance of 1
%       between each of the 256 samples on the x axis in the original Jet colormap,
%       the function was used to resample it at non-integer distances (up
%       to 1.5 where the yellow is, unmodified at 1 where the cyan is, less
%       than 1 everywhere else) resulting in a greater number of samples in
%       the yellow area in the display compared to all the blue areas, with
%       the total number of samples staying at 256. The next step was to force
%       all these new samples back to a distance of 1, achieving a
%       continuously dynamic stretch. The resulting colormap is shown in
%       the fifth display and accompanied by its Luminance versus wavelenght
%       in the last display. This profile is noticeably more perceptually
%       balnced with gentler transitions and a compressive character. 
%       To me this is a very good result, even though it's not perfect. 
%       In an ideal world I would have paired one of the several human wavelenght 
%       discrimination curves found in Wyszecki and Stiles (2000) 
%       with in conjunction with the corresponding spectrum color functions
%       (many are referenced in the FEX submission "Spectral and XYZ Color
%       Functions"), but the problem I had was to identify a matching pair; 
%       a problem that in the end proved insurmountable.
%
%     'J'  
%       This is the original default Jet which I clipped to lign up with Gregory's curve.
%
%     'J_DB'
%       Modified by Douglas Bakkum to add a bit more red at the end.
%
%
%   n - scalar specifying number of points in the colorbar. Maximum n=256
%       If n is not specified, the size of the colormap is determined by the
%       current figure. If no figure exists, MATLAB creates one.
%
%
%   arguments: (output)
%   map - the output colormap i
% 
%  
%   Example: compare cape topography using the improved Jet vs. default Jet(clipped)
%     %  load cape;
%     %  imagesc(X); colormap(mkpj(128,'JetI')); colorbar;
%     %  figure;
%     %  imagesc(X); colormap(mkpj(128,'J')); colorbar;
%
%
%   See also: JET, HSV, GRAY, HOT, COOL, BONE, COPPER, PINK, FLAG, PRISM,
%             COLORMAP, RGBPLOT
% 
%
%   Other submissions of interest
%     Perceptually improved colormaps
%     http://www.mathworks.com/matlabcentral/fileexchange/28982
%
%     Haxby color map
%     www.mathworks.com/matlabcentral/fileexchange/25690-haxby-color-map
% 
%     Colormap and colorbar utilities
%     www.mathworks.com/matlabcentral/fileexchange/24371-colormap-and-color
%     bar-utilities-sep-2009
% 
%     Lutbar
%     www.mathworks.com/matlabcentral/fileexchange/9137-lutbar-a-pedestrian-colormap-toolbarcontextmenu-creator
% 
%     usercolormap
%     www.mathworks.com/matlabcentral/fileexchange/7144-usercolormap
% 
%     freezeColors
%     www.mathworks.com/matlabcentral/fileexchange/7943
%
%     Spectral and XYZ Color Functions
%     www.mathworks.com/matlabcentral/fileexchange/7021-spectral-and-xyz-color-functions
%
%     Bipolar Colormap
%     www.mathworks.com/matlabcentral/fileexchange/26026
%
%     colorGray
%     www.mathworks.com/matlabcentral/fileexchange/12804-colorgray
%
%     mrgb2gray
%     www.mathworks.com/matlabcentral/fileexchange/5855-mrgb2gray
%
%     CMRmap
%     www.mathworks.com/matlabcentral/fileexchange/2662-cmrmap-m
%
%     real2rgb & colormaps
%     www.mathworks.com/matlabcentral/fileexchange/23342-real2rgb-colormaps
%
%     Fire
%     http://www.mathworks.com/matlabcentral/fileexchange/31761-colormap-fire-optimized-for-print
%
%     Isolum
%     http://www.mathworks.com/matlabcentral/fileexchange/31762-colormap-isolum-optimized-for-print-color-vision-deficiency
%
%
%   Acknowledgements
%     For function architecture and code syntax I was inspired by:
%     Light Bartlein Color Maps 
%     www.mathworks.com/matlabcentral/fileexchange/17555
%     (and comments posted therein)
% 
%     For Lab=>RGB conversions I used:
%     Colorspace transforamtions
%     www.mathworks.com/matlabcentral/fileexchange/28790-colorspace-transfo
%     rmations
%
%     A great way to learn more about improved colormaps and making colormaps:
%     MakeColorMap
%     www.mathworks.com/matlabcentral/fileexchange/17552
%     blogs.mathworks.com/videos/2007/11/15/practical-example-algorithm-development-for-making-colormaps/
%
%
%  References
%     1)  Borland, D. and Taylor, R. M. II (2007) - Rainbow Color Map (Still) 
%         Considered Harmful
%         IEEE Computer Graphics and Applications, Volume 27, Issue 2
%         Pdf paper included in submission
% 
%     2)  Kindlmann, G. Reinhard, E. and Creem, S. Face-based Luminance Matching
%         for Perceptual Colormap Generation
%         IEEE - Proceedings of the conference on Visualization '02
%         www.cs.utah.edu/~gk/papers/vis02/FaceLumin.pdf
% 
%     3)  Light, A. and Bartlein, P.J. (2004) - The end of the rainbow? 
%         Color schemes for improved data graphics.
%         EOS Transactions of the American Geophysical Union 85 (40)
%         Reprint of Article with Comments and Reply
%         http://geography.uoregon.edu/datagraphics/EOS/Light-and-Bartlein.pdf
% 
%     4)  Rogowitz, B.E. and  Kalvin, A.D. (2001) - The "Which Blair project":
%         a quick visual method for evaluating perceptual color maps. 
%         IEEE - Proceedings of the conference on Visualization 01
%         www.research.ibm.com/visualanalysis/papers/WhichBlair-Viz01Rogowitz_Kalvin._final.pdf
% 
%     5)  Rogowitz, B.E. and  Kalvin, A.D. - Why Should Engineers and Scientists
%         Be Worried About Color?
%         www.research.ibm.com/people/l/lloydt/color/color.HTM
% 
%     6)  Rogowitz, B.E. and  Kalvin, A.D. - How NOT to Lie with Visualization
%         www.research.ibm.com/dx/proceedings/pravda/truevis.htm
%
%     7)  Welland, M., Donnelly, N., and Menneer, T., (2006) - Are we properly
%         using our brains in seismic interpretation? - The Leading Edge; February
%         2006; v. 25; No. 2
%         http://tle.geoscienceworld.org/cgi/content/abstract/25/2/142
%
%     8)  Wyszecki, G. and Stiles W. S. (2000) - Color Science: Concepts and 
%         Methods, Quantitative Data and Formulae, 2nd Edition, John Wiley and Sons
%         http://ca.wiley.com/WileyCDA/WileyTitle/productCd-0471399183.html
%
%     9)  Gregory, R.L. (1966) Eye and Brain: The Psychology of Seeing
%         Fifth edition, 1997 - http://press.princeton.edu/titles/6016.html
% 
%
%  Author: Matteo Niccoli
%  http://mycarta.wordpress.com/
%  matteo@mycarta.ca
%  Release: 1.00
%  Release date: September 28 2011


% error checking, defaults, valid schemes
error(nargchk(0,2,nargin))
error(nargoutchk(0,1,nargout))

if nargin<2
  scheme = 'JetI';
end
if nargin<1
  n = size(get(gcf,'colormap'),1);
end
if n>256
error('Maximum number of 256 points for colormap exceeded');
end

switch lower(scheme)
  case 'j_DB'
    baseMap = J_DB;
  case 'J_db'
    baseMap = J_DB;
  case 'j_db'
    baseMap = J_DB;
  case 'jeti'
    baseMap = JetI;
  case 'Jeti'
    baseMap = JetI;
  case 'jetI'
    baseMap = JetI;
  case 'j'
    baseMap = J;
  otherwise
    error(['Invalid scheme ' scheme])
end

% this is the kernel of MKPJ
idx1 = linspace(1,n,size(baseMap,1));
idx2 = [1:1:n];
map = interp1(idx1,baseMap,idx2,'cubic');

% subfuntions
function baseMap = J
baseMap=[0         0    0.8594
         0         0    0.9089
         0         0    0.9584
         0    0.0079    1.0000
         0    0.0574    1.0000
         0    0.1069    1.0000
         0    0.1564    1.0000
         0    0.2059    1.0000
         0    0.2555    1.0000
         0    0.3050    1.0000
         0    0.3545    1.0000
         0    0.4040    1.0000
         0    0.4535    1.0000
         0    0.5030    1.0000
         0    0.5525    1.0000
         0    0.6020    1.0000
         0    0.6515    1.0000
         0    0.7010    1.0000
         0    0.7506    1.0000
         0    0.8001    1.0000
         0    0.8496    1.0000
         0    0.8991    1.0000
         0    0.9486    1.0000
         0    0.9981    1.0000
    0.0476    1.0000    0.9524
    0.0971    1.0000    0.9029
    0.1466    1.0000    0.8534
    0.1961    1.0000    0.8039
    0.2456    1.0000    0.7544
    0.2952    1.0000    0.7048
    0.3447    1.0000    0.6553
    0.3942    1.0000    0.6058
    0.4437    1.0000    0.5563
    0.4932    1.0000    0.5068
    0.5427    1.0000    0.4573
    0.5922    1.0000    0.4078
    0.6417    1.0000    0.3583
    0.6912    1.0000    0.3088
    0.7407    1.0000    0.2593
    0.7903    1.0000    0.2097
    0.8398    1.0000    0.1602
    0.8893    1.0000    0.1107
    0.9388    1.0000    0.0612
    0.9883    1.0000    0.0117
    1.0000    0.9622         0
    1.0000    0.9127         0
    1.0000    0.8632         0
    1.0000    0.8137         0
    1.0000    0.7642         0
    1.0000    0.7146         0
    1.0000    0.6651         0
    1.0000    0.6156         0
    1.0000    0.5661         0
    1.0000    0.5166         0
    1.0000    0.4671         0
    1.0000    0.4176         0
    1.0000    0.3681         0
    1.0000    0.3186         0
    1.0000    0.2691         0
    1.0000    0.2195         0
    1.0000    0.1700         0
    1.0000    0.1205         0
    1.0000    0.0710         0
    1.0000    0.0215         0 ];

% 'J' modified slightly by Douglas Bakkum 2012 to add some more red at the end
% subfuntions
function baseMap = J_DB
baseMap=[0         0    0.8594
         0         0    0.9089
         0         0    0.9584
         0    0.0079    1.0000
         0    0.0574    1.0000
         0    0.1069    1.0000
         0    0.1564    1.0000
         0    0.2059    1.0000
         0    0.2555    1.0000
         0    0.3050    1.0000
         0    0.3545    1.0000
         0    0.4040    1.0000
         0    0.4535    1.0000
         0    0.5030    1.0000
         0    0.5525    1.0000
         0    0.6020    1.0000
         0    0.6515    1.0000
         0    0.7010    1.0000
         0    0.7506    1.0000
         0    0.8001    1.0000
         0    0.8496    1.0000
         0    0.8991    1.0000
         0    0.9486    1.0000
         0    0.9981    1.0000
    0.0476    1.0000    0.9524
    0.0971    1.0000    0.9029
    0.1466    1.0000    0.8534
    0.1961    1.0000    0.8039
    0.2456    1.0000    0.7544
    0.2952    1.0000    0.7048
    0.3447    1.0000    0.6553
    0.3942    1.0000    0.6058
    0.4437    1.0000    0.5563
    0.4932    1.0000    0.5068
    0.5427    1.0000    0.4573
    0.5922    1.0000    0.4078
    0.6417    1.0000    0.3583
    0.6912    1.0000    0.3088
    0.7407    1.0000    0.2593
    0.7903    1.0000    0.2097
    0.8398    1.0000    0.1602
    0.8893    1.0000    0.1107
    0.9388    1.0000    0.0612
    0.9883    1.0000    0.0117
    1.0000    0.9622         0
    1.0000    0.9127         0
    1.0000    0.8632         0
    1.0000    0.8137         0
    1.0000    0.7642         0
    1.0000    0.7146         0
    1.0000    0.6651         0
    1.0000    0.6156         0
    1.0000    0.5661         0
    1.0000    0.5166         0
    1.0000    0.4671         0
    1.0000    0.4176         0
    1.0000    0.3681         0
    1.0000    0.3186         0
    1.0000    0.2691         0
    1.0000    0.2195         0
    1.0000    0.1700         0
    1.0000    0.1205         0
    1.0000    0.0710         0
    1.0000    0.0215         0
    1.0000    0.0000    0.0000  %% edit starts here  
    0.9883    0.0000    0
    0.9388    0.0000    0
    0.8893    0.0000    0
    0.8398    0.0000    0
    0.7903    0.0000    0
    0.7407    0.0000    0 ];%
%     0.6912    0.0000    0
%     0.6417    0.0000    0
%     0.5922    0.0000    0   
%     0.5427    0.0000    0
%     0.4932    0.0000    0 ];

function baseMap = JetI
baseMap=[0    0.0116    1.0000
         0    0.0909    1.0000
         0    0.1791    1.0000
         0    0.2667    1.0000
         0    0.3472    1.0000
         0    0.4196    1.0000
         0    0.4849    1.0000
         0    0.5404    1.0000
         0    0.5878    1.0000
         0    0.6292    1.0000
         0    0.6658    1.0000
         0    0.6988    1.0000
         0    0.7290    1.0000
         0    0.7574    1.0000
         0    0.7846    1.0000
         0    0.8110    1.0000
         0    0.8370    1.0000
         0    0.8628    1.0000
         0    0.8885    1.0000
         0    0.9145    1.0000
         0    0.9410    1.0000
         0    0.9687    1.0000
    0.0005    0.9975    0.9995
    0.0298    1.0000    0.9702
    0.0653    1.0000    0.9347
    0.1055    1.0000    0.8945
    0.1524    1.0000    0.8476
    0.2094    1.0000    0.7906
    0.2787    1.0000    0.7213
    0.3565    1.0000    0.6435
    0.4364    1.0000    0.5636
    0.5154    1.0000    0.4846
    0.5903    1.0000    0.4097
    0.6582    1.0000    0.3418
    0.7183    1.0000    0.2817
    0.7714    1.0000    0.2286
    0.8176    1.0000    0.1824
    0.8579    1.0000    0.1421
    0.8936    1.0000    0.1064
    0.9254    1.0000    0.0746
    0.9540    1.0000    0.0460
    0.9800    1.0000    0.0200
    1.0000    0.9963         0
    1.0000    0.9743         0
    1.0000    0.9537         0
    1.0000    0.9344         0
    1.0000    0.9162         0
    1.0000    0.8987         0
    1.0000    0.8821         0
    1.0000    0.8659         0
    1.0000    0.8500         0
    1.0000    0.8343         0
    1.0000    0.8186         0
    1.0000    0.8025         0
    1.0000    0.7859         0
    1.0000    0.7683         0
    1.0000    0.7491         0
    1.0000    0.7276         0
    1.0000    0.7026         0
    1.0000    0.6728         0
    1.0000    0.6363         0
    1.0000    0.5915         0
    1.0000    0.5346         0
    1.0000    0.4602         0];
        


