figure
subplot(211)
for lag = 1:20
    [same, idx] = cell2matrix(rsa_group.obj.same);
    plot_ci(squeeze(mean(same,2))','r',0.05)
    diff = cell2matrix(rsa_group.obj.diff(:,lag));
    plot_ci(squeeze(mean(diff,2))','b',0.05)
    diff_all(:,:,i) = squeeze(mean(diff,2));
end
xticks(0:10:200);
xticklabels([-50:10:150]/100);
xlabel('Sequence pic /s')
title([subject,': RSA same-diff(Object)'])

yline(0,'--')
xline(50,'--')
xline(165,'--')
ylabel('Fisher Z')

subplot(212)
data1 = squeeze(mean(same,2))';
data2 = squeeze(mean(diff_all,3))';
plot_ci_sig(data1, data2)
xticks(0:10:200);
xticklabels([-50:10:150]/100);
xlabel('Sequence pic /s')
title([subject,': RSA mean same-diff(Object)'])

yline(0,'--')
xline(50,'--')
xline(165,'--')
ylabel('Fisher Z')
legend('Same','','Diff','','p<0.05')










figure
subplot(211)
% plot flatten same - diff
plot_ci(data1-data2, deep_blue, 0.09)
xticks(0:10:200);
xticklabels([-50:10:150]/100);
xlabel('Sequence pic /s')
title([subject,': RSA same-diff(Object)'])
yline(0,'--')
xline(50,'--')
xline(165,'--')
ylabel('Fisher Z')