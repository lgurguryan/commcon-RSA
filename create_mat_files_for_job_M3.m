clear all

%%%----Things you will want to change for your study----%%%

rootDir = '/Users/yorkie/Documents/CommCon/data/raw_behavioral/Model3/';
commercialFolders = dir(fullfile(rootDir, '*')); 
commercialFolders = commercialFolders([commercialFolders.isdir] & ~ismember({commercialFolders.name}, {'.', '..'})); 
preTimingSuffix = '_TimingFile_M3_PRE.txt';   
postTimingSuffix = '_TimingFile_M3_POST.txt';

% Loop through all commercial folders for PRE files
for folderIdx = 1:length(commercialFolders)
    
    % Get the path of the current commercial folder
    commercialFolderPath = fullfile(rootDir, commercialFolders(folderIdx).name);
    
    % Get the list of PRE timing files in the current commercial folder
    timingFiles = dir(fullfile(commercialFolderPath, ['*' preTimingSuffix])); 
    
    % Extract the commercial name from the folder name
    commercialName = commercialFolders(folderIdx).name;
    
    % Loop through all PRE timing files in the current commercial folder
    for fileIdx = 1:length(timingFiles)
        
        % Get the subject-specific timing file
        timingFilePath = fullfile(commercialFolderPath, timingFiles(fileIdx).name);
        
        % Read the timing file (Run, ConditionName, Onset, Duration)
        fid = fopen(timingFilePath, 'rt');
        T = textscan(fid, '%f %s %f %f', 'HeaderLines', 1); 
        fclose(fid);
        
        % Get subject ID from the timing file name 
        [~, fileName, ~] = fileparts(timingFiles(fileIdx).name);
        subjectID = fileName(1:6); 
        
        % Create the .mat file for the current subject and commercial folder
        runs = unique(T{1});
        nameList = T{2};  
        names = unique(nameList, 'stable');  % Stable keeps the order in txt that was exptracted
        names = names';  % Transpose 

        onsets = cell(1, length(names));
        durations = cell(1, length(names));
        
        % Process each condition in the timing file
        for nameIdx = 1:length(names)
            for idx = 1:length(T{3})
                if isequal(T{2}{idx}, names{nameIdx}) && T{1}(idx) == runs
                    onsets{nameIdx} = double([onsets{nameIdx} T{3}(idx)]);
                    durations{nameIdx} = double([durations{nameIdx} T{4}(idx)]);
                end
            end
        end
        
        % Save the .mat file for PRE timing files
        matFileName = fullfile(commercialFolderPath, [subjectID '_' commercialName '_TimingFile_M3_PRE.mat']);
        save(matFileName, 'names', 'onsets', 'durations', 'commercialName');
        
        % Print
        disp(['Saved .mat file for subject ' subjectID ' in commercial ' commercialFolders(folderIdx).name ' (PRE)']);
        
    end
end

% Loop through all commercial folders for POST files
for folderIdx = 1:length(commercialFolders)
    
    % Get the path of the current commercial folder
    commercialFolderPath = fullfile(rootDir, commercialFolders(folderIdx).name);
    
    % Get the list of POST timing files in the current commercial folder
    timingFiles = dir(fullfile(commercialFolderPath, ['*' postTimingSuffix])); 
    
    % Extract the commercial name from the folder name
    commercialName = commercialFolders(folderIdx).name;
    
    % Loop through all POST timing files in the current commercial folder
    for fileIdx = 1:length(timingFiles)
        
        % Get the subject-specific timing file
        timingFilePath = fullfile(commercialFolderPath, timingFiles(fileIdx).name);
        
        % Read the timing file (Run, ConditionName, Onset, Duration)
        fid = fopen(timingFilePath, 'rt');
        T = textscan(fid, '%f %s %f %f', 'HeaderLines', 1); 
        fclose(fid);
        
        % Get subject ID from the timing file name 
        [~, fileName, ~] = fileparts(timingFiles(fileIdx).name);
        subjectID = fileName(1:6); 
        
        % Create the .mat file for the current subject and commercial folder
        runs = unique(T{1});
        nameList = T{2};  
        names = unique(nameList, 'stable');  % Stable keeps the order in txt that was exptracted
        names = names';  % Transpose 

        onsets = cell(1, length(names));
        durations = cell(1, length(names));
        
        % Process each condition in the timing file
        for nameIdx = 1:length(names)
            for idx = 1:length(T{3})
                if isequal(T{2}{idx}, names{nameIdx}) && T{1}(idx) == runs
                    onsets{nameIdx} = double([onsets{nameIdx} T{3}(idx)]);
                    durations{nameIdx} = double([durations{nameIdx} T{4}(idx)]);
                end
            end
        end
        
        % Save the .mat file for POST timing files
        matFileName = fullfile(commercialFolderPath, [subjectID '_' commercialName '_TimingFile_M3_POST.mat']);
        save(matFileName, 'names', 'onsets', 'durations', 'commercialName');
        
        % Print
        disp(['Saved .mat file for subject ' subjectID ' in commercial ' commercialFolders(folderIdx).name ' (POST)']);
        
    end
end
