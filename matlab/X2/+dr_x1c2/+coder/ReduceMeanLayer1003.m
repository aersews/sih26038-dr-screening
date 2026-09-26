classdef ReduceMeanLayer1003 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1003(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1003(cgInstance.Name);
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
        function this = ReduceMeanLayer1003(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_blocks_46'};
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

        function [x_backbone_blocks_46] = predict(this, x_backbone_blocks_40__)
            if isdlarray(x_backbone_blocks_40__)
                x_backbone_blocks_40_ = stripdims(x_backbone_blocks_40__);
            else
                x_backbone_blocks_40_ = x_backbone_blocks_40__;
            end
            x_backbone_blocks_40NumDims = 4;
            x_backbone_blocks_40 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_blocks_40_, [4 3 1 2], 4);

            [x_backbone_blocks_46__, x_backbone_blocks_46NumDims__] = ReduceMeanGraph1009(this, x_backbone_blocks_40, x_backbone_blocks_40NumDims, false);
            x_backbone_blocks_46_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_blocks_46__, [3 4 2 1], 4);

            x_backbone_blocks_46 = dlarray(single(x_backbone_blocks_46_), 'SSCB');
        end

        function [x_backbone_blocks_46, x_backbone_blocks_46NumDims1011] = ReduceMeanGraph1009(this, x_backbone_blocks_40, x_backbone_blocks_40NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1006 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1010, coder.const(x_backbone_blocks_40NumDims));
            xReduced1007 = mean(x_backbone_blocks_40, dims1006);
            x_backbone_blocks_46 = xReduced1007;
            x_backbone_blocks_46NumDims = coder.const(x_backbone_blocks_40NumDims);

            % Set graph output arguments
            x_backbone_blocks_46NumDims1011 = coder.const(x_backbone_blocks_46NumDims);

        end

    end

end