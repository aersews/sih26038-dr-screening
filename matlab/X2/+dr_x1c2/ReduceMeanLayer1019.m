classdef ReduceMeanLayer1019 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1019';
        end
    end


    methods
        function this = ReduceMeanLayer1019(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_282'};
        end

        function [x_backbone_block_282] = predict(this, x_backbone_block_276)
            if isdlarray(x_backbone_block_276)
                x_backbone_block_276 = stripdims(x_backbone_block_276);
            end
            x_backbone_block_276NumDims = 4;
            x_backbone_block_276 = dr_x1c2.ops.permuteInputVar(x_backbone_block_276, [4 3 1 2], 4);

            [x_backbone_block_282, x_backbone_block_282NumDims] = ReduceMeanGraph1057(this, x_backbone_block_276, x_backbone_block_276NumDims, false);
            x_backbone_block_282 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_282, [3 4 2 1], 4);

            x_backbone_block_282 = dlarray(single(x_backbone_block_282), 'SSCB');
        end

        function [x_backbone_block_282] = forward(this, x_backbone_block_276)
            if isdlarray(x_backbone_block_276)
                x_backbone_block_276 = stripdims(x_backbone_block_276);
            end
            x_backbone_block_276NumDims = 4;
            x_backbone_block_276 = dr_x1c2.ops.permuteInputVar(x_backbone_block_276, [4 3 1 2], 4);

            [x_backbone_block_282, x_backbone_block_282NumDims] = ReduceMeanGraph1057(this, x_backbone_block_276, x_backbone_block_276NumDims, true);
            x_backbone_block_282 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_282, [3 4 2 1], 4);

            x_backbone_block_282 = dlarray(single(x_backbone_block_282), 'SSCB');
        end

        function [x_backbone_block_282, x_backbone_block_282NumDims1059] = ReduceMeanGraph1057(this, x_backbone_block_276, x_backbone_block_276NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1058, x_backbone_block_276NumDims);
            xMean = mean(x_backbone_block_276, dims);
            x_backbone_block_282 = xMean;
            x_backbone_block_282NumDims = x_backbone_block_276NumDims;

            % Set graph output arguments
            x_backbone_block_282NumDims1059 = x_backbone_block_282NumDims;

        end

    end

end