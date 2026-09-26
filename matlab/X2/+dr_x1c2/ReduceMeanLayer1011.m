classdef ReduceMeanLayer1011 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1011';
        end
    end


    methods
        function this = ReduceMeanLayer1011(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_164'};
        end

        function [x_backbone_block_164] = predict(this, x_backbone_block_158)
            if isdlarray(x_backbone_block_158)
                x_backbone_block_158 = stripdims(x_backbone_block_158);
            end
            x_backbone_block_158NumDims = 4;
            x_backbone_block_158 = dr_x1c2.ops.permuteInputVar(x_backbone_block_158, [4 3 1 2], 4);

            [x_backbone_block_164, x_backbone_block_164NumDims] = ReduceMeanGraph1033(this, x_backbone_block_158, x_backbone_block_158NumDims, false);
            x_backbone_block_164 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_164, [3 4 2 1], 4);

            x_backbone_block_164 = dlarray(single(x_backbone_block_164), 'SSCB');
        end

        function [x_backbone_block_164] = forward(this, x_backbone_block_158)
            if isdlarray(x_backbone_block_158)
                x_backbone_block_158 = stripdims(x_backbone_block_158);
            end
            x_backbone_block_158NumDims = 4;
            x_backbone_block_158 = dr_x1c2.ops.permuteInputVar(x_backbone_block_158, [4 3 1 2], 4);

            [x_backbone_block_164, x_backbone_block_164NumDims] = ReduceMeanGraph1033(this, x_backbone_block_158, x_backbone_block_158NumDims, true);
            x_backbone_block_164 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_164, [3 4 2 1], 4);

            x_backbone_block_164 = dlarray(single(x_backbone_block_164), 'SSCB');
        end

        function [x_backbone_block_164, x_backbone_block_164NumDims1035] = ReduceMeanGraph1033(this, x_backbone_block_158, x_backbone_block_158NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1034, x_backbone_block_158NumDims);
            xMean = mean(x_backbone_block_158, dims);
            x_backbone_block_164 = xMean;
            x_backbone_block_164NumDims = x_backbone_block_158NumDims;

            % Set graph output arguments
            x_backbone_block_164NumDims1035 = x_backbone_block_164NumDims;

        end

    end

end