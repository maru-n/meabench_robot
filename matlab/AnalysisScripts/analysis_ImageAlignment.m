
%% Image transformation and plotting



%% Do transform on single layer


dir         = '/home/bakkumd/Data_bak/130107-lipofection/images/';
name        = '130109-801-wide-1_ch00';

if strcmp(Info.Exptitle(1:6),'130829')
    dir         = '/home/bakkumd/Data_bak/130819-lipofection-tdimer-milos/images/';
    name        = '130829-1397-bottom-bright_ch00';
    name        = 'Overlay001';
end


imagename_i = [dir name '.jpg'];
imagename_o = [name '_transformed'];

%%

% !! NOTE !! 2013.09.03 updated svn accepting 'theirs full'

  hidens_register_images(imagename_i, 'version', 2,'saveas',imagename_o);
% hidens_register_images(imagename, 'version', 2,'saveas','zStackCombined','which_layer',3);
% hidens_register_images(imagename,'version',2,'resolution',1,'black')

%%

name2         = '130111-967-E-combined';
name2         = '130109-801-wide-1_ch00';

apply_transform_on_image([dir name '.jpg'],[dir name2 '.jpg'],'saveas',[name '_transformed'])




%% Plot

% dir     = '/home/bakkumd/Data_bak/130124-lipofection/images/';
% fn      = [dir 'transformed/130126-712-wide-2_ch00_transformed.jpg'];
% INVERT  = 1;

fn      = [dir 'transformed/' name '_transformed.jpg'];
INVERT  = 1;


    im = imread(fn);
    if length(size(im))==3,  im = rgb2gray(im); end
    im = double(im); 

    % im2=imadjust(im); % doesnt work as well as manual adjust below...

    % Adjust color levels from >>   
    figure; 
    n  = histc(reshape(im,1,size(im,1)*size(im,2)),[1:254]); bar([1:254],n)

    % Set color limits used in data plots:
    im_ll        =    10;  
    im_ul        =    50;
%     im_ll        =    0;  
%     im_ul        =    254;

    % Clip image color boundaries and invert
    im(im<im_ll) = im_ll;
    im(im>im_ul) = im_ul;
    if INVERT
        im=-im+255;
        tmp=im_ll;
        im_ll=255-im_ul;
        im_ul=255-tmp;
    end
    im=im-im_ll;


    % Plot result
    figure
    imagesc(im)
    axis equal
    colormap gray
    caxis([0 im_ul-im_ll])
    title(name)


   
%% Set correction for color scales for overlaid plots (i.e. StimMap / StimScan)
%  Plot here then copy and paste into figures, setting alpha() level


        im_m=max(max(im));

        ll = -40;
        ul =  10;
        
        figure
            imagesc(im-im_m+ll-1)
            axis equal
            axis ij



        
        clr1    =  mkpj(ul-ll+1,'J_DB');              % modified by me to add more red (perceptually balanced colormaps)
        clr0    =  gray(im_m);
        clr     =  [clr0; clr1];
        colormap(clr)
        caxis([-im_m+ll ul])
        %alpha(.5)
        
        figure_fontsize(8,'bold')
        figure_size(8,12)
        axis fill
        hold on

        %%
    
        colorbar('delete')
    
        %set(gca,'xtick',[])
        cb = colorbar('location','southoutside')
        cpos = [.16 .05 .7 .02];
        set(cb,'Position',cpos);
        figure_fontsize(8,'bold')

        set(get(cb,'xlabel'),'String', 'Voltage [uV]','FontSize',8,'FontWeight','bold');
        set(cb,'xtick',[0:clr_scale:ul],'xticklabel',[0:ul/clr_scale]);
        
        set(get(cb,'xlabel'),'String', 'Velocity [m/s]','FontSize',8,'FontWeight','bold');
        set(cb,'xtick',[ll:10:ul],'xticklabel',[ll/clr_scale:.1:ul/clr_scale]);
    
%% Plot electrodes onto image
load global_cmos
hold on
plot(ELC.X,ELC.Y,'b.','markersize',1)



%%
%%  Make montage figure from multiple images for use in overlay plots
%
%
%

    
    
    %  
%     
%     INVERT = 1;
%     LEVELS = 1;
%     ycut = 330;%380; %450;
%     dir = '/home/bakkumd/Data_bak/130107-lipofection/transformed/';
    
    
    INVERT = 0;
    LEVELS = 0;
    dir  = '/home/bakkumd/Data_bak/130107-lipofection/images/reg_pics/';

    if strcmp(Info.Exptitle,'130112-967-D7') || strcmp(Info.Exptitle,'130112-967-D8')
        fn1  = [dir '130112-967-D-post-combined-axonhighlight_transformed.jpg'];
        fn2  = NaN;
        ycut = 750;
%         fn1  = [dir '130112-967-D-2-post_ch00-gimp_transformed.jpg'];
%         fn2  = [dir '130112-967-D-3-post_ch00-gimp_transformed.jpg'];
%         ycut = 350;
    elseif strcmp(Info.Exptitle,'130111-967-D3')
        fn1  = [dir '130111-967-D-2-part2_ch00-gimp_transformed.jpg'];
        fn2  = [dir '130111-967-D-3-part2_ch00-gimp_transformed.jpg'];
        ycut = 330;
    elseif strcmp(Info.Exptitle,'130110-D')
        fn1  = [dir '130110-967-D-combined-axonhighlight_transformed.jpg'];
        fn2  = NaN;
        ycut = 700;
%         fn1  = [dir '130110-967-D-1_ch00-gimp_transformed.jpg'];
%         fn2  = [dir '130110-967-D-2_ch00-gimp_transformed.jpg'];
%         ycut = 330;
    elseif strcmp(Info.Exptitle,'130111-967-E1') || strcmp(Info.Exptitle,'130111-967-E2')  || strcmp(Info.Exptitle,'130111-967-all-ntk') 
        
        dir = '/home/bakkumd/Data_bak/130107-lipofection/images/';
        fn1 = [dir 'transformed/130111-967-E-combined_transformed.jpg'];
        %fn1 = [dir 'transformed/130111-967-E-combined-silhouette_transformed.jpg'];
        fn2 = NaN;
        ycut = 1200;
        
    else
        disp ERROR
        beep
        return
    end
    
        jj = [   1 :  ycut ];
        ii = [   1 : 2099 ];
        im = imread(fn1);
        if length(size(im))==3,  im = rgb2gray(im); end
        im = double(im); 
    imD2 = im(jj,ii);
    
    if ~isnan(fn2)
        jj = [ycut+1 : 2223 ];
        ii = [     1 : 2099 ];
        im = imread(fn2);
        if length(size(im))==3,  im = rgb2gray(im); end
        im = double(im); 
    imD3 = im(jj,ii);

    im   = [imD2 ; imD3];
    else
    im   = imD2;
    end
    
    if INVERT
        
        im(im==255)=0;
%         im(   1:45, :)  = 0;
%         im(701:end, :)  = 0;
%         im(:,  1:1529)  = 0;
%         im(:,2021:end)  = 0;
    else
    end

    

    
    
    % im2=imadjust(im); % doesnt work as well as manual adjust below...
    % adjust color levels from >>   
    %figure; hist(reshape(im,1,size(im,1)*size(im,2)),256);
    figure;  n = histc(reshape(im,1,size(im,1)*size(im,2)),[1:254]); bar([1:254],n)
    
    if LEVELS
        im_ll=10;  im_ul=40;
        % im_ll=20;  im_ul=4500; % MAP2 --
        im(im<im_ll)=im_ll;
        im(im>im_ul)=im_ul;
    else
        im_ll=0; im_ul=255;
    end

    if INVERT
        im=-im+255;
        tmp=im_ll;
        im_ll=255-im_ul;
        im_ul=255-tmp;
    end

    im = im-im_ll;

    figure
    imagesc(im)
    axis equal
    colormap gray
    %colormap(gray(256))
    %caxis([0 im_ul-im_ll])
    caxis([0 im_ul-im_ll])
    [pathstr, name, ext] = fileparts(fn1);  title(name)


    figure_size(8,12)
    axis fill

    hold on


    
%% Plot electrodes onto image
load global_cmos
hold on
plot(ELC.X,ELC.Y,'b.','markersize',1)























