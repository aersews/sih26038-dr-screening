classdef SqueezeLayer1026 < nnet.layer.Layer & nnet.layer.Formattable
    % A custom layer auto-generated while importing an ONNX network.
    %#codegen

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
        % Specify the properties of the class that will not be modified
        % after the first assignment.
        function p = matlabCodegenNontunableProperties(~)
            p = {
                % Constants, i.e., Vars, NumDims and all learnables and states
                'Vars'
                'NumDims'
                };
        end
    end


    methods(Static, Hidden)
        % Instantiate a codegenable layer instance from a MATLAB layer instance
        function this_cg = matlabCodegenToRedirected(mlInstance)
            this_cg = dr_x1c2.coder.SqueezeLayer1026(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_x1c2.SqueezeLayer1026(cgInstance.Name);
            if isstruct(cgInstance.Vars)
                names = fieldnames(cgInstance.Vars);
                for i=1:numel(names)
                    fieldname = names{i};
                    this_ml.Vars.(fieldname) = dlarray(cgInstance.Vars.(fieldname));
                end
            else
                this_ml.Vars = [];
            end
            this_ml.NumDims = cgInstance.NumDims;
        end
    end

    methods
        function this = SqueezeLayer1026(mlInstance)
            this.Name = mlInstance.Name;
            this.OutputNames = {'ref_logit'};
            if isstruct(mlInstance.Vars)
                names = fieldnames(mlInstance.Vars);
                for i=1:numel(names)
                    fieldname = names{i};
                    this.Vars.(fieldname) = dr_x1c2.coder.ops.extractIfDlarray(mlInstance.Vars.(fieldname));
                end
            else
                this.Vars = [];
            end

            this.NumDims = mlInstance.NumDims;
        end

        function [ref_logit] = predict(this, x_ref_Gemm_output_0__)
            if isdlarray(x_ref_Gemm_output_0__)
                x_ref_Gemm_output_0_ = stripdims(x_ref_Gemm_output_0__);
            else
                x_ref_Gemm_output_0_ = x_ref_Gemm_output_0__;
            end
            x_ref_Gemm_output_0NumDims = 2;
            x_ref_Gemm_output_0 = dr_x1c2.coder.ops.permuteInputVar(x_ref_Gemm_output_0_, [2 1], 2);

            [ref_logit__, ref_logitNumDims__] = SqueezeGraph1078(this, x_ref_Gemm_output_0, x_ref_Gemm_output_0NumDims, false);
            ref_logit_ = dr_x1c2.coder.ops.permuteOutputVar(ref_logit__, ['as-is'], 1);

            ref_logit = dlarray(single(ref_logit_), repmat('U', 1, max(2, coder.const(ref_logitNumDims__))));
        end

        function [ref_logit, ref_logitNumDims1079] = SqueezeGraph1078(this, x_ref_Gemm_output_0, x_ref_Gemm_output_0NumDims, Training)

            % Execute the operators:
            % Squeeze:
            [ref_logit, ref_logitNumDims] = dr_x1c2.coder.ops.onnxSqueeze(x_ref_Gemm_output_0, this.Vars.x_Constant_output_0, coder.const(x_ref_Gemm_output_0NumDims));

            % Set graph output arguments
            ref_logitNumDims1079 = coder.const(ref_logitNumDims);

        end

    end

end