function plot_brain_electrode(contacts, transparency, view_angle, CData)
% plot colin27 MNI brain and electrode position
% Input: 
%     contacts:       contacts tables in '/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv'
%     location_name:  brain location_name in contacts
%     transparency:   transparency in brain plot
%     view_angle:     view_angle of brain
%     CData:          electrode CData 
% Outplot:
%     plot 

fieldtrip_dir =  '/konglab/home/xicwan/toolbox/fieldtrip/';
% Load left and right pial surface meshes
load(fullfile(fieldtrip_dir,'template','anatomy','surface_pial_left.mat'),'mesh');
ft_plot_mesh(mesh);
load(fullfile(fieldtrip_dir,'template','anatomy','surface_pial_right.mat'),'mesh');
ft_plot_mesh(mesh);

% Set transparency and view angle
alpha(transparency)
view(view_angle);
material dull;
lighting gouraud;
camlight;
rotate3d on
hold on

% electrode info
numCoords = str2coord(contacts.MNI);

% plot sEEG
e_size = 7;
e = numCoords;

% Plot sEEG locations as scatter points with colors based on sub_id
fig = scatter3(e(:,1), e(:,2), e(:,3), ...
    'o', 'filled', ...
    'SizeData', e_size, ...
    'CData',CData);%'MarkerEdgeColor','k'

%title(['colin27 MNI brain: ',strrep(location_name, '_', ' ')])
end


