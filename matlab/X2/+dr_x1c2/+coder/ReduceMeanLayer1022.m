classdef ReduceMeanLayer1022 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1022(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1022(cgInstance.Name);
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
        function this = ReduceMeanLayer1022(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_327'};
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

        function [x_backbone_block_327] = predict(this, x_backbone_block_321__)
            if isdlarray(x_backbone_block_321__)
                x_backbone_block_321_ = stripdims(x_backbone_block_321__);
            else
                x_backbone_block_321_ = x_backbone_block_321__;
            end
            x_backbone_block_321NumDims = 4;
            x_backbone_block_321 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_321_, [4 3 1 2], 4);

            [x_backbone_block_327__, x_backbone_block_327NumDims__] = ReduceMeanGraph1066(this, x_backbone_block_321, x_backbone_block_321NumDims, false);
            x_backbone_block_327_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_327__, [3 4 2 1], 4);

            x_backbone_block_327 = dlarray(single(x_backbone_block_327_), 'SSCB');
        end

        function [x_backbone_block_327, x_backbone_block_327NumDims1068] = ReduceMeanGraph1066(this, x_backbone_block_321, x_backbone_block_321NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1044 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1067, coder.const(x_backbone_block_321NumDims));
            xReduced1045 = mean(x_backbone_block_321, dims1044);
            x_backbone_block_327 = xReduced1045;
            x_backbone_block_327NumDims = coder.const(x_backbone_block_321NumDims);

            % Set graph output arguments
            x_backbone_block_327NumDims1068 = coder.const(x_backbone_block_327NumDims);

        end

    end

end