classdef ReduceMeanLayer1025 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1025(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1025(cgInstance.Name);
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
        function this = ReduceMeanLayer1025(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_371'};
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

        function [x_backbone_block_371] = predict(this, x_backbone_block_365__)
            if isdlarray(x_backbone_block_365__)
                x_backbone_block_365_ = stripdims(x_backbone_block_365__);
            else
                x_backbone_block_365_ = x_backbone_block_365__;
            end
            x_backbone_block_365NumDims = 4;
            x_backbone_block_365 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_365_, [4 3 1 2], 4);

            [x_backbone_block_371__, x_backbone_block_371NumDims__] = ReduceMeanGraph1075(this, x_backbone_block_365, x_backbone_block_365NumDims, false);
            x_backbone_block_371_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_371__, [3 4 2 1], 4);

            x_backbone_block_371 = dlarray(single(x_backbone_block_371_), 'SSCB');
        end

        function [x_backbone_block_371, x_backbone_block_371NumDims1077] = ReduceMeanGraph1075(this, x_backbone_block_365, x_backbone_block_365NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1050 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1076, coder.const(x_backbone_block_365NumDims));
            xReduced1051 = mean(x_backbone_block_365, dims1050);
            x_backbone_block_371 = xReduced1051;
            x_backbone_block_371NumDims = coder.const(x_backbone_block_365NumDims);

            % Set graph output arguments
            x_backbone_block_371NumDims1077 = coder.const(x_backbone_block_371NumDims);

        end

    end

end