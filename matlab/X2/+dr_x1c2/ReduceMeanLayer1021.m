classdef ReduceMeanLayer1021 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1021';
        end
    end


    methods
        function this = ReduceMeanLayer1021(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_312'};
        end

        function [x_backbone_block_312] = predict(this, x_backbone_block_306)
            if isdlarray(x_backbone_block_306)
                x_backbone_block_306 = stripdims(x_backbone_block_306);
            end
            x_backbone_block_306NumDims = 4;
            x_backbone_block_306 = dr_x1c2.ops.permuteInputVar(x_backbone_block_306, [4 3 1 2], 4);

            [x_backbone_block_312, x_backbone_block_312NumDims] = ReduceMeanGraph1063(this, x_backbone_block_306, x_backbone_block_306NumDims, false);
            x_backbone_block_312 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_312, [3 4 2 1], 4);

            x_backbone_block_312 = dlarray(single(x_backbone_block_312), 'SSCB');
        end

        function [x_backbone_block_312] = forward(this, x_backbone_block_306)
            if isdlarray(x_backbone_block_306)
                x_backbone_block_306 = stripdims(x_backbone_block_306);
            end
            x_backbone_block_306NumDims = 4;
            x_backbone_block_306 = dr_x1c2.ops.permuteInputVar(x_backbone_block_306, [4 3 1 2], 4);

            [x_backbone_block_312, x_backbone_block_312NumDims] = ReduceMeanGraph1063(this, x_backbone_block_306, x_backbone_block_306NumDims, true);
            x_backbone_block_312 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_312, [3 4 2 1], 4);

            x_backbone_block_312 = dlarray(single(x_backbone_block_312), 'SSCB');
        end

        function [x_backbone_block_312, x_backbone_block_312NumDims1065] = ReduceMeanGraph1063(this, x_backbone_block_306, x_backbone_block_306NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1064, x_backbone_block_306NumDims);
            xMean = mean(x_backbone_block_306, dims);
            x_backbone_block_312 = xMean;
            x_backbone_block_312NumDims = x_backbone_block_306NumDims;

            % Set graph output arguments
            x_backbone_block_312NumDims1065 = x_backbone_block_312NumDims;

        end

    end

end