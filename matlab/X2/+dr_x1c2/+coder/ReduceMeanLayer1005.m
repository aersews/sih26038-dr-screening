classdef ReduceMeanLayer1005 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1005(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1005(cgInstance.Name);
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
        function this = ReduceMeanLayer1005(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_blocks_75'};
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

        function [x_backbone_blocks_75] = predict(this, x_backbone_blocks_69__)
            if isdlarray(x_backbone_blocks_69__)
                x_backbone_blocks_69_ = stripdims(x_backbone_blocks_69__);
            else
                x_backbone_blocks_69_ = x_backbone_blocks_69__;
            end
            x_backbone_blocks_69NumDims = 4;
            x_backbone_blocks_69 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_blocks_69_, [4 3 1 2], 4);

            [x_backbone_blocks_75__, x_backbone_blocks_75NumDims__] = ReduceMeanGraph1015(this, x_backbone_blocks_69, x_backbone_blocks_69NumDims, false);
            x_backbone_blocks_75_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_blocks_75__, [3 4 2 1], 4);

            x_backbone_blocks_75 = dlarray(single(x_backbone_blocks_75_), 'SSCB');
        end

        function [x_backbone_blocks_75, x_backbone_blocks_75NumDims1017] = ReduceMeanGraph1015(this, x_backbone_blocks_69, x_backbone_blocks_69NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1010 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1016, coder.const(x_backbone_blocks_69NumDims));
            xReduced1011 = mean(x_backbone_blocks_69, dims1010);
            x_backbone_blocks_75 = xReduced1011;
            x_backbone_blocks_75NumDims = coder.const(x_backbone_blocks_69NumDims);

            % Set graph output arguments
            x_backbone_blocks_75NumDims1017 = coder.const(x_backbone_blocks_75NumDims);

        end

    end

end