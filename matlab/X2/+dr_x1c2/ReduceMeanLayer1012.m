classdef ReduceMeanLayer1012 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1012';
        end
    end


    methods
        function this = ReduceMeanLayer1012(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_179'};
        end

        function [x_backbone_block_179] = predict(this, x_backbone_block_173)
            if isdlarray(x_backbone_block_173)
                x_backbone_block_173 = stripdims(x_backbone_block_173);
            end
            x_backbone_block_173NumDims = 4;
            x_backbone_block_173 = dr_x1c2.ops.permuteInputVar(x_backbone_block_173, [4 3 1 2], 4);

            [x_backbone_block_179, x_backbone_block_179NumDims] = ReduceMeanGraph1036(this, x_backbone_block_173, x_backbone_block_173NumDims, false);
            x_backbone_block_179 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_179, [3 4 2 1], 4);

            x_backbone_block_179 = dlarray(single(x_backbone_block_179), 'SSCB');
        end

        function [x_backbone_block_179] = forward(this, x_backbone_block_173)
            if isdlarray(x_backbone_block_173)
                x_backbone_block_173 = stripdims(x_backbone_block_173);
            end
            x_backbone_block_173NumDims = 4;
            x_backbone_block_173 = dr_x1c2.ops.permuteInputVar(x_backbone_block_173, [4 3 1 2], 4);

            [x_backbone_block_179, x_backbone_block_179NumDims] = ReduceMeanGraph1036(this, x_backbone_block_173, x_backbone_block_173NumDims, true);
            x_backbone_block_179 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_179, [3 4 2 1], 4);

            x_backbone_block_179 = dlarray(single(x_backbone_block_179), 'SSCB');
        end

        function [x_backbone_block_179, x_backbone_block_179NumDims1038] = ReduceMeanGraph1036(this, x_backbone_block_173, x_backbone_block_173NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1037, x_backbone_block_173NumDims);
            xMean = mean(x_backbone_block_173, dims);
            x_backbone_block_179 = xMean;
            x_backbone_block_179NumDims = x_backbone_block_173NumDims;

            % Set graph output arguments
            x_backbone_block_179NumDims1038 = x_backbone_block_179NumDims;

        end

    end

end