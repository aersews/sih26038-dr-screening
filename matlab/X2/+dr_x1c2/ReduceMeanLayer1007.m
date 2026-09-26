classdef ReduceMeanLayer1007 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1007';
        end
    end


    methods
        function this = ReduceMeanLayer1007(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_105'};
        end

        function [x_backbone_block_105] = predict(this, x_backbone_blocks_99)
            if isdlarray(x_backbone_blocks_99)
                x_backbone_blocks_99 = stripdims(x_backbone_blocks_99);
            end
            x_backbone_blocks_99NumDims = 4;
            x_backbone_blocks_99 = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_99, [4 3 1 2], 4);

            [x_backbone_block_105, x_backbone_block_105NumDims] = ReduceMeanGraph1021(this, x_backbone_blocks_99, x_backbone_blocks_99NumDims, false);
            x_backbone_block_105 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_105, [3 4 2 1], 4);

            x_backbone_block_105 = dlarray(single(x_backbone_block_105), 'SSCB');
        end

        function [x_backbone_block_105] = forward(this, x_backbone_blocks_99)
            if isdlarray(x_backbone_blocks_99)
                x_backbone_blocks_99 = stripdims(x_backbone_blocks_99);
            end
            x_backbone_blocks_99NumDims = 4;
            x_backbone_blocks_99 = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_99, [4 3 1 2], 4);

            [x_backbone_block_105, x_backbone_block_105NumDims] = ReduceMeanGraph1021(this, x_backbone_blocks_99, x_backbone_blocks_99NumDims, true);
            x_backbone_block_105 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_105, [3 4 2 1], 4);

            x_backbone_block_105 = dlarray(single(x_backbone_block_105), 'SSCB');
        end

        function [x_backbone_block_105, x_backbone_block_105NumDims1023] = ReduceMeanGraph1021(this, x_backbone_blocks_99, x_backbone_blocks_99NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1022, x_backbone_blocks_99NumDims);
            xMean = mean(x_backbone_blocks_99, dims);
            x_backbone_block_105 = xMean;
            x_backbone_block_105NumDims = x_backbone_blocks_99NumDims;

            % Set graph output arguments
            x_backbone_block_105NumDims1023 = x_backbone_block_105NumDims;

        end

    end

end