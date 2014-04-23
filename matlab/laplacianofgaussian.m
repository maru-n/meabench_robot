function img=laplacianofgaussian(V,spacing)
% img = laplacianofgaussian(V,spacing) is used to approximate the Current Source Density
% from the interpolated voltages in V (which must be a 2d-matrix) with 
% each value spaced by 'spacing' in micrometers. A spacing of 5um
% was used in the thesis.

%% Laplacian of Gaussian (LoG) -- used as approximation for Current Source Density analysis
%  equation from: Urs thesis chapter 4
%  see also  http://fourier.eng.hmc.edu/e161/lectures/gradient/node10.html
%
%  In thesis, CSD done to find sinks (neg values) and sources (pos values)
%  of transmembrane current. CSD consists of a second order spatial 
%  derivative and was approximated using the LoG applied to the
%  "interpolated (grid of 5 um) potentials".

% LoG(x,y) = (x^2 + y^2 - 2*w^2)/w^4 * exp( -1*(x^2+y^2)/(2*w^2) );
%       w == 1.5*(electrode_spacing)
%       electrode spacing ~17um center to center

if nargin<2
    error('Not enough input parameters.')
end


%w=17*1.5/spacing; % higher w -> wider filter
% why this w?
w=1;

clear LoG
r=ceil(w*6);
for x=-r:r
for y=-r:r
    %LoG(x+r+1,y+r+1)=(x^2 + y^2 - 2*w^2)/w^4 * exp( -1*(x^2+y^2)/(2*w^2) );
    G(x+r+1,y+r+1)   = exp( -1*(x^2+y^2)/(2*w^2) ); 
    LoG(x+r+1,y+r+1) = (x^2 + y^2 - 2*w^2)/(2*pi*w^6) * G(x+r+1,y+r+1);
end
end
LoG=LoG/(sum(sum(G)));
img=filter2(LoG,V);