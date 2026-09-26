classdef ReduceMeanLayer1023 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1023';
        end
    end


    methods
        function this = ReduceMeanLayer1023(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_342'};
        end

        function [x_backbone_block_342] = predict(this, x_backbone_block_336)
            if isdlarray(x_backbone_block_336)
                x_backbone_block_336 = stripdims(x_backbone_block_336);
            end
            x_backbone_block_336NumDims = 4;
            x_backbone_block_336 = dr_x1c2.ops.permuteInputVar(x_backbone_block_336, [4 3 1 2], 4);

            [x_backbone_block_342, x_backbone_block_342NumDims] = ReduceMeanGraph1069(this, x_backbone_block_336, x_backbone_block_336NumDims, false);
            x_backbone_block_342 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_342, [3 4 2 1], 4);

            x_backbone_block_342 = dlarray(single(x_backbone_block_342), 'SSCB');
        end

        function [x_backbone_block_342] = forward(this, x_backbone_block_336)
            if isdlarray(x_backbone_block_336)
                x_backbone_block_336 = stripdims(x_backbone_block_336);
            end
            x_backbone_block_336NumDims = 4;
            x_backbone_block_336 = dr_x1c2.ops.permuteInputVar(x_backbone_block_336, [4 3 1 2], 4);

            [x_backbone_block_342, x_backbone_block_342NumDims] = ReduceMeanGraph1069(this, x_backbone_block_336, x_backbone_block_336NumDims, true);
            x_backbone_block_342 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_342, [3 4 2 1], 4);

            x_backbone_block_342 = dlarray(single(x_backbone_block_342), 'SSCB');
        end

        function [x_backbone_block_342, x_backbone_block_342NumDims1071] = ReduceMeanGraph1069(this, x_backbone_block_336, x_backbone_block_336NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1070, x_backbone_block_336NumDims);
            xMean = mean(x_backbone_block_336, dims);
            x_backbone_block_342 = xMean;
            x_backbone_block_342NumDims = x_backbone_block_336NumDims;

            % Set graph output arguments
            x_backbone_block_342NumDims1071 = x_backbone_block_342NumDims;

        end

    end

end