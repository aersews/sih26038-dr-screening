classdef ReduceMeanLayer1018 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1018';
        end
    end


    methods
        function this = ReduceMeanLayer1018(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_267'};
        end

        function [x_backbone_block_267] = predict(this, x_backbone_block_261)
            if isdlarray(x_backbone_block_261)
                x_backbone_block_261 = stripdims(x_backbone_block_261);
            end
            x_backbone_block_261NumDims = 4;
            x_backbone_block_261 = dr_x1c2.ops.permuteInputVar(x_backbone_block_261, [4 3 1 2], 4);

            [x_backbone_block_267, x_backbone_block_267NumDims] = ReduceMeanGraph1054(this, x_backbone_block_261, x_backbone_block_261NumDims, false);
            x_backbone_block_267 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_267, [3 4 2 1], 4);

            x_backbone_block_267 = dlarray(single(x_backbone_block_267), 'SSCB');
        end

        function [x_backbone_block_267] = forward(this, x_backbone_block_261)
            if isdlarray(x_backbone_block_261)
                x_backbone_block_261 = stripdims(x_backbone_block_261);
            end
            x_backbone_block_261NumDims = 4;
            x_backbone_block_261 = dr_x1c2.ops.permuteInputVar(x_backbone_block_261, [4 3 1 2], 4);

            [x_backbone_block_267, x_backbone_block_267NumDims] = ReduceMeanGraph1054(this, x_backbone_block_261, x_backbone_block_261NumDims, true);
            x_backbone_block_267 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_267, [3 4 2 1], 4);

            x_backbone_block_267 = dlarray(single(x_backbone_block_267), 'SSCB');
        end

        function [x_backbone_block_267, x_backbone_block_267NumDims1056] = ReduceMeanGraph1054(this, x_backbone_block_261, x_backbone_block_261NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1055, x_backbone_block_261NumDims);
            xMean = mean(x_backbone_block_261, dims);
            x_backbone_block_267 = xMean;
            x_backbone_block_267NumDims = x_backbone_block_261NumDims;

            % Set graph output arguments
            x_backbone_block_267NumDims1056 = x_backbone_block_267NumDims;

        end

    end

end