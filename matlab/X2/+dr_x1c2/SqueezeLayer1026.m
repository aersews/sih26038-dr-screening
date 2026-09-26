classdef SqueezeLayer1026 < nnet.layer.Layer & nnet.layer.Formattable
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
            name = 'dr_x1c2.coder.SqueezeLayer1026';
        end
    end


    methods
        function this = SqueezeLayer1026(name)
            this.Name = name;
            this.OutputNames = {'ref_logit'};
        end

        function [ref_logit] = predict(this, x_ref_Gemm_output_0)
            if isdlarray(x_ref_Gemm_output_0)
                x_ref_Gemm_output_0 = stripdims(x_ref_Gemm_output_0);
            end
            x_ref_Gemm_output_0NumDims = 2;
            x_ref_Gemm_output_0 = dr_x1c2.ops.permuteInputVar(x_ref_Gemm_output_0, [2 1], 2);

            [ref_logit, ref_logitNumDims] = SqueezeGraph1078(this, x_ref_Gemm_output_0, x_ref_Gemm_output_0NumDims, false);
            ref_logit = dr_x1c2.ops.permuteOutputVar(ref_logit, ['as-is'], 1);

            ref_logit = dlarray(single(ref_logit), repmat('U', 1, max(2, ref_logitNumDims)));
        end

        function [ref_logit] = forward(this, x_ref_Gemm_output_0)
            if isdlarray(x_ref_Gemm_output_0)
                x_ref_Gemm_output_0 = stripdims(x_ref_Gemm_output_0);
            end
            x_ref_Gemm_output_0NumDims = 2;
            x_ref_Gemm_output_0 = dr_x1c2.ops.permuteInputVar(x_ref_Gemm_output_0, [2 1], 2);

            [ref_logit, ref_logitNumDims] = SqueezeGraph1078(this, x_ref_Gemm_output_0, x_ref_Gemm_output_0NumDims, true);
            ref_logit = dr_x1c2.ops.permuteOutputVar(ref_logit, ['as-is'], 1);

            ref_logit = dlarray(single(ref_logit), repmat('U', 1, max(2, ref_logitNumDims)));
        end

        function [ref_logit, ref_logitNumDims1079] = SqueezeGraph1078(this, x_ref_Gemm_output_0, x_ref_Gemm_output_0NumDims, Training)

            % Execute the operators:
            % Squeeze:
            [ref_logit, ref_logitNumDims] = dr_x1c2.ops.onnxSqueeze(x_ref_Gemm_output_0, this.Vars.x_Constant_output_0, x_ref_Gemm_output_0NumDims);

            % Set graph output arguments
            ref_logitNumDims1079 = ref_logitNumDims;

        end

    end

end