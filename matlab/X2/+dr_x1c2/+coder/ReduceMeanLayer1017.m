classdef ReduceMeanLayer1017 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1017(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1017(cgInstance.Name);
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
        function this = ReduceMeanLayer1017(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_253'};
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

        function [x_backbone_block_253] = predict(this, x_backbone_block_247__)
            if isdlarray(x_backbone_block_247__)
                x_backbone_block_247_ = stripdims(x_backbone_block_247__);
            else
                x_backbone_block_247_ = x_backbone_block_247__;
            end
            x_backbone_block_247NumDims = 4;
            x_backbone_block_247 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_247_, [4 3 1 2], 4);

            [x_backbone_block_253__, x_backbone_block_253NumDims__] = ReduceMeanGraph1051(this, x_backbone_block_247, x_backbone_block_247NumDims, false);
            x_backbone_block_253_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_253__, [3 4 2 1], 4);

            x_backbone_block_253 = dlarray(single(x_backbone_block_253_), 'SSCB');
        end

        function [x_backbone_block_253, x_backbone_block_253NumDims1053] = ReduceMeanGraph1051(this, x_backbone_block_247, x_backbone_block_247NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1034 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1052, coder.const(x_backbone_block_247NumDims));
            xReduced1035 = mean(x_backbone_block_247, dims1034);
            x_backbone_block_253 = xReduced1035;
            x_backbone_block_253NumDims = coder.const(x_backbone_block_247NumDims);

            % Set graph output arguments
            x_backbone_block_253NumDims1053 = coder.const(x_backbone_block_253NumDims);

        end

    end

end