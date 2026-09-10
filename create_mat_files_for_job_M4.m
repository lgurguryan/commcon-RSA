clear all

%%%----Things you will want to change for your study----%%%

rootDir = '/Users/yorkie/Documents/CommCon/data/raw_behavioral/Model4/';

preTimingSuffix = '_TimingFile_M4_PRE.txt';


% Get all PRE timing files
timingFiles = dir(fullfile(rootDir, ['*' preTimingSuffix]));


% Loop through all participant PRE timing files
for fileIdx = 1:length(timingFiles)
    
    % Get the subject-specific timing file
    timingFilePath = fullfile(rootDir, timingFiles(fileIdx).name);
    
    % Read the timing file
    % Columns:
    % Run | regressor_name | onset | duration
    fid = fopen(timingFilePath, 'rt');
    T = textscan(fid, '%f %s %f %f', 'HeaderLines', 1);
    fclose(fid);
    
    
    % Get subject ID from the timing file name
    %
    % Example:
    % sub_001_TimingFile_M4_PRE.txt
    %
    % gives:
    % sub_001
    
    [~, fileName, ~] = fileparts(timingFiles(fileIdx).name);
    
    subjectID = regexp(fileName, '^sub_\d+', 'match', 'once');
    
    
    % Get unique runs
    runs = unique(T{1});
    
    
    % Get condition names
    %
    % Expected:
    % seg-0
    % seg-1
    % seg-2
    
    nameList = T{2};
    names = unique(nameList, 'stable');
    names = names';
    
    
    % Create empty cells for onsets and durations
    onsets = cell(1, length(names));
    durations = cell(1, length(names));
    
    
    % Process each condition
    for nameIdx = 1:length(names)
        
        for idx = 1:length(T{3})
            
            if isequal(T{2}{idx}, names{nameIdx}) && ...
                    T{1}(idx) == runs(1)
                
                onsets{nameIdx} = double([ ...
                    onsets{nameIdx} T{3}(idx) ...
                    ]);
                
                durations{nameIdx} = double([ ...
                    durations{nameIdx} T{4}(idx) ...
                    ]);
                
            end
            
        end
        
    end
    
    
    % Save the .mat file
    %
    % Example:
    % sub_001_TimingFile_M4_PRE.mat
    
    matFileName = fullfile(rootDir, ...
        [subjectID '_TimingFile_M4_PRE.mat']);
    
    save(matFileName, ...
        'names', ...
        'onsets', ...
        'durations');
    
    
    % Print
    disp(['Saved .mat file for subject ' subjectID ' (M4 PRE)']);
    
end
