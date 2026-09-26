classdef ReduceMeanLayer1002 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1002(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1002(cgInstance.Name);
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
        function this = ReduceMeanLayer1002(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_blocks_31'};
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

        function [x_backbone_blocks_31] = predict(this, x_backbone_blocks_25__)
            if isdlarray(x_backbone_blocks_25__)
                x_backbone_blocks_25_ = stripdims(x_backbone_blocks_25__);
            else
                x_backbone_blocks_25_ = x_backbone_blocks_25__;
            end
            x_backbone_blocks_25NumDims = 4;
            x_backbone_blocks_25 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_blocks_25_, [4 3 1 2], 4);

            [x_backbone_blocks_31__, x_backbone_blocks_31NumDims__] = ReduceMeanGraph1006(this, x_backbone_blocks_25, x_backbone_blocks_25NumDims, false);
            x_backbone_blocks_31_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_blocks_31__, [3 4 2 1], 4);

            x_backbone_blocks_31 = dlarray(single(x_backbone_blocks_31_), 'SSCB');
        end

        function [x_backbone_blocks_31, x_backbone_blocks_31NumDims1008] = ReduceMeanGraph1006(this, x_backbone_blocks_25, x_backbone_blocks_25NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1004 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1007, coder.const(x_backbone_blocks_25NumDims));
            xReduced1005 = mean(x_backbone_blocks_25, dims1004);
            x_backbone_blocks_31 = xReduced1005;
            x_backbone_blocks_31NumDims = coder.const(x_backbone_blocks_25NumDims);

            % Set graph output arguments
            x_backbone_blocks_31NumDims1008 = coder.const(x_backbone_blocks_31NumDims);

        end

    end

end