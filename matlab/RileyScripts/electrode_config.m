%[fname elidx]= electrode_config(electrode,st_electrode,neuroposfile)
%script to generate a routing based on selected stimulation and recording
%electrodes
%inputs:
%electrode- list of recording electrodes
%st_electrode- list of stimulation electrodes
%neuroposfile- file name of the .nrk file to generate
%elidx- electrodes successfully routed
%fname- filename of the generated el2fi.nrk2 file

function [fname elidx]= electrode_config(electrode,st_electrode,neuroposfile)
     % neuroposfile=[Info.Path '/configs/myscan.neuropos.nrk'];

% % if too many, choose largest spikes
%   [a b]= sort(height(elc_with_neuron+1));
%   elc_with_neuron = elc_with_neuron(b(1:130));

%neuroposfile=['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/17.Jun.2013/proc/Chip1393/test_configs/' Info.Exptitle '.neuropos.nrk']
fid = fopen(neuroposfile, 'wt');
elc_with_neuron = electrode;
elc_to_stimulate =st_electrode;
% normal electrodes without stimulation request
for i=1:length(elc_with_neuron)
    e=elc_with_neuron(i);
    [x y]=el2position(e);
    x = round(x);
    y = round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10\n',i,x,y);
end

% stimulation electrodes
for i=1:length(elc_to_stimulate)
    e=elc_to_stimulate(i);
    [x y]=el2position(e);
    x = round(x);
    y = round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10, stim\n',i,x,y);
end
fclose(fid);

ndr_exe='`which NeuroDishRouter`';

[pathstr, name, ext] = fileparts(neuroposfile);
[tmp, name]          = fileparts(name);
fnames            = [pathstr '/' name];
neurs_to_take     = elc_with_neuron;

cmd=sprintf('%s -n -v 2 -l %s -s %s\n', ndr_exe, neuroposfile, [pathstr '/' name])
system(cmd);

% reload & visualize configuration


    fname=[fnames '.el2fi.nrk2']
    fid=fopen(fname);
    elidx=[];
    tline = fgetl(fid);
    while ischar(tline)
        [tokens] = regexp(tline, 'el\((\d+)\)', 'tokens');
        elidx(end+1)=str2double(tokens{1});
        tline = fgetl(fid);
    end
    fclose(fid);

    elidx = elidx+1;

