classdef ReduceMeanLayer1004 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1004';
        end
    end


    methods
        function this = ReduceMeanLayer1004(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_blocks_61'};
        end

        function [x_backbone_blocks_61] = predict(this, x_backbone_blocks_55)
            if isdlarray(x_backbone_blocks_55)
                x_backbone_blocks_55 = stripdims(x_backbone_blocks_55);
            end
            x_backbone_blocks_55NumDims = 4;
            x_backbone_blocks_55 = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_55, [4 3 1 2], 4);

            [x_backbone_blocks_61, x_backbone_blocks_61NumDims] = ReduceMeanGraph1012(this, x_backbone_blocks_55, x_backbone_blocks_55NumDims, false);
            x_backbone_blocks_61 = dr_x1c2.ops.permuteOutputVar(x_backbone_blocks_61, [3 4 2 1], 4);

            x_backbone_blocks_61 = dlarray(single(x_backbone_blocks_61), 'SSCB');
        end

        function [x_backbone_blocks_61] = forward(this, x_backbone_blocks_55)
            if isdlarray(x_backbone_blocks_55)
                x_backbone_blocks_55 = stripdims(x_backbone_blocks_55);
            end
            x_backbone_blocks_55NumDims = 4;
            x_backbone_blocks_55 = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_55, [4 3 1 2], 4);

            [x_backbone_blocks_61, x_backbone_blocks_61NumDims] = ReduceMeanGraph1012(this, x_backbone_blocks_55, x_backbone_blocks_55NumDims, true);
            x_backbone_blocks_61 = dr_x1c2.ops.permuteOutputVar(x_backbone_blocks_61, [3 4 2 1], 4);

            x_backbone_blocks_61 = dlarray(single(x_backbone_blocks_61), 'SSCB');
        end

        function [x_backbone_blocks_61, x_backbone_blocks_61NumDims1014] = ReduceMeanGraph1012(this, x_backbone_blocks_55, x_backbone_blocks_55NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1013, x_backbone_blocks_55NumDims);
            xMean = mean(x_backbone_blocks_55, dims);
            x_backbone_blocks_61 = xMean;
            x_backbone_blocks_61NumDims = x_backbone_blocks_55NumDims;

            % Set graph output arguments
            x_backbone_blocks_61NumDims1014 = x_backbone_blocks_61NumDims;

        end

    end

end