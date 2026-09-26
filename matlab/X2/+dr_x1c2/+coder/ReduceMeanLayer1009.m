classdef ReduceMeanLayer1009 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1009(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1009(cgInstance.Name);
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
        function this = ReduceMeanLayer1009(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_134'};
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

        function [x_backbone_block_134] = predict(this, x_backbone_block_128__)
            if isdlarray(x_backbone_block_128__)
                x_backbone_block_128_ = stripdims(x_backbone_block_128__);
            else
                x_backbone_block_128_ = x_backbone_block_128__;
            end
            x_backbone_block_128NumDims = 4;
            x_backbone_block_128 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_128_, [4 3 1 2], 4);

            [x_backbone_block_134__, x_backbone_block_134NumDims__] = ReduceMeanGraph1027(this, x_backbone_block_128, x_backbone_block_128NumDims, false);
            x_backbone_block_134_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_134__, [3 4 2 1], 4);

            x_backbone_block_134 = dlarray(single(x_backbone_block_134_), 'SSCB');
        end

        function [x_backbone_block_134, x_backbone_block_134NumDims1029] = ReduceMeanGraph1027(this, x_backbone_block_128, x_backbone_block_128NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1018 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1028, coder.const(x_backbone_block_128NumDims));
            xReduced1019 = mean(x_backbone_block_128, dims1018);
            x_backbone_block_134 = xReduced1019;
            x_backbone_block_134NumDims = coder.const(x_backbone_block_128NumDims);

            % Set graph output arguments
            x_backbone_block_134NumDims1029 = coder.const(x_backbone_block_134NumDims);

        end

    end

end