classdef ReduceMeanLayer1010 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1010';
        end
    end


    methods
        function this = ReduceMeanLayer1010(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_149'};
        end

        function [x_backbone_block_149] = predict(this, x_backbone_block_143)
            if isdlarray(x_backbone_block_143)
                x_backbone_block_143 = stripdims(x_backbone_block_143);
            end
            x_backbone_block_143NumDims = 4;
            x_backbone_block_143 = dr_x1c2.ops.permuteInputVar(x_backbone_block_143, [4 3 1 2], 4);

            [x_backbone_block_149, x_backbone_block_149NumDims] = ReduceMeanGraph1030(this, x_backbone_block_143, x_backbone_block_143NumDims, false);
            x_backbone_block_149 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_149, [3 4 2 1], 4);

            x_backbone_block_149 = dlarray(single(x_backbone_block_149), 'SSCB');
        end

        function [x_backbone_block_149] = forward(this, x_backbone_block_143)
            if isdlarray(x_backbone_block_143)
                x_backbone_block_143 = stripdims(x_backbone_block_143);
            end
            x_backbone_block_143NumDims = 4;
            x_backbone_block_143 = dr_x1c2.ops.permuteInputVar(x_backbone_block_143, [4 3 1 2], 4);

            [x_backbone_block_149, x_backbone_block_149NumDims] = ReduceMeanGraph1030(this, x_backbone_block_143, x_backbone_block_143NumDims, true);
            x_backbone_block_149 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_149, [3 4 2 1], 4);

            x_backbone_block_149 = dlarray(single(x_backbone_block_149), 'SSCB');
        end

        function [x_backbone_block_149, x_backbone_block_149NumDims1032] = ReduceMeanGraph1030(this, x_backbone_block_143, x_backbone_block_143NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1031, x_backbone_block_143NumDims);
            xMean = mean(x_backbone_block_143, dims);
            x_backbone_block_149 = xMean;
            x_backbone_block_149NumDims = x_backbone_block_143NumDims;

            % Set graph output arguments
            x_backbone_block_149NumDims1032 = x_backbone_block_149NumDims;

        end

    end

end