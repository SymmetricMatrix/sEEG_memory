%% setting parameter
location_name = 'Temporal_Sup L';

%% plot brain
%
fieldtrip_dir =  '/konglab/home/xicwan/toolbox/fieldtrip/';
transparency = 0.1;

figure;
fig = subplot(2,2,1);
% adding MNI brain plot
load(fullfile(fieldtrip_dir,'template','anatomy','surface_pial_left.mat'),'mesh');
ft_plot_mesh(mesh);
load(fullfile(fieldtrip_dir,'template','anatomy','surface_pial_right.mat'),'mesh');
ft_plot_mesh(mesh);
title('colin27 MNI brain')

alpha(transparency)
view(view_angle);
material dull;
lighting gouraud;
camlight;
rotate3d on
hold on
%% load sEEG loction
contacts = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
contacts = contacts(strcmp(contacts.AAL3,location_name),:);
numCoords = str2coord(contacts.MNI);

% plot sEEG
e_size = 50;
e = numCoords;

% determine color based on sub_id
CData=[];
sub_ids = unique(contacts.sub_id);
colors = jet(length(sub_ids));
for i = 1:length(sub_ids)
    color_idx = find(contacts.sub_id==sub_ids(i));
    CData(color_idx,:) = repmat(colors(i,:),length(color_idx),1);
end

% plot scatter
fig = scatter3(e(:,1), e(:,2), e(:,3), ...
    'o', 'filled', ...
    'SizeData', e_size, ...
    'MarkerEdgeColor','k','CData',CData);

% set colorbar
legend_labels = cellstr(strcat('subject', string(sub_ids)'));
colormap(colors)
c =colorbar;
c.Ticks = linspace(0,1,length(sub_ids));
c.TickLabels = legend_labels;
title(['colin27 MNI brain: ',strrep(location_name, '_', ' ')])

