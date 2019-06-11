%% fMRI prepsocessing

% important:

% 1.) save all important jobs in a main folder
% 2.) each subj in separate folder
% 3.) anat and func data in separate folders
% 4.) each session in func folder in separate folders
% 5.) every part of the code is created as if we execute them separately

%% DICOM to NIFTI

clc, clear
main_dir = 'D:\elisa experiment\fMRI data\DATA';
cd(main_dir);
subs = dir('subj*');
subs = {subs.name}';

spm('defaults','fmri');
spm_jobman('initcfg');

matlabbatch{1}.spm.util.import.dicom.root = 'flat';
matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;

for i = 1:length(subs)
    
    % anatomical images 
    
    dicom_anat = spm_select('FPList', fullfile(main_dir, subs{i}, 'anat'), '.*\.DCM$');
    matlabbatch{1}.spm.util.import.dicom.data = cellstr(dicom_anat);
    matlabbatch{1}.spm.util.import.dicom.outdir = cellstr(fullfile(main_dir, subs{i}, 'anat'));
    spm_jobman('run', matlabbatch);
    
    % functional images
    
    sessions = dir(fullfile(main_dir, subs{i}, 'func', 'sess*'));
    sessions = {sessions.name}';
    
    for k = 1:length(sessions)
        
        dicom_func = spm_select('FPList', fullfile(main_dir, subs{i}, 'func', sessions{k}), '.*\.DCM$');
        matlabbatch{1}.spm.util.import.dicom.data = cellstr(dicom_func);
        matlabbatch{1}.spm.util.import.dicom.outdir = cellstr(fullfile(main_dir, subs{i}, 'func', sessions{k}));
        spm_jobman('run', matlabbatch);
        
    end
    
    fprintf('%1$s %2$s\n', 'Done DICOM to NIFTI conversion of', subs{i})
    
end

%% anatomical segmentation + normalization of T1s (using CAT12)

clc, clear
main_dir = 'D:\elisa experiment\fMRI data\DATA';
cd(main_dir);
subs = dir('subj*');
subs = {subs.name}';

% creating a matlabbatch structure for CAT12

matlabbatch{1}.spm.tools.cat.estwrite.nproc = 1;
matlabbatch{1}.spm.tools.cat.estwrite.opts.tpm = {'D:\hands on methods course\Packages\spm12\tpm\TPM.nii'};
matlabbatch{1}.spm.tools.cat.estwrite.opts.affreg = 'mni';
matlabbatch{1}.spm.tools.cat.estwrite.extopts.APP = 1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.LASstr = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.gcutstr = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.cleanupstr = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.darteltpm = {'D:\hands on methods course\Packages\spm12\toolbox\cat12\templates_1.50mm\Template_1_IXI555_MNI152.nii'};
matlabbatch{1}.spm.tools.cat.estwrite.extopts.vox = 1.5;
matlabbatch{1}.spm.tools.cat.estwrite.output.surface = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.native = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.mod = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.dartel = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.native = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.mod = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.dartel = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.bias.warped = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.jacobian.warped = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.warps = [1 0];

spm('defaults','fmri');
spm_jobman('initcfg');

% loop across subjects

for i = 1:length(subs)
    
    nii_anat = spm_select('ExtFPList', fullfile(main_dir, subs{i}, 'anat'), '.*\.nii$', 1);
    matlabbatch{1}.spm.tools.cat.estwrite.data = cellstr(nii_anat);
    spm_jobman('run', matlabbatch);
    fprintf('%1$s %2$s\n', 'Done T1 segmentation and normalization of', subs{i})
    
end

%% preprocessing 

clc, clear
main_dir = 'D:\elisa experiment\fMRI data\DATA';
cd(main_dir);
subs = dir('subj*');
subs = {subs.name}';

spm('defaults','fmri');
spm_jobman('initcfg');

% use the job. file that was created with SPM GUI
% save that job. file in main folder

PREPROCESSING_job;

for i = 1:length(subs)
    
     sessions = dir(fullfile(main_dir, subs{i}, 'func', 'sess*'));
     sessions = {sessions.name}';
     
     % deformation field 
     
     def_field = spm_select('FPList', fullfile(main_dir, subs{i}, 'anat', 'mri'), '^y_.*\.nii$');
     matlabbatch{2}.spm.spatial.normalise.write.subj.def = cellstr(def_field);
     
     for k = 1:length(sessions)
         
            % choosing EPI files
            
            nii_func = spm_select('ExtFPList', fullfile(main_dir, subs{i}, 'func', sessions{k}), '.*\.nii$', 1);
            matlabbatch{1}.spm.spatial.realignunwarp.data.scans = cellstr(nii_func);
            spm_jobman('run', matlabbatch);
            
     end
    
    fprintf('%1$s %2$s\n', 'Done preprocessing of', subs{i});

end
