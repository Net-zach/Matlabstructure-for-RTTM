function importedModel = importPointPillarsModel(pyTorchPath, outputPath)
%IMPORTPOINTPILLARSMODEL Import Rachel's PyTorch PointPillars model to MATLAB
%   importedModel = importPointPillarsModel(pyTorchPath, outputPath)
%
%   This function handles the complete import workflow:
%   1. Import PyTorch model using importNetworkFromPyTorch
%   2. Add required input layers
%   3. Save as MATLAB .mat file for future use
%   4. Return dlnetwork object
%
%   Inputs:
%       pyTorchPath - Path to Rachel's .pth file
%       outputPath  - Path to save converted .mat file
%
%   Outputs:
%       importedModel - dlnetwork object ready for inference

    try
        fprintf('Starting PyTorch model import process...\n');
        
        % Step 1: Import PyTorch model
        fprintf('Importing from PyTorch: %s\n', pyTorchPath);
        dlnet = importNetworkFromPyTorch(pyTorchPath, ...
            'PreferredNestingType', 'networkLayer');
        
        % Step 2: Analyze imported network
        fprintf('Analyzing imported network structure...\n');
        analyzeNetwork(dlnet);
        
        % Step 3: Add input layer if missing (common for PyTorch models)
        if isempty(dlnet.InputNames)
            fprintf('Adding input layer...\n');
            % Based on PointPillars expected input: [C, H, W] = [4, 496, 432]
            inputSize = [4, 496, 432]; % [channels, height, width] 
            dlnet = addInputLayer(dlnet, inputSize, 'Name', 'pointcloud_input');
        end
        
        % Step 4: Verify network is ready for inference
        fprintf('Verifying network compatibility...\n');
        inputNames = dlnet.InputNames;
        outputNames = dlnet.OutputNames;
        fprintf('Input layers: %s\n', strjoin(inputNames, ', '));
        fprintf('Output layers: %s\n', strjoin(outputNames, ', '));
        
        % Step 5: Save converted model
        if nargin > 1 && ~isempty(outputPath)
            fprintf('Saving converted model to: %s\n', outputPath);
            save(outputPath, 'dlnet', '-v7.3');
        end
        
        importedModel = dlnet;
        fprintf('✅ Successfully imported PyTorch PointPillars model!\n');
        
    catch ME
        fprintf('❌ Error importing PyTorch model:\n');
        fprintf('   %s\n', ME.message);
        
        % Provide troubleshooting suggestions
        fprintf('\n🔧 Troubleshooting suggestions:\n');
        fprintf('1. Ensure PyTorch model is traced and exported properly\n');
        fprintf('2. Check Deep Learning Toolbox Converter for PyTorch Models\n');
        fprintf('3. Verify model file is not corrupted\n');
        fprintf('4. Try converting to ONNX format first\n');
        
        rethrow(ME);
    end
end
