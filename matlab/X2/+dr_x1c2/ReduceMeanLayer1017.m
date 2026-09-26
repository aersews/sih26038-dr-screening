classdef ReduceMeanLayer1017 < nnet.layer.Layer & nnet.layer.Formattable
    % A custom layer auto-generated while importing an ONNX network.

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
        % Specify the path to the class that will be used for codegen
        function name = matlabCodegenRedirect(~)
            name = 'dr_x1c2.coder.ReduceMeanLayer1017';
        end
    end


    methods
        function this = ReduceMeanLayer1017(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_253'};
        end

        function [x_backbone_block_253] = predict(this, x_backbone_block_247)
            if isdlarray(x_backbone_block_247)
                x_backbone_block_247 = stripdims(x_backbone_block_247);
            end
            x_backbone_block_247NumDims = 4;
            x_backbone_block_247 = dr_x1c2.ops.permuteInputVar(x_backbone_block_247, [4 3 1 2], 4);

            [x_backbone_block_253, x_backbone_block_253NumDims] = ReduceMeanGraph1051(this, x_backbone_block_247, x_backbone_block_247NumDims, false);
            x_backbone_block_253 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_253, [3 4 2 1], 4);

            x_backbone_block_253 = dlarray(single(x_backbone_block_253), 'SSCB');
        end

        function [x_backbone_block_253] = forward(this, x_backbone_block_247)
            if isdlarray(x_backbone_block_247)
                x_backbone_block_247 = stripdims(x_backbone_block_247);
            end
            x_backbone_block_247NumDims = 4;
            x_backbone_block_247 = dr_x1c2.ops.permuteInputVar(x_backbone_block_247, [4 3 1 2], 4);

            [x_backbone_block_253, x_backbone_block_253NumDims] = ReduceMeanGraph1051(this, x_backbone_block_247, x_backbone_block_247NumDims, true);
            x_backbone_block_253 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_253, [3 4 2 1], 4);

            x_backbone_block_253 = dlarray(single(x_backbone_block_253), 'SSCB');
        end

        function [x_backbone_block_253, x_backbone_block_253NumDims1053] = ReduceMeanGraph1051(this, x_backbone_block_247, x_backbone_block_247NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1052, x_backbone_block_247NumDims);
            xMean = mean(x_backbone_block_247, dims);
            x_backbone_block_253 = xMean;
            x_backbone_block_253NumDims = x_backbone_block_247NumDims;

            % Set graph output arguments
            x_backbone_block_253NumDims1053 = x_backbone_block_253NumDims;

        end

    end

end