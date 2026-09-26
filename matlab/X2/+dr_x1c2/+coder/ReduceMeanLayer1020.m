classdef ReduceMeanLayer1020 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1020(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1020(cgInstance.Name);
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
        function this = ReduceMeanLayer1020(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_297'};
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

        function [x_backbone_block_297] = predict(this, x_backbone_block_291__)
            if isdlarray(x_backbone_block_291__)
                x_backbone_block_291_ = stripdims(x_backbone_block_291__);
            else
                x_backbone_block_291_ = x_backbone_block_291__;
            end
            x_backbone_block_291NumDims = 4;
            x_backbone_block_291 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_291_, [4 3 1 2], 4);

            [x_backbone_block_297__, x_backbone_block_297NumDims__] = ReduceMeanGraph1060(this, x_backbone_block_291, x_backbone_block_291NumDims, false);
            x_backbone_block_297_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_297__, [3 4 2 1], 4);

            x_backbone_block_297 = dlarray(single(x_backbone_block_297_), 'SSCB');
        end

        function [x_backbone_block_297, x_backbone_block_297NumDims1062] = ReduceMeanGraph1060(this, x_backbone_block_291, x_backbone_block_291NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1040 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1061, coder.const(x_backbone_block_291NumDims));
            xReduced1041 = mean(x_backbone_block_291, dims1040);
            x_backbone_block_297 = xReduced1041;
            x_backbone_block_297NumDims = coder.const(x_backbone_block_291NumDims);

            % Set graph output arguments
            x_backbone_block_297NumDims1062 = coder.const(x_backbone_block_297NumDims);

        end

    end

end