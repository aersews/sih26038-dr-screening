classdef ReduceMeanLayer1015 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1015';
        end
    end


    methods
        function this = ReduceMeanLayer1015(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_223'};
        end

        function [x_backbone_block_223] = predict(this, x_backbone_block_217)
            if isdlarray(x_backbone_block_217)
                x_backbone_block_217 = stripdims(x_backbone_block_217);
            end
            x_backbone_block_217NumDims = 4;
            x_backbone_block_217 = dr_x1c2.ops.permuteInputVar(x_backbone_block_217, [4 3 1 2], 4);

            [x_backbone_block_223, x_backbone_block_223NumDims] = ReduceMeanGraph1045(this, x_backbone_block_217, x_backbone_block_217NumDims, false);
            x_backbone_block_223 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_223, [3 4 2 1], 4);

            x_backbone_block_223 = dlarray(single(x_backbone_block_223), 'SSCB');
        end

        function [x_backbone_block_223] = forward(this, x_backbone_block_217)
            if isdlarray(x_backbone_block_217)
                x_backbone_block_217 = stripdims(x_backbone_block_217);
            end
            x_backbone_block_217NumDims = 4;
            x_backbone_block_217 = dr_x1c2.ops.permuteInputVar(x_backbone_block_217, [4 3 1 2], 4);

            [x_backbone_block_223, x_backbone_block_223NumDims] = ReduceMeanGraph1045(this, x_backbone_block_217, x_backbone_block_217NumDims, true);
            x_backbone_block_223 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_223, [3 4 2 1], 4);

            x_backbone_block_223 = dlarray(single(x_backbone_block_223), 'SSCB');
        end

        function [x_backbone_block_223, x_backbone_block_223NumDims1047] = ReduceMeanGraph1045(this, x_backbone_block_217, x_backbone_block_217NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1046, x_backbone_block_217NumDims);
            xMean = mean(x_backbone_block_217, dims);
            x_backbone_block_223 = xMean;
            x_backbone_block_223NumDims = x_backbone_block_217NumDims;

            % Set graph output arguments
            x_backbone_block_223NumDims1047 = x_backbone_block_223NumDims;

        end

    end

end