classdef ReduceMeanLayer1024 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1024(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1024(cgInstance.Name);
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
        function this = ReduceMeanLayer1024(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_356'};
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

        function [x_backbone_block_356] = predict(this, x_backbone_block_350__)
            if isdlarray(x_backbone_block_350__)
                x_backbone_block_350_ = stripdims(x_backbone_block_350__);
            else
                x_backbone_block_350_ = x_backbone_block_350__;
            end
            x_backbone_block_350NumDims = 4;
            x_backbone_block_350 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_350_, [4 3 1 2], 4);

            [x_backbone_block_356__, x_backbone_block_356NumDims__] = ReduceMeanGraph1072(this, x_backbone_block_350, x_backbone_block_350NumDims, false);
            x_backbone_block_356_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_356__, [3 4 2 1], 4);

            x_backbone_block_356 = dlarray(single(x_backbone_block_356_), 'SSCB');
        end

        function [x_backbone_block_356, x_backbone_block_356NumDims1074] = ReduceMeanGraph1072(this, x_backbone_block_350, x_backbone_block_350NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1048 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1073, coder.const(x_backbone_block_350NumDims));
            xReduced1049 = mean(x_backbone_block_350, dims1048);
            x_backbone_block_356 = xReduced1049;
            x_backbone_block_356NumDims = coder.const(x_backbone_block_350NumDims);

            % Set graph output arguments
            x_backbone_block_356NumDims1074 = coder.const(x_backbone_block_356NumDims);

        end

    end

end