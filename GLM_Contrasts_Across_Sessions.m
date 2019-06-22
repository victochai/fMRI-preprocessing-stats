%% GLM / first level analysis

% 9 categories
% 5 subjetcs
% 6 runs each
% subjects num. 4 --> fell asleep last 2 sessions

% each run --> 2 BLOCKS
% each BLOCK --> presented 9 categories
% each category had 8 stimuli (so, 8 words)
% so, each category is a run was presented 16 times

% categories:
% 1. body
% 2. tools
% 3. ---
% 4. materials
% 5. flour
% 6. mammals
% 7. birds
% 8. food
% 9. ---

%% specify firectories // subs

clc, clear
main_dir = 'D:\elisa experiment\fMRI data\DATA';
cd(main_dir);
subs = dir('subj*');
subs = {subs.name}';

First_Level_Analysis_job;

spm('defaults', 'FMRI'); % initialise SPM
spm_jobman('initcfg');

%% GLM / acquire betas

for i = 1:length(subs)
    
    matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = cellstr(fullfile(main_dir, subs{i}));
    
    sessions = dir(fullfile(main_dir, subs{i}, 'func', 'sess_*'));
    sessions = {sessions.name}';
    
    mult_cond = dir(fullfile(main_dir, subs{i}, 'mult conditions', 'MC*'));
    mult_cond = {mult_cond.name}';

    for k = 1:length(sessions)
        
        nii_func = spm_select('ExtFPList', fullfile(main_dir, subs{i}, 'func', sessions{k}), '^swuf.*\.nii$', 1);
        matlabbatch{2}.spm.stats.fmri_spec.sess(k).scans = cellstr(nii_func);
        matlabbatch{2}.spm.stats.fmri_spec.sess(k).multi = cellstr(fullfile(main_dir, subs{i}, 'mult conditions', mult_cond{k}));
        
    end
    
    spm_jobman('run', matlabbatch);
    fprintf('%1$s %2$s\n', 'Done stats of', subs{i});
    
end

%% defining contrasts / body-tools / baseline-all / across sessions per each subj

clc, clear
main_dir = 'D:\elisa experiment\fMRI data\DATA';
cd(main_dir);
subs = dir('subj*');
subs = {subs.name}';

contrasts = {'body-tools', 'baseline-all'}

spm('defaults', 'FMRI'); % initialise SPM
spm_jobman('initcfg');

for i = 1:length(subs)
    
    matlabbatch{1}.spm.stats.con.spmmat = cellstr(fullfile(main_dir, subs{i}, 'output', 'SPM.mat'));
    
    % body-tools
    
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = contrasts{1};  % it should be a string
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';  % replicate over sessions
     
    % baseline-all
    
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = contrasts{2};  % it should be a string
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [-1 -1 -1 -1 -1 -1 -1 -1 -1];
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';  % replicate over sessions
    
    matlabbatch{1}.spm.stats.con.delete = 0;
    
    spm_jobman('run', matlabbatch);
    
    fprintf('%1$s %2$s\n', 'Done contrasts of', subs{i});

end
