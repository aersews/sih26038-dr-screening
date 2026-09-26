classdef ReduceMeanLayer1000 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1000';
        end
    end


    methods
        function this = ReduceMeanLayer1000(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_blocks__5'};
        end

        function [x_backbone_blocks__5] = predict(this, x_backbone_blocks_bl)
            if isdlarray(x_backbone_blocks_bl)
                x_backbone_blocks_bl = stripdims(x_backbone_blocks_bl);
            end
            x_backbone_blocks_blNumDims = 4;
            x_backbone_blocks_bl = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_bl, [4 3 1 2], 4);

            [x_backbone_blocks__5, x_backbone_blocks__5NumDims] = ReduceMeanGraph1000(this, x_backbone_blocks_bl, x_backbone_blocks_blNumDims, false);
            x_backbone_blocks__5 = dr_x1c2.ops.permuteOutputVar(x_backbone_blocks__5, [3 4 2 1], 4);

            x_backbone_blocks__5 = dlarray(single(x_backbone_blocks__5), 'SSCB');
        end

        function [x_backbone_blocks__5] = forward(this, x_backbone_blocks_bl)
            if isdlarray(x_backbone_blocks_bl)
                x_backbone_blocks_bl = stripdims(x_backbone_blocks_bl);
            end
            x_backbone_blocks_blNumDims = 4;
            x_backbone_blocks_bl = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_bl, [4 3 1 2], 4);

            [x_backbone_blocks__5, x_backbone_blocks__5NumDims] = ReduceMeanGraph1000(this, x_backbone_blocks_bl, x_backbone_blocks_blNumDims, true);
            x_backbone_blocks__5 = dr_x1c2.ops.permuteOutputVar(x_backbone_blocks__5, [3 4 2 1], 4);

            x_backbone_blocks__5 = dlarray(single(x_backbone_blocks__5), 'SSCB');
        end

        function [x_backbone_blocks__5, x_backbone_blocks__5NumDims1002] = ReduceMeanGraph1000(this, x_backbone_blocks_bl, x_backbone_blocks_blNumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1001, x_backbone_blocks_blNumDims);
            xMean = mean(x_backbone_blocks_bl, dims);
            x_backbone_blocks__5 = xMean;
            x_backbone_blocks__5NumDims = x_backbone_blocks_blNumDims;

            % Set graph output arguments
            x_backbone_blocks__5NumDims1002 = x_backbone_blocks__5NumDims;

        end

    end

end