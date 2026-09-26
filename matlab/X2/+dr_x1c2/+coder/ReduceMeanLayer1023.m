classdef ReduceMeanLayer1023 < nnet.layer.Layer & nnet.layer.Formattable
    % A custom layer auto-generated while importing an ONNX network.
    %#codegen

    %#ok<*PROPLC>
    %#ok<*NBRAK>
    %#ok<*INUSL>
    %#ok<*VARARG>
    properties (Learnable)
    end

    properties (State)
    end

    properties
        Vars
        NumDims
    end

    methods(Static, Hidden)
        % Specify the properties of the class that will not be modified
        % after the first assignment.
        function p = matlabCodegenNontunableProperties(~)
            p = {
                % Constants, i.e., Vars, NumDims and all learnables and states
                'Vars'
                'NumDims'
                };
        end
    end


    methods(Static, Hidden)
        % Instantiate a codegenable layer instance from a MATLAB layer instance
        function this_cg = matlabCodegenToRedirected(mlInstance)
            this_cg = dr_x1c2.coder.ReduceMeanLayer1023(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1023(cgInstance.Name);
            if isstruct(cgInstance.Vars)
                names = fieldnames(cgInstance.Vars);
                for i=1:numel(names)
                    fieldname = names{i};
                    this_ml.Vars.(fieldname) = dlarray(cgInstance.Vars.(fieldname));
                end
            else
                this_ml.Vars = [];
            end
            this_ml.NumDims = cgInstance.NumDims;
        end
    end

    methods
        function this = ReduceMeanLayer1023(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_342'};
            if isstruct(mlInstance.Vars)
                names = fieldnames(mlInstance.Vars);
                for i=1:numel(names)
                    fieldname = names{i};
                    this.Vars.(fieldname) = dr_x1c2.coder.ops.extractIfDlarray(mlInstance.Vars.(fieldname));
                end
            else
                this.Vars = [];
            end

            this.NumDims = mlInstance.NumDims;
        end

        function [x_backbone_block_342] = predict(this, x_backbone_block_336__)
            if isdlarray(x_backbone_block_336__)
                x_backbone_block_336_ = stripdims(x_backbone_block_336__);
            else
                x_backbone_block_336_ = x_backbone_block_336__;
            end
            x_backbone_block_336NumDims = 4;
            x_backbone_block_336 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_336_, [4 3 1 2], 4);

            [x_backbone_block_342__, x_backbone_block_342NumDims__] = ReduceMeanGraph1069(this, x_backbone_block_336, x_backbone_block_336NumDims, false);
            x_backbone_block_342_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_342__, [3 4 2 1], 4);

            x_backbone_block_342 = dlarray(single(x_backbone_block_342_), 'SSCB');
        end

        function [x_backbone_block_342, x_backbone_block_342NumDims1071] = ReduceMeanGraph1069(this, x_backbone_block_336, x_backbone_block_336NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1046 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1070, coder.const(x_backbone_block_336NumDims));
            xReduced1047 = mean(x_backbone_block_336, dims1046);
            x_backbone_block_342 = xReduced1047;
            x_backbone_block_342NumDims = coder.const(x_backbone_block_336NumDims);

            % Set graph output arguments
            x_backbone_block_342NumDims1071 = coder.const(x_backbone_block_342NumDims);

        end

    end

end