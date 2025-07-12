classdef PointPillarsDetector < handle
    %POINTPILLARSDETECTOR 3D object detection using imported PyTorch PointPillars model
    %   Compatible with MATLAB 2025a Deep Learning Toolbox and LiDAR Toolbox
    %   Imports Rachel's trained PyTorch model using importNetworkFromPyTorch
    
    properties (Access = private)
        NetworkModel dlnetwork         % Imported PyTorch model as dlnetwork
        ModelConfig struct             % Model configuration parameters
        ClassNames string              % Object class names
        PointCloudRange double         % [xmin, ymin, zmin, xmax, ymax, zmax]
        VoxelSize double               % [x, y, z] voxel dimensions
        ScoreThreshold double          % Detection confidence threshold
        NMSThreshold double            % Non-maximum suppression threshold
        IsInitialized logical          % Model initialization status
    end
    
    methods
        function obj = PointPillarsDetector(pyTorchModelPath, configPath)
            %POINTPILLARSDETECTOR Constructor - imports PyTorch model
            %   obj = PointPillarsDetector(pyTorchModelPath, configPath)
            %   
            %   Inputs:
            %       pyTorchModelPath - Path to Rachel's .pth model file
            %       configPath       - Path to configuration file
            
            obj.IsInitialized = false;
            if nargin > 0
                obj.loadModel(pyTorchModelPath, configPath);
            end
        end
        
        function loadModel(obj, pyTorchModelPath, configPath)
            %LOADMODEL Import PyTorch model using MATLAB 2025a functions
            %   Uses importNetworkFromPyTorch for proper model conversion
            
            try
                % Load configuration first
                if nargin > 2 && ~isempty(configPath)
                    obj.loadConfiguration(configPath);
                else
                    obj.loadDefaultConfiguration();
                end
                
                % Import PyTorch model as dlnetwork
                fprintf('Importing PyTorch model: %s\n', pyTorchModelPath);
                obj.NetworkModel = importNetworkFromPyTorch(pyTorchModelPath);
                
                % Add input layer if needed (common requirement)
                if isempty(obj.NetworkModel.InputNames)
                    inputSize = [obj.ModelConfig.InputChannels, ...
                                obj.ModelConfig.GridSize(1), ...
                                obj.ModelConfig.GridSize(2)];
                    obj.NetworkModel = addInputLayer(obj.NetworkModel, inputSize, ...
                                                   'Name', 'input_layer');
                end
                
                obj.IsInitialized = true;
                fprintf('✅ PyTorch model successfully imported as dlnetwork\n');
                
            catch ME
                warning('Failed to import PyTorch model: %s', ME.message);
                obj.IsInitialized = false;
            end
        end
        
        function detections = detect(obj, pointCloud)
            %DETECT Perform 3D object detection on point cloud
            %   detections = detect(obj, pointCloud)
            %   
            %   Uses MATLAB LiDAR Toolbox pipeline with imported PyTorch model
            
            if ~obj.IsInitialized
                error('Model not initialized. Call loadModel() first.');
            end
            
            % Preprocess point cloud using LiDAR Toolbox functions
            processedData = pointpillars.preprocessing.preprocessPointCloud(...
                pointCloud, obj.ModelConfig);
            
            % Run inference using dlnetwork
            dlInput = dlarray(processedData, 'SSCB'); % [Spatial, Spatial, Channel, Batch]
            dlOutput = predict(obj.NetworkModel, dlInput);
            
            % Post-process results to get bounding boxes
            detections = obj.postProcessDetections(dlOutput);
        end
        
        function config = loadDefaultConfiguration(obj)
            %LOADDEFAULTCONFIGURATION Load Rachel's model configuration
            
            obj.ModelConfig.ClassNames = ["Pedestrian", "Cyclist", "Car"];
            obj.ModelConfig.NumClasses = 3;
            obj.ModelConfig.PointCloudRange = [0, -39.68, -3, 69.12, 39.68, 1];
            obj.ModelConfig.VoxelSize = [0.16, 0.16, 4];
            obj.ModelConfig.GridSize = [496, 432]; % From middle_encoder
            obj.ModelConfig.InputChannels = 4; % [x, y, z, intensity]
            obj.ModelConfig.ScoreThreshold = 0.1;
            obj.ModelConfig.NMSThreshold = 0.01;
            
            % Copy to object properties
            obj.ClassNames = obj.ModelConfig.ClassNames;
            obj.PointCloudRange = obj.ModelConfig.PointCloudRange;
            obj.VoxelSize = obj.ModelConfig.VoxelSize;
            obj.ScoreThreshold = obj.ModelConfig.ScoreThreshold;
            obj.NMSThreshold = obj.ModelConfig.NMSThreshold;
        end
        
        function detections = postProcessDetections(obj, dlOutput)
            %POSTPROCESSDETECTIONS Convert network output to bounding boxes
            %   Implementation depends on Rachel's model output format
            
            % TODO: Implement based on Rachel's model output structure
            % This will decode the network predictions into 3D bounding boxes
            detections = [];
        end
    end
end
