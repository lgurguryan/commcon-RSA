function [] = extract_beta_descrip()
% Extract the "descrip" field from all beta images for each subject and commercial and save as a txt file.

%%%%%%%%%%%%%
%%%% PRE %%%%
%%%%%%%%%%%%%

% Define base directories
base_spm_results_dir = '/Volumes/Chi/Model3_PRE';
commercialNamesFile = '/Volumes/My Passport for Mac/CommCon/SPM_results/Model3_scripts/CommercialNames.txt';

% Read commercial names
fid = fopen(commercialNamesFile, 'r');
commercialNames = textscan(fid, '%s');
fclose(fid);

% List of subject IDs
subjects = [01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34];  
% subjects = [01 02];  

% Prepare output file
output_file = fullfile(base_spm_results_dir, 'AllSubjects_BetaDescriptions_PRE.txt');
fid_out = fopen(output_file, 'w');
fprintf(fid_out, 'Subject\tCommercial\tBetaFile\tDescription\n');  

% Loop through subjects
for subj = subjects
    subjID = sprintf('%02d', subj);
    disp(['Processing subject: ' subjID]);

    % Loop through commercials
    for i = 1:length(commercialNames{1})
        commercialName = commercialNames{1}{i};
        resultDir = fullfile(base_spm_results_dir, ['Model3_sub-' subjID], commercialName);

        % Find all beta files in this commercial folder
        beta_files = dir(fullfile(resultDir, 'beta_*.nii'));

        if isempty(beta_files)
            disp(['  No beta files found for ' commercialName]);
            continue;
        end

        % Loop through each beta file
        for ibeta = 1:length(beta_files)
            beta_path = fullfile(resultDir, beta_files(ibeta).name);
            try
                V = spm_vol(beta_path);
                descrip = strtrim(V.descrip);
            catch ME
                descrip = ['ERROR reading file: ' ME.message];
            end

            % Write to text file
            fprintf(fid_out, '%s\t%s\t%s\t%s\n', subjID, commercialName, beta_files(ibeta).name, descrip);
        end
    end
end

fclose(fid_out);
disp(['Saved to: ' output_file]);

end


%%%%%%%%%%%%%%
%%%% POST %%%%
%%%%%%%%%%%%%%

% Define base directories
base_spm_results_dir = '/Volumes/My Passport for Mac/CommCon/SPM_results/Model3_POST';
commercialNamesFile = '/Volumes/My Passport for Mac/CommCon/SPM_results/Model3_scripts/CommercialNames.txt';

% Read commercial names
fid = fopen(commercialNamesFile, 'r');
commercialNames = textscan(fid, '%s');
fclose(fid);

% List of subject IDs
subjects = [01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34];  
% subjects = [01 02];  

% Prepare output file
output_file = fullfile(base_spm_results_dir, 'AllSubjects_BetaDescriptions_POST.txt');
fid_out = fopen(output_file, 'w');
fprintf(fid_out, 'Subject\tCommercial\tBetaFile\tDescription\n');  

% Loop through subjects
for subj = subjects
    subjID = sprintf('%02d', subj);
    disp(['Processing subject: ' subjID]);
    
    % Loop through commercials
    for i = 1:length(commercialNames{1})
        commercialName = commercialNames{1}{i};
        resultDir = fullfile(base_spm_results_dir, ['Model3_sub-' subjID], commercialName);
        
        % Find all beta files in this commercial folder
        beta_files = dir(fullfile(resultDir, 'beta_*.nii'));
        
        if isempty(beta_files)
            disp(['  No beta files found for ' commercialName]);
            continue;
        end
        
        % Loop through each beta file
        for ibeta = 1:length(beta_files)
            beta_path = fullfile(resultDir, beta_files(ibeta).name);
            try
                V = spm_vol(beta_path);
                descrip = strtrim(V.descrip);
            catch ME
                descrip = ['ERROR reading file: ' ME.message];
            end
            
            % Write to text file
            fprintf(fid_out, '%s\t%s\t%s\t%s\n', subjID, commercialName, beta_files(ibeta).name, descrip);
        end
    end
end

fclose(fid_out);
disp(['Saved to: ' output_file]);

end