function result = run_x2_matlab_onnx_parity(ROOT)
%run_x2_matlab_onnx_parity  Phase F: import dr_x1c2.onnx into MATLAB, run the
%   exact Python tensors, compare cls/ref logits to the saved Python logits.
if nargin < 1, ROOT = fileparts(mfilename('fullpath')); end

result = struct();
result.test = 'x2_matlab_onnx_parity';
result.execution_status = 'REQUIRES_EXTERNAL_EXECUTION';
result.pass = false;
result.training_claim = 'PyTorch-trained X1C2 integrated into MATLAB via ONNX; NOT MATLAB-trained';
result.executed_at = datestr(now);

try
    assert(exist('importNetworkFromONNX','file')==2, 'importNetworkFromONNX not available');
    modelPath = fullfile(ROOT, 'dr_x1c2.onnx');
    assert(exist(modelPath,'file')==2, 'missing dr_x1c2.onnx');

    net = importNetworkFromONNX(modelPath);
    result.network_class = class(net);
    result.network_inputs = string();
    meta = jsondecode(fileread(fullfile(ROOT,'data','ref','matlab_parity_reference_v9_x2.json')));

    cases = {};
    for k = 1:numel(meta.ref)
        ref = meta.ref(k);
        S = load(fullfile(ROOT, 'data', 'ref', ref.mat));
        x = double(S.(ref.input_var));           % 1x3x300x300 NCHW, python float32
        xHCWB = permute(x, [3 4 2 1]);           % H W C B for MATLAB dlnetwork
        python_cls = double(S.(ref.cls_var));    % 1x5
        python_ref = double(S.(ref.ref_var));    % 1x1

        dlx = dlarray(single(xHCWB), 'SSCB');
        [ocls, oref] = predict(net, dlx);   % multi-output dlnetwork
        mcls = single(extractdata(ocls));   % Cx1x1xB
        mcls = permute(mcls, [1 4 3 2]);
        mref = single(extractdata(oref));   % tx1x1xB
        if isscalar(mref)
            mref = mref(:);
        else
            mref = permute(mref, [1 4 3 2]);
            mref = mref(:);
        end

        maxDiffCls = max(abs(mcls(:) - python_cls(:)));
        maxDiffRef = max(abs(mref(:) - python_ref(:)));
        torchPred = maxloc(python_cls);
        matPred = maxloc(mcls);
        cases{end+1} = struct( ...
            'id', ref.id, 'true_label', ref.true_label, ...
            'matlab_cls_logits', mcls(:), 'python_cls_logits', python_cls(:), ...
            'matlab_ref_logit', mref, 'python_ref_logit', python_ref(:), ...
            'max_abs_diff_cls', maxDiffCls, 'max_abs_diff_ref', maxDiffRef, ...
            'matlab_pred_severity', matPred, 'python_pred_severity', torchPred, ...
            'semantic_agreement', matPred==torchPred);
    end

    result.execution_status = 'EXECUTED';
    result.cases = cases;
    result.max_abs_diff_cls_overall = max(cellfun(@(c) c.max_abs_diff_cls, cases));
    result.max_abs_diff_ref_overall = max(cellfun(@(c) c.max_abs_diff_ref, cases));
    result.tolerance = 1e-3;
    result.pass = result.max_abs_diff_cls_overall < result.tolerance && ...
                  result.max_abs_diff_ref_overall < result.tolerance && ...
                  all(cellfun(@(c) c.semantic_agreement, cases));

    fprintf('MATLAB ONNX parity: max cls diff %.3e, max ref diff %.3e, pass=%d\n', ...
        result.max_abs_diff_cls_overall, result.max_abs_diff_ref_overall, result.pass);
catch ME
    result.execution_status = 'ERROR';
    result.error = ME.message;
    fprintf('MATLAB PARITY ERROR: %s\n', ME.message);
end

if ~exist(fullfile(ROOT,'results'),'dir'), mkdir(fullfile(ROOT,'results')); end
savejson(fullfile(ROOT,'results','x2_f_matlab_onnx_parity.json'), result);
end

function p = maxloc(v)
[~, p] = max(v(:));
end

function savejson(fn, s)
txt = jsonencode(s);
fid = fopen(fn,'w','n','UTF-8'); fwrite(fid, txt, 'char'); fclose(fid);
end