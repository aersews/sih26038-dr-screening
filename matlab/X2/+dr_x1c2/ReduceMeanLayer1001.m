classdef ReduceMeanLayer1001 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1001';
        end
    end


    methods
        function this = ReduceMeanLayer1001(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_blocks_17'};
        end

        function [x_backbone_blocks_17] = predict(this, x_backbone_blocks_12)
            if isdlarray(x_backbone_blocks_12)
                x_backbone_blocks_12 = stripdims(x_backbone_blocks_12);
            end
            x_backbone_blocks_12NumDims = 4;
            x_backbone_blocks_12 = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_12, [4 3 1 2], 4);

            [x_backbone_blocks_17, x_backbone_blocks_17NumDims] = ReduceMeanGraph1003(this, x_backbone_blocks_12, x_backbone_blocks_12NumDims, false);
            x_backbone_blocks_17 = dr_x1c2.ops.permuteOutputVar(x_backbone_blocks_17, [3 4 2 1], 4);

            x_backbone_blocks_17 = dlarray(single(x_backbone_blocks_17), 'SSCB');
        end

        function [x_backbone_blocks_17] = forward(this, x_backbone_blocks_12)
            if isdlarray(x_backbone_blocks_12)
                x_backbone_blocks_12 = stripdims(x_backbone_blocks_12);
            end
            x_backbone_blocks_12NumDims = 4;
            x_backbone_blocks_12 = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_12, [4 3 1 2], 4);

            [x_backbone_blocks_17, x_backbone_blocks_17NumDims] = ReduceMeanGraph1003(this, x_backbone_blocks_12, x_backbone_blocks_12NumDims, true);
            x_backbone_blocks_17 = dr_x1c2.ops.permuteOutputVar(x_backbone_blocks_17, [3 4 2 1], 4);

            x_backbone_blocks_17 = dlarray(single(x_backbone_blocks_17), 'SSCB');
        end

        function [x_backbone_blocks_17, x_backbone_blocks_17NumDims1005] = ReduceMeanGraph1003(this, x_backbone_blocks_12, x_backbone_blocks_12NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1004, x_backbone_blocks_12NumDims);
            xMean = mean(x_backbone_blocks_12, dims);
            x_backbone_blocks_17 = xMean;
            x_backbone_blocks_17NumDims = x_backbone_blocks_12NumDims;

            % Set graph output arguments
            x_backbone_blocks_17NumDims1005 = x_backbone_blocks_17NumDims;

        end

    end

end