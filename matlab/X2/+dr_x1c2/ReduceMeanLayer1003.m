classdef ReduceMeanLayer1003 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1003';
        end
    end


    methods
        function this = ReduceMeanLayer1003(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_blocks_46'};
        end

        function [x_backbone_blocks_46] = predict(this, x_backbone_blocks_40)
            if isdlarray(x_backbone_blocks_40)
                x_backbone_blocks_40 = stripdims(x_backbone_blocks_40);
            end
            x_backbone_blocks_40NumDims = 4;
            x_backbone_blocks_40 = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_40, [4 3 1 2], 4);

            [x_backbone_blocks_46, x_backbone_blocks_46NumDims] = ReduceMeanGraph1009(this, x_backbone_blocks_40, x_backbone_blocks_40NumDims, false);
            x_backbone_blocks_46 = dr_x1c2.ops.permuteOutputVar(x_backbone_blocks_46, [3 4 2 1], 4);

            x_backbone_blocks_46 = dlarray(single(x_backbone_blocks_46), 'SSCB');
        end

        function [x_backbone_blocks_46] = forward(this, x_backbone_blocks_40)
            if isdlarray(x_backbone_blocks_40)
                x_backbone_blocks_40 = stripdims(x_backbone_blocks_40);
            end
            x_backbone_blocks_40NumDims = 4;
            x_backbone_blocks_40 = dr_x1c2.ops.permuteInputVar(x_backbone_blocks_40, [4 3 1 2], 4);

            [x_backbone_blocks_46, x_backbone_blocks_46NumDims] = ReduceMeanGraph1009(this, x_backbone_blocks_40, x_backbone_blocks_40NumDims, true);
            x_backbone_blocks_46 = dr_x1c2.ops.permuteOutputVar(x_backbone_blocks_46, [3 4 2 1], 4);

            x_backbone_blocks_46 = dlarray(single(x_backbone_blocks_46), 'SSCB');
        end

        function [x_backbone_blocks_46, x_backbone_blocks_46NumDims1011] = ReduceMeanGraph1009(this, x_backbone_blocks_40, x_backbone_blocks_40NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1010, x_backbone_blocks_40NumDims);
            xMean = mean(x_backbone_blocks_40, dims);
            x_backbone_blocks_46 = xMean;
            x_backbone_blocks_46NumDims = x_backbone_blocks_40NumDims;

            % Set graph output arguments
            x_backbone_blocks_46NumDims1011 = x_backbone_blocks_46NumDims;

        end

    end

end