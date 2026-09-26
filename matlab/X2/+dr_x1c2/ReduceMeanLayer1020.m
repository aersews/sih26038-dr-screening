classdef ReduceMeanLayer1020 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1020';
        end
    end


    methods
        function this = ReduceMeanLayer1020(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_297'};
        end

        function [x_backbone_block_297] = predict(this, x_backbone_block_291)
            if isdlarray(x_backbone_block_291)
                x_backbone_block_291 = stripdims(x_backbone_block_291);
            end
            x_backbone_block_291NumDims = 4;
            x_backbone_block_291 = dr_x1c2.ops.permuteInputVar(x_backbone_block_291, [4 3 1 2], 4);

            [x_backbone_block_297, x_backbone_block_297NumDims] = ReduceMeanGraph1060(this, x_backbone_block_291, x_backbone_block_291NumDims, false);
            x_backbone_block_297 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_297, [3 4 2 1], 4);

            x_backbone_block_297 = dlarray(single(x_backbone_block_297), 'SSCB');
        end

        function [x_backbone_block_297] = forward(this, x_backbone_block_291)
            if isdlarray(x_backbone_block_291)
                x_backbone_block_291 = stripdims(x_backbone_block_291);
            end
            x_backbone_block_291NumDims = 4;
            x_backbone_block_291 = dr_x1c2.ops.permuteInputVar(x_backbone_block_291, [4 3 1 2], 4);

            [x_backbone_block_297, x_backbone_block_297NumDims] = ReduceMeanGraph1060(this, x_backbone_block_291, x_backbone_block_291NumDims, true);
            x_backbone_block_297 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_297, [3 4 2 1], 4);

            x_backbone_block_297 = dlarray(single(x_backbone_block_297), 'SSCB');
        end

        function [x_backbone_block_297, x_backbone_block_297NumDims1062] = ReduceMeanGraph1060(this, x_backbone_block_291, x_backbone_block_291NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1061, x_backbone_block_291NumDims);
            xMean = mean(x_backbone_block_291, dims);
            x_backbone_block_297 = xMean;
            x_backbone_block_297NumDims = x_backbone_block_291NumDims;

            % Set graph output arguments
            x_backbone_block_297NumDims1062 = x_backbone_block_297NumDims;

        end

    end

end