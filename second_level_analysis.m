%% second level analysis

%% set directories

clc, clear
main_dir = 'D:\elisa experiment\fMRI data\DATA';
cd(main_dir);
subs = dir('subj*');
subs = {subs.name}';

spm('defaults', 'FMRI'); % initialise SPM
spm_jobman('initcfg');

%% main script (unchanged)

matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% body / tools

matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(fullfile(main_dir, 'body_tools'));
nii_con = {}

for i = 1:length(subs)
    
    nii_con{i, 1} = spm_select('ExtFPList', fullfile(main_dir, subs{i}, 'output'), '^con_0001.*\.nii$', 1);
    
end

matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(nii_con);
spm_jobman('run', matlabbatch);

%% baseline / all

matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(fullfile(main_dir, 'baseline-all'));
nii_con = {}

for i = 1:length(subs)
    
    nii_con{i, 1} = spm_select('ExtFPList', fullfile(main_dir, subs{i}, 'output'), '^con_0002.*\.nii$', 1);
    
end

matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(nii_con);
spm_jobman('run', matlabbatch);
