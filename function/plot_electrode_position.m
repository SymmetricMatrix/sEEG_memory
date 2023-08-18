%% plot electrode position
%
fieldtrip_dir =  '/konglab/home/xicwan/toolbox/fieldtrip/';
transparency = 0.2;
fig = figure;
% adding MNI brain plot
load(fullfile(fieldtrip_dir,'template','anatomy','surface_pial_left.mat'),'mesh');
ft_plot_mesh(mesh);
load(fullfile(fieldtrip_dir,'template','anatomy','surface_pial_right.mat'),'mesh');
ft_plot_mesh(mesh);
title('colin27 MNI brain')

view_angle = [0 90];
alpha(transparency)
view(view_angle);
material dull;
lighting gouraud;
camlight;
rotate3d on
hold on


%% load sEEG loction
contacts=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
numCoords=str2coord(contacts.MNI);



%% plot sEEG
e_size = 50;          
cmap = [0,0,0]; 
e = numCoords;
fig = scatter3(e(:,1), e(:,2), e(:,3), ...
'o', 'filled', ...
'SizeData', e_size, ...
'MarkerEdgeColor','k');

fig.CData = cmap;
  