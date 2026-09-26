classdef ReduceMeanLayer1022 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.ReduceMeanLayer1022';
        end
    end


    methods
        function this = ReduceMeanLayer1022(name)
            this.Name = name;
            this.OutputNames = {'x_backbone_block_327'};
        end

        function [x_backbone_block_327] = predict(this, x_backbone_block_321)
            if isdlarray(x_backbone_block_321)
                x_backbone_block_321 = stripdims(x_backbone_block_321);
            end
            x_backbone_block_321NumDims = 4;
            x_backbone_block_321 = dr_x1c2.ops.permuteInputVar(x_backbone_block_321, [4 3 1 2], 4);

            [x_backbone_block_327, x_backbone_block_327NumDims] = ReduceMeanGraph1066(this, x_backbone_block_321, x_backbone_block_321NumDims, false);
            x_backbone_block_327 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_327, [3 4 2 1], 4);

            x_backbone_block_327 = dlarray(single(x_backbone_block_327), 'SSCB');
        end

        function [x_backbone_block_327] = forward(this, x_backbone_block_321)
            if isdlarray(x_backbone_block_321)
                x_backbone_block_321 = stripdims(x_backbone_block_321);
            end
            x_backbone_block_321NumDims = 4;
            x_backbone_block_321 = dr_x1c2.ops.permuteInputVar(x_backbone_block_321, [4 3 1 2], 4);

            [x_backbone_block_327, x_backbone_block_327NumDims] = ReduceMeanGraph1066(this, x_backbone_block_321, x_backbone_block_321NumDims, true);
            x_backbone_block_327 = dr_x1c2.ops.permuteOutputVar(x_backbone_block_327, [3 4 2 1], 4);

            x_backbone_block_327 = dlarray(single(x_backbone_block_327), 'SSCB');
        end

        function [x_backbone_block_327, x_backbone_block_327NumDims1068] = ReduceMeanGraph1066(this, x_backbone_block_321, x_backbone_block_321NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_x1c2.ops.prepareReduceArgs(this.Vars.ReduceMeanAxes1067, x_backbone_block_321NumDims);
            xMean = mean(x_backbone_block_321, dims);
            x_backbone_block_327 = xMean;
            x_backbone_block_327NumDims = x_backbone_block_321NumDims;

            % Set graph output arguments
            x_backbone_block_327NumDims1068 = x_backbone_block_327NumDims;

        end

    end

end