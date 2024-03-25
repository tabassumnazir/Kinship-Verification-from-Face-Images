% bsif_functions.m
function bsif_features = extract_bsif_features(folderPath)
    % Function to extract BSIF features from images
    % Load the pre-learned filters
    filename = '/Users/tabu/Documents/MATLAB/texturefilters/ICAtextureFilters_3x3_8bit.mat';
    load(filename, 'ICAtextureFilters');

    % Get a list of all image files in the folder
    imageFiles = dir(fullfile(folderPath, '*.jpg'));

    % Initialize cell array to store BSIF features
    bsif_features = cell(length(imageFiles), 1);

    % Iterate over each image in the folder
    for i = 1:length(imageFiles)
        % Read the image
        imagePath = fullfile(folderPath, imageFiles(i).name);
        img = double(rgb2hsv(imread(imagePath)));

        % Call the bsif function to extract BSIF features
        bsif_features{i} = bsif(img, ICAtextureFilters, 'nh'); % Extract unnormalized BSIF code word histogram
    end
end

