classdef ReduceMeanLayer1008 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1008(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1008(cgInstance.Name);
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
        function this = ReduceMeanLayer1008(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_119'};
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

        function [x_backbone_block_119] = predict(this, x_backbone_block_113__)
            if isdlarray(x_backbone_block_113__)
                x_backbone_block_113_ = stripdims(x_backbone_block_113__);
            else
                x_backbone_block_113_ = x_backbone_block_113__;
            end
            x_backbone_block_113NumDims = 4;
            x_backbone_block_113 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_113_, [4 3 1 2], 4);

            [x_backbone_block_119__, x_backbone_block_119NumDims__] = ReduceMeanGraph1024(this, x_backbone_block_113, x_backbone_block_113NumDims, false);
            x_backbone_block_119_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_119__, [3 4 2 1], 4);

            x_backbone_block_119 = dlarray(single(x_backbone_block_119_), 'SSCB');
        end

        function [x_backbone_block_119, x_backbone_block_119NumDims1026] = ReduceMeanGraph1024(this, x_backbone_block_113, x_backbone_block_113NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1016 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1025, coder.const(x_backbone_block_113NumDims));
            xReduced1017 = mean(x_backbone_block_113, dims1016);
            x_backbone_block_119 = xReduced1017;
            x_backbone_block_119NumDims = coder.const(x_backbone_block_113NumDims);

            % Set graph output arguments
            x_backbone_block_119NumDims1026 = coder.const(x_backbone_block_119NumDims);

        end

    end

end