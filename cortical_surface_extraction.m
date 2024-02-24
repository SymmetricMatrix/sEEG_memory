% fshome: path to freesurfer home directory
% subdir: path to subject directory
% mrfile: path to subject MR_acpc.nii

sub_id=27;
num_sub = length(sub_id);
for i=1:num_sub
    subject = ['subject',num2str(sub_id(i))];
    fshome = '/konglab/apps/freesurfer/';
    subdir = ['/bigvault/Projects/seeg_pointing/subject/',subject,'/freesurfer'];
    find_file = dir([['/bigvault/Projects/seeg_pointing/subject/',subject,'/CT_MRI/MRI/'],'*.nii']);
    mrfile = fullfile(find_file.folder,find_file.name);
    system(['export FREESURFER_HOME=' fshome '; ' ...
        'source $FREESURFER_HOME/SetUpFreeSurfer.sh; '...
        'mri_convert -c -oc 0 0 0 ' mrfile ' ' [subdir '/tmp.nii'] '; ' ...
        'recon-all -i ' [subdir '/tmp.nii'] ' -s ' 'freesurfer' ' -sd ' subdir ' -all'])
end

