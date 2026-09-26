classdef ReduceMeanLayer1025 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1025';
        end
    end


    methods
        function this = ReduceMeanLayer1025(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_371'};
        end

        function [x_backbone_block_371] = predict(this, x_backbone_block_365)
            if isdlarray(x_backbone_block_365)
                x_backbone_block_365 = stripdims(x_backbone_block_365);
            end
            x_backbone_block_365NumDims = 4;
            x_backbone_block_365 = dr_x1c2.ops.permuteInputVar(x_backbone_block_365, [4 3 1 2], 4);

            [x_backbone_block_371, x_backbone_block_371NumDims] = ReduceMeanGraph1075(this, x_backbone_block_365, x_backbone_block_365NumDims, false);
            x_backbone_block_371 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_371, [3 4 2 1], 4);

            x_backbone_block_371 = dlarray(single(x_backbone_block_371), 'SSCB');
        end

        function [x_backbone_block_371] = forward(this, x_backbone_block_365)
            if isdlarray(x_backbone_block_365)
                x_backbone_block_365 = stripdims(x_backbone_block_365);
            end
            x_backbone_block_365NumDims = 4;
            x_backbone_block_365 = dr_x1c2.ops.permuteInputVar(x_backbone_block_365, [4 3 1 2], 4);

            [x_backbone_block_371, x_backbone_block_371NumDims] = ReduceMeanGraph1075(this, x_backbone_block_365, x_backbone_block_365NumDims, true);
            x_backbone_block_371 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_371, [3 4 2 1], 4);

            x_backbone_block_371 = dlarray(single(x_backbone_block_371), 'SSCB');
        end

        function [x_backbone_block_371, x_backbone_block_371NumDims1077] = ReduceMeanGraph1075(this, x_backbone_block_365, x_backbone_block_365NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1076, x_backbone_block_365NumDims);
            xMean = mean(x_backbone_block_365, dims);
            x_backbone_block_371 = xMean;
            x_backbone_block_371NumDims = x_backbone_block_365NumDims;

            % Set graph output arguments
            x_backbone_block_371NumDims1077 = x_backbone_block_371NumDims;

        end

    end

end