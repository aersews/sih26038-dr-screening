classdef ReduceMeanLayer1024 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1024';
        end
    end


    methods
        function this = ReduceMeanLayer1024(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_356'};
        end

        function [x_backbone_block_356] = predict(this, x_backbone_block_350)
            if isdlarray(x_backbone_block_350)
                x_backbone_block_350 = stripdims(x_backbone_block_350);
            end
            x_backbone_block_350NumDims = 4;
            x_backbone_block_350 = dr_x1c2.ops.permuteInputVar(x_backbone_block_350, [4 3 1 2], 4);

            [x_backbone_block_356, x_backbone_block_356NumDims] = ReduceMeanGraph1072(this, x_backbone_block_350, x_backbone_block_350NumDims, false);
            x_backbone_block_356 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_356, [3 4 2 1], 4);

            x_backbone_block_356 = dlarray(single(x_backbone_block_356), 'SSCB');
        end

        function [x_backbone_block_356] = forward(this, x_backbone_block_350)
            if isdlarray(x_backbone_block_350)
                x_backbone_block_350 = stripdims(x_backbone_block_350);
            end
            x_backbone_block_350NumDims = 4;
            x_backbone_block_350 = dr_x1c2.ops.permuteInputVar(x_backbone_block_350, [4 3 1 2], 4);

            [x_backbone_block_356, x_backbone_block_356NumDims] = ReduceMeanGraph1072(this, x_backbone_block_350, x_backbone_block_350NumDims, true);
            x_backbone_block_356 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_356, [3 4 2 1], 4);

            x_backbone_block_356 = dlarray(single(x_backbone_block_356), 'SSCB');
        end

        function [x_backbone_block_356, x_backbone_block_356NumDims1074] = ReduceMeanGraph1072(this, x_backbone_block_350, x_backbone_block_350NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1073, x_backbone_block_350NumDims);
            xMean = mean(x_backbone_block_350, dims);
            x_backbone_block_356 = xMean;
            x_backbone_block_356NumDims = x_backbone_block_350NumDims;

            % Set graph output arguments
            x_backbone_block_356NumDims1074 = x_backbone_block_356NumDims;

        end

    end

end