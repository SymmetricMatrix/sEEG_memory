for subi= 2%1:18
    try
        subject = strcat('subject', num2str(subi));
        load(['/bigvault/Projects/seeg_pointing/results/object_recognition/',subject,'/trigger_new.mat'])
        
        
        % get read_dir
        sub_dir= dir(fullfile([home_dir,subject,'/seeg_edf/',proj],'*.edf'));
        read_dir=[sub_dir.folder,'/',sub_dir.name];
        
        % read trigger channel
        cfg = [];
        cfg.dataset = read_dir;
        cfg.channel = 'TRIG';
        data_trigger = ft_preprocessing(cfg);
        trigger=cell2mat(data_trigger.trial);
        save([save_dir,subject,'/trigger.mat'],'data_trigger','-v7.3');
        save([save_dir,subject,'/','trigger_old.mat'],'trigger','-v7.3');
    catch ME
        % display the error message
        disp([num2str(subi),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end



for i=2%1:18
    try
        disp(['subject',num2str(i)])
        load(['/bigvault/Projects/seeg_pointing/results/sequence_memory/subject',num2str(i),'/trigger_old.mat'])
        
        if i==9
            trigger(1:229839)= trigger(2161290);
        elseif i==10
            trigger(1:945565)= trigger(3038980);
        elseif i==12
            trigger(1:1350130)= trigger(1350130);
            trigger(6360220:end)= trigger(1350130);
        elseif i==11
            trigger(1:585600)= trigger(1718060);
        elseif i==15
            trigger(1:56452) = 0;
        elseif i==17
            trigger(1:24326) = trigger(233361);
            trigger(1370000:end) = trigger(233361);
            trigger= abs(trigger-trigger(75106));
            trigger = trigger-trigger(1);
            trigger(trigger<0 )=0;
            trigger = abs(trigger);
            
            
            trigger(trigger>8000 )=200;
            trigger(trigger>1700 )=100;
            trigger(trigger==trigger(861446))=6;
            trigger(trigger==trigger(767780))=1;
            trigger(trigger==trigger(762744))=2;
            trigger(trigger==trigger(509374))=3;
            trigger(trigger==trigger(430367))=4;
            trigger(trigger==trigger(425960))=5;
            idx=find(trigger(530001:800000)>200);
            trigger(idx+530000)=200;
            idx=find(trigger(1170001:end)>200);
            trigger(idx+1170000)=200;
            trigger(trigger>300)=100;
            trigger(1145843)=200;
            trigger(trigger==100)=20;
            trigger(trigger==200)=60;
            
        end
        
        trigger = trigger-trigger(1);
        trigger = abs(trigger);
        trigger(trigger>30000  )=0;
        
        for id=1:size(seq_trigger,1)
            trigger(trigger==seq_trigger(id,1))=seq_trigger(id,2);
        end
        
        if size(tabulate(trigger),1)~=43
            disp([num2str(size(tabulate(trigger),1)),'/43'])
            tabulate(trigger)
        end
        % plot(trigger)
        save(['/bigvault/Projects/seeg_pointing/results/sequence_memory/subject',num2str(i),'/trigger_new.mat'],'trigger','-v7.3');
        
    catch ME
        % display the error message
        disp([num2str(i),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end






tabulate(trigger)
trigger = trigger-trigger(1);
trigger = abs(trigger);
plot(trigger)
trigger(trigger>30000  )=0;

idx_old=sort(tabulate(trigger));
idxs = [0,1:5,10,11:28,51:68];
for i=1:length(idxs)
    trigger(trigger==idx_old(i))=idxs(i);
end
tabulate(trigger)
plot(trigger)


%%
data_pre.trial{1}=[data_pre1.trial{1};data_pre2.trial{1}];
data_pre.label=[data_pre1.label;data_pre2.label];
data_pre.cfg.channel=data.cfg.channel;
data_pre.cfg.previous.channel=data.cfg.channel;

%% sequence
trigger=trigger-trigger(1);
trigger = abs(trigger);

right = [0:6,11:28,51:68];
trigger_idx = tabulate(trigger);
trigger_idx = sort(trigger_idx(:,1));
if length(trigger_idx)==length(right)
    for i =1:length(right)
        trigger(trigger==trigger_idx(i))=right(i);
        
    end
end

plot(trigger)

data_trigger.trial{1, 1} =trigger;



