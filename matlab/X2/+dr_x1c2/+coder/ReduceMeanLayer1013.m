classdef ReduceMeanLayer1013 < nnet.layer.Layer & nnet.layer.Formattable
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
            this_cg = dr_x1c2.coder.ReduceMeanLayer1013(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.ReduceMeanLayer1013(cgInstance.Name);
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
        function this = ReduceMeanLayer1013(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'x_backbone_block_193'};
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

        function [x_backbone_block_193] = predict(this, x_backbone_block_187__)
            if isdlarray(x_backbone_block_187__)
                x_backbone_block_187_ = stripdims(x_backbone_block_187__);
            else
                x_backbone_block_187_ = x_backbone_block_187__;
            end
            x_backbone_block_187NumDims = 4;
            x_backbone_block_187 = dr_x1c2.coder.ops.permuteInputVar(x_backbone_block_187_, [4 3 1 2], 4);

            [x_backbone_block_193__, x_backbone_block_193NumDims__] = ReduceMeanGraph1039(this, x_backbone_block_187, x_backbone_block_187NumDims, false);
            x_backbone_block_193_ = dr_x1c2.coder.ops.permuteOutputVar(x_backbone_block_193__, [3 4 2 1], 4);

            x_backbone_block_193 = dlarray(single(x_backbone_block_193_), 'SSCB');
        end

        function [x_backbone_block_193, x_backbone_block_193NumDims1041] = ReduceMeanGraph1039(this, x_backbone_block_187, x_backbone_block_187NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1026 = dr_x1c2.coder.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1040, coder.const(x_backbone_block_187NumDims));
            xReduced1027 = mean(x_backbone_block_187, dims1026);
            x_backbone_block_193 = xReduced1027;
            x_backbone_block_193NumDims = coder.const(x_backbone_block_187NumDims);

            % Set graph output arguments
            x_backbone_block_193NumDims1041 = coder.const(x_backbone_block_193NumDims);

        end

    end

end