classdef ReduceMeanLayer1013 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1013';
        end
    end


    methods
        function this = ReduceMeanLayer1013(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_193'};
        end

        function [x_backbone_block_193] = predict(this, x_backbone_block_187)
            if isdlarray(x_backbone_block_187)
                x_backbone_block_187 = stripdims(x_backbone_block_187);
            end
            x_backbone_block_187NumDims = 4;
            x_backbone_block_187 = dr_x1c2.ops.permuteInputVar(x_backbone_block_187, [4 3 1 2], 4);

            [x_backbone_block_193, x_backbone_block_193NumDims] = ReduceMeanGraph1039(this, x_backbone_block_187, x_backbone_block_187NumDims, false);
            x_backbone_block_193 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_193, [3 4 2 1], 4);

            x_backbone_block_193 = dlarray(single(x_backbone_block_193), 'SSCB');
        end

        function [x_backbone_block_193] = forward(this, x_backbone_block_187)
            if isdlarray(x_backbone_block_187)
                x_backbone_block_187 = stripdims(x_backbone_block_187);
            end
            x_backbone_block_187NumDims = 4;
            x_backbone_block_187 = dr_x1c2.ops.permuteInputVar(x_backbone_block_187, [4 3 1 2], 4);

            [x_backbone_block_193, x_backbone_block_193NumDims] = ReduceMeanGraph1039(this, x_backbone_block_187, x_backbone_block_187NumDims, true);
            x_backbone_block_193 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_193, [3 4 2 1], 4);

            x_backbone_block_193 = dlarray(single(x_backbone_block_193), 'SSCB');
        end

        function [x_backbone_block_193, x_backbone_block_193NumDims1041] = ReduceMeanGraph1039(this, x_backbone_block_187, x_backbone_block_187NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1040, x_backbone_block_187NumDims);
            xMean = mean(x_backbone_block_187, dims);
            x_backbone_block_193 = xMean;
            x_backbone_block_193NumDims = x_backbone_block_187NumDims;

            % Set graph output arguments
            x_backbone_block_193NumDims1041 = x_backbone_block_193NumDims;

        end

    end

end