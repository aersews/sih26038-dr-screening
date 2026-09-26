classdef ReduceMeanLayer1014 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1014';
        end
    end


    methods
        function this = ReduceMeanLayer1014(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_208'};
        end

        function [x_backbone_block_208] = predict(this, x_backbone_block_202)
            if isdlarray(x_backbone_block_202)
                x_backbone_block_202 = stripdims(x_backbone_block_202);
            end
            x_backbone_block_202NumDims = 4;
            x_backbone_block_202 = dr_x1c2.ops.permuteInputVar(x_backbone_block_202, [4 3 1 2], 4);

            [x_backbone_block_208, x_backbone_block_208NumDims] = ReduceMeanGraph1042(this, x_backbone_block_202, x_backbone_block_202NumDims, false);
            x_backbone_block_208 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_208, [3 4 2 1], 4);

            x_backbone_block_208 = dlarray(single(x_backbone_block_208), 'SSCB');
        end

        function [x_backbone_block_208] = forward(this, x_backbone_block_202)
            if isdlarray(x_backbone_block_202)
                x_backbone_block_202 = stripdims(x_backbone_block_202);
            end
            x_backbone_block_202NumDims = 4;
            x_backbone_block_202 = dr_x1c2.ops.permuteInputVar(x_backbone_block_202, [4 3 1 2], 4);

            [x_backbone_block_208, x_backbone_block_208NumDims] = ReduceMeanGraph1042(this, x_backbone_block_202, x_backbone_block_202NumDims, true);
            x_backbone_block_208 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_208, [3 4 2 1], 4);

            x_backbone_block_208 = dlarray(single(x_backbone_block_208), 'SSCB');
        end

        function [x_backbone_block_208, x_backbone_block_208NumDims1044] = ReduceMeanGraph1042(this, x_backbone_block_202, x_backbone_block_202NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1043, x_backbone_block_202NumDims);
            xMean = mean(x_backbone_block_202, dims);
            x_backbone_block_208 = xMean;
            x_backbone_block_208NumDims = x_backbone_block_202NumDims;

            % Set graph output arguments
            x_backbone_block_208NumDims1044 = x_backbone_block_208NumDims;

        end

    end

end