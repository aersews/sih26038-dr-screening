classdef ReduceMeanLayer1016 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1016';
        end
    end


    methods
        function this = ReduceMeanLayer1016(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_238'};
        end

        function [x_backbone_block_238] = predict(this, x_backbone_block_232)
            if isdlarray(x_backbone_block_232)
                x_backbone_block_232 = stripdims(x_backbone_block_232);
            end
            x_backbone_block_232NumDims = 4;
            x_backbone_block_232 = dr_x1c2.ops.permuteInputVar(x_backbone_block_232, [4 3 1 2], 4);

            [x_backbone_block_238, x_backbone_block_238NumDims] = ReduceMeanGraph1048(this, x_backbone_block_232, x_backbone_block_232NumDims, false);
            x_backbone_block_238 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_238, [3 4 2 1], 4);

            x_backbone_block_238 = dlarray(single(x_backbone_block_238), 'SSCB');
        end

        function [x_backbone_block_238] = forward(this, x_backbone_block_232)
            if isdlarray(x_backbone_block_232)
                x_backbone_block_232 = stripdims(x_backbone_block_232);
            end
            x_backbone_block_232NumDims = 4;
            x_backbone_block_232 = dr_x1c2.ops.permuteInputVar(x_backbone_block_232, [4 3 1 2], 4);

            [x_backbone_block_238, x_backbone_block_238NumDims] = ReduceMeanGraph1048(this, x_backbone_block_232, x_backbone_block_232NumDims, true);
            x_backbone_block_238 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_238, [3 4 2 1], 4);

            x_backbone_block_238 = dlarray(single(x_backbone_block_238), 'SSCB');
        end

        function [x_backbone_block_238, x_backbone_block_238NumDims1050] = ReduceMeanGraph1048(this, x_backbone_block_232, x_backbone_block_232NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1049, x_backbone_block_232NumDims);
            xMean = mean(x_backbone_block_232, dims);
            x_backbone_block_238 = xMean;
            x_backbone_block_238NumDims = x_backbone_block_232NumDims;

            % Set graph output arguments
            x_backbone_block_238NumDims1050 = x_backbone_block_238NumDims;

        end

    end

end