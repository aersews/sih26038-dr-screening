classdef ReduceMeanLayer1008 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1008';
        end
    end


    methods
        function this = ReduceMeanLayer1008(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_119'};
        end

        function [x_backbone_block_119] = predict(this, x_backbone_block_113)
            if isdlarray(x_backbone_block_113)
                x_backbone_block_113 = stripdims(x_backbone_block_113);
            end
            x_backbone_block_113NumDims = 4;
            x_backbone_block_113 = dr_x1c2.ops.permuteInputVar(x_backbone_block_113, [4 3 1 2], 4);

            [x_backbone_block_119, x_backbone_block_119NumDims] = ReduceMeanGraph1024(this, x_backbone_block_113, x_backbone_block_113NumDims, false);
            x_backbone_block_119 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_119, [3 4 2 1], 4);

            x_backbone_block_119 = dlarray(single(x_backbone_block_119), 'SSCB');
        end

        function [x_backbone_block_119] = forward(this, x_backbone_block_113)
            if isdlarray(x_backbone_block_113)
                x_backbone_block_113 = stripdims(x_backbone_block_113);
            end
            x_backbone_block_113NumDims = 4;
            x_backbone_block_113 = dr_x1c2.ops.permuteInputVar(x_backbone_block_113, [4 3 1 2], 4);

            [x_backbone_block_119, x_backbone_block_119NumDims] = ReduceMeanGraph1024(this, x_backbone_block_113, x_backbone_block_113NumDims, true);
            x_backbone_block_119 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_119, [3 4 2 1], 4);

            x_backbone_block_119 = dlarray(single(x_backbone_block_119), 'SSCB');
        end

        function [x_backbone_block_119, x_backbone_block_119NumDims1026] = ReduceMeanGraph1024(this, x_backbone_block_113, x_backbone_block_113NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1025, x_backbone_block_113NumDims);
            xMean = mean(x_backbone_block_113, dims);
            x_backbone_block_119 = xMean;
            x_backbone_block_119NumDims = x_backbone_block_113NumDims;

            % Set graph output arguments
            x_backbone_block_119NumDims1026 = x_backbone_block_119NumDims;

        end

    end

end