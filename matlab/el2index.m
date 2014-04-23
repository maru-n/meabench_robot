function [x y]=el2index(el)
% [x y]=el2index(el)   DB 2011
% return electrode indices for CMOS v2 arrays, using positions from [x,y]=el2position(el)
% (no offset -> el begins at 0)

if nargin<1
    error('Not enough input parameters.')
end

if find(el<0 | el>11015)
    error('Electrode value out of range.')
end
    
%%

	px_start=175;	px_end=1910; px_width=107; %// total columns 108 {from  0 to 107}
	py_start=108;	py_end=2098; py_width=203; %// total rows    205 {from -1 to 203}

    [x_pos y_pos]=el2position(el);
    

x = round( px_width * (x_pos-px_start) / (px_end-px_start) );
y = round( py_width * (y_pos-py_start) / (py_end-py_start) );

