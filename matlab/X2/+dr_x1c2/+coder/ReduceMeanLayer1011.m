classdef ReduceMeanLayer1011 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1011(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1011(cgInstance.Name);
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
        function this = ReduceMeanLayer1011(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_164'};
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

        function [x_backbone_block_164] = predict(this, x_backbone_block_158__)
            if isdlarray(x_backbone_block_158__)
                x_backbone_block_158_ = stripdims(x_backbone_block_158__);
            else
                x_backbone_block_158_ = x_backbone_block_158__;
            end
            x_backbone_block_158NumDims = 4;
            x_backbone_block_158 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_158_, [4 3 1 2], 4);

            [x_backbone_block_164__, x_backbone_block_164NumDims__] = ReduceMeanGraph1033(this, x_backbone_block_158, x_backbone_block_158NumDims, false);
            x_backbone_block_164_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_164__, [3 4 2 1], 4);

            x_backbone_block_164 = dlarray(single(x_backbone_block_164_), 'SSCB');
        end

        function [x_backbone_block_164, x_backbone_block_164NumDims1035] = ReduceMeanGraph1033(this, x_backbone_block_158, x_backbone_block_158NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1022 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1034, coder.const(x_backbone_block_158NumDims));
            xReduced1023 = mean(x_backbone_block_158, dims1022);
            x_backbone_block_164 = xReduced1023;
            x_backbone_block_164NumDims = coder.const(x_backbone_block_158NumDims);

            % Set graph output arguments
            x_backbone_block_164NumDims1035 = coder.const(x_backbone_block_164NumDims);

        end

    end

end