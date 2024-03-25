% Define folder containing metadata files
metadata_folder = '/Users/tabu/Documents/MATLAB/KinFaceW-II/meta_data';

% List of relation types
relation_types = {'ms', 'md', 'fs', 'fd'};

% Initialize arrays to store true positive rate (TPR) and false positive rate (FPR)
TPR_all = cell(1, numel(relation_types));
FPR_all = cell(1, numel(relation_types));

% Iterate over each relation type
for rel_type_idx = 1:numel(relation_types)
    % Load metadata file
    metadata_file = fullfile(metadata_folder, [relation_types{rel_type_idx} '_pairs.mat']);
    metadata = load(metadata_file);

    % Extract pairs and labels
    pairs = metadata.pairs;
    labels = cell2mat(pairs(:, 2));

    % Extract BSIF features for image pairs
    bsif_features1 = extract_bsif_features(fullfile('/Users/tabu/Documents/MATLAB/KinFaceW-II/images/', relation_types{rel_type_idx}));
    bsif_features2 = extract_bsif_features(fullfile('/Users/tabu/Documents/MATLAB/KinFaceW-II/images/', relation_types{rel_type_idx}));

    % Combine BSIF features for each image pair
    trainingData = cell(length(bsif_features1), 1);
    for i = 1:length(bsif_features1)
        trainingData{i} = cat(2, bsif_features1{i}, bsif_features2{i});
    end

    % Convert to array and reshape
    trainingData = cat(4, trainingData{:});
    trainingLabels = categorical(labels);

    % Define deep learning model
    layers = [
        imageInputLayer([size(trainingData,1), size(trainingData,2), size(trainingData,3)]) % Input layer size
        fullyConnectedLayer(128) % Fully connected layer
        reluLayer
        fullyConnectedLayer(2) % Output layer with 2 classes
        softmaxLayer
        classificationLayer];

    % Define training options
    options = trainingOptions('sgdm', ... % Use stochastic gradient descent with momentum
        'MaxEpochs', 10, ...
        'MiniBatchSize', 32, ...
        'InitialLearnRate', 0.1, ...
        'Shuffle', 'every-epoch', ...
        'Plots', 'training-progress');

    % Train the model
    net = trainNetwork(trainingData, trainingLabels, layers, options);
    
    % Generate predictions on training data
    YPred = predict(net, trainingData);
    
    % Calculate ROC curve
    [FPR, TPR, ~, AUC] = perfcurve(labels, YPred(:,2), true);
    
    % Store TPR and FPR values
    TPR_all{rel_type_idx} = TPR;
    FPR_all{rel_type_idx} = FPR;
    
    % Plot ROC curve
    figure;
    plot(FPR, TPR);
    title(['ROC Curve - Relation Type: ' relation_types{rel_type_idx} ', AUC: ' num2str(AUC)]);
    xlabel('False Positive Rate');
    ylabel('True Positive Rate');
    grid on;
    axis square;
end

