  

% 4:   clear first practice,trigger(1:688172)=0;
% 5:   271
% 13:  174
% 16:  redundance trigger 11, after first practice
% 18:  53 74 

h=272;
id=cfg.trl(h,1)+cfg.trialdef.pre*data_trigger.hdr.Fs +(cfg.trl(h,1)-cfg.trl(h-1,1))
trigger(id)
trigger(id:id+30)=trigger(cfg.trl(h,1)+cfg.trialdef.pre*data_trigger.hdr.Fs)+1;

plot(trigger)
read_dir
load( fullfile(read_dir, 'trigger.mat'))
data_trigger.trial{1}=trigger;
save([read_dir,'/','trigger.mat'],'data_trigger','-v7.3');


% subject 1, cut
data3=data_pre.trial{1}(:,1:6242610);
data4=data_pre.trial{1}(:,6927420:end);

data_pre.label=label;
data_pre.trial{1}=data;
data_pre.sampleinfo(2)=size(data,2);
data_pre.cfg.channel=channels;
data_pre.cfg.refchannel=channels;
data_pre.time{1}=(0:size(data,2)-1)/2048;


%% change label name
channels = table2cell(ele_excl(ele_excl.subi==subi & ele_excl.lab_inside==1, {'label'}));
cfg            = [];
cfg.dataset    = '/bigvault/Projects/seeg_pointing/subject/subject1/seeg_edf/sequence_memory/Lin~ Kaifeng_5ccb2cbc-076f-4409-b188-cf2bcae20975.edf';
cfg.channel    = channels(70:end);
data_pre2 = ft_preprocessing(cfg);
channels = table2cell(ele_excl(ele_excl.subi==subi & ele_excl.lab_inside==1, {'lab_bs'}));


data=data1;
data.label=[data1.label;data2.label];
data.trial{1}=[data1.trial{1};data2.trial{1}];
data.sampleinfo(2)=size(data.trial{1},2);
data.cfg.channel=channels;
data.cfg.refchannel=channels;
data.time{1}=(0:size(data.trial{1},2)-1)/2048;
data.labeledf=data.label;
data.label=table2cell(ele_excl(ele_excl.subi==subi & ele_excl.lab_inside==1, {'lab_bs'}));

%%
data_pre=data;
data_pre.trial{1}=[data.trial{1}(:,1:6242610)];
data_pre.sampleinfo(2)=size(data_pre.trial{1},2);
data_pre.time{1}=(0:size(data_pre.trial{1},2)-1)/2048;

  

% obj
data_pre.trial{1}=[data_pre1.trial{1}(:,6927420:end);data_pre2.trial{1}(:,6927420:end)];
data_pre.sampleinfo(2)=size(data_pre.trial{1},2);
data_pre.cfg.channel=channels;
data_pre.cfg.refchannel=channels;
data_pre.time{1}=(0:size(data_pre.trial{1},2)-1)/2048;
data_pre.labeledf=data_pre.label;
data_pre.label=table2cell(ele_excl(ele_excl.subi==subi & ele_excl.lab_inside==1, {'lab_bs'}));

% seq trigger
data_trigger.trial{1}=data_trigger.trial{1}(:,1:6242610);
data_trigger.sampleinfo(2)=size(data_trigger.trial{1},2);
data_trigger.time{1}=(0:size(data_trigger.trial{1},2)-1)/2048;

% obj trigger
data_trigger.trial{1}=data_trigger.trial{1}(:,6927420:end);
data_trigger.sampleinfo(2)=size(data_trigger.trial{1},2);
data_trigger.time{1}=(0:size(data_trigger.trial{1},2)-1)/2048;

%% genner
trigger_index =[0:6,11:28,51:68];
idx =sort(unique(trigger));
for i=1:length(trigger_index)
    trigger(trigger==idx(i))=trigger_index(i);
end
plot(trigger)
    

%% obj
trigger(trigger==0)=trigger(1);
trigger=abs(trigger);
trigger_index =[0:3,100];
idx =sort(unique(trigger));
for i=1:length(trigger_index)
    trigger(trigger==idx(i))=trigger_index(i);
end
plot(trigger)
data_trigger.trial{1, 1} =trigger;










