%% setting parameter
location_name = 'Temporal_Mid L';%'Rolandic_Oper L';
transparency = 0.1;
sub_ids = [3,4,6,7,8,9,12:17,19:26];

% load  contacts
contacts = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
contacts = contacts(ismember(contacts.sub_id,sub_ids) & contains(contacts.AAL3,location_name),:);


CData=[];
sub_ids = unique(contacts.sub_id);
colors = jet(length(sub_ids));
for i = 1:length(sub_ids)
    color_idx = find(contacts.sub_id==sub_ids(i));
    CData(color_idx,:) = repmat(colors(i,:),length(color_idx),1);
end

figure
%subplot(2, 2, 1);
view_angle = [270, 0];
plot_brain_electrode(contacts, transparency, view_angle,CData)
% subplot(2, 2, 2);
% view_angle = [0, 0]; 
% plot_brain_electrode(contacts, transparency, view_angle,CData)
% subplot(2, 2, 3);
% view_angle = [0, 90]; 
% plot_brain_electrode(contacts, transparency, view_angle,CData)

% set colorbar
legend_labels = cellstr(strcat('subject', string(sub_ids)'));
colormap(colors)
c = colorbar('Position', [0.92 0.1 0.02 0.8]);
c.Ticks = linspace(0,1,length(sub_ids));
c.TickLabels = legend_labels;
sgtitle(['colin27 MNI brain: ',strrep(location_name, '_', ' ')])

% Set the figure position to the screen size
set(gcf, 'Position', get(0, 'ScreenSize'));
% Maximize the figure window
set(gcf, 'WindowState', 'maximized');