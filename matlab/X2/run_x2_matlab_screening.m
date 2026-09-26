function result = run_x2_matlab_screening()
%run_x2_matlab_screening  MATLAB-side workflow-aware DR screening: Feeds the
%   same reference tensors the Python side used through the imported ONNX
%   network, computes T=1.25 softmax/confidence/uncertainty/ref_prob, and
%   applies the EXACT frozen deterministic routing rules (x2_common.workflow_route)
%   to verify that the MATLAB implementation reproduces the Python decisions.

ROOT = fileparts(mfilename('fullpath'));
result = struct(); result.test='x2_matlab_screening'; result.execution_status='REQUIRES_EXTERNAL_EXECUTION';
result.pass = false;

try
    net = importNetworkFromONNX(fullfile(ROOT,'dr_x1c2.onnx'));
    meta = jsondecode(fileread(fullfile(ROOT,'data','ref','matlab_parity_reference_v9_x2.json')));

    % Frozen policy constants (mirrors x2_common.py)
    T = 1.25; Q_RECAPTURE = 0.35; Q_USABLE = 0.60; CONF_HIGH = 0.90; UNC_HIGH = 0.50;
    % Quality score must come from the (Python) heuristic quality gate; pass per case.
    quality_by_id = containers.Map(...
        {'0083ee8054ee','0304bedad8fe','9b4fc15df3c8','054b1b305160'},...
        {0.6783, 0.7184, 0.4290, 0.7275});

    cases = {};
    for k = 1:numel(meta.ref)
        ref = meta.ref(k);
        S = load(fullfile(ROOT,'data','ref',ref.mat));
        x = double(S.(ref.input_var)); xHCWB = permute(x,[3 4 2 1]);
        [ocls, ~] = predict(net, dlarray(single(xHCWB),'SSCB'));
        cls = double(extractdata(ocls));                 % 5x1
        z = cls/ T;
        p = softmax(z);                                    % 5x1
        confidence = max(p);
        uncertainty = -sum(p.*log(max(p,1e-9)))/log(numel(p));
        ref_prob = sum(p(3:5));                            % classes 2,3,4 = referable
        pred = find(p==max(p),1)-1;                        % 0-based argmax
        q = quality_by_id(ref.id);

        quality_bucket = 'USABLE_FOR_MODEL';
        if q < Q_RECAPTURE, quality_bucket = 'RECAPTURE_CANDIDATE';
        elseif q < Q_USABLE, quality_bucket = 'LOW_QUALITY_REVIEW'; end

        % ---- exact decision order of x2_common.workflow_route ----
        route = 'SCREENING_OUTPUT'; reason = '';
        if q < Q_RECAPTURE
            route = 'RECAPTURE'; reason = sprintf('low quality %.3f < 0.35', q);
        elseif pred >= 2
            route = 'REFER'; reason = sprintf('referable (argmax=%d); ref_prob %.3f', pred, ref_prob);
        elseif pred == 1
            route = 'HUMAN_REVIEW'; reason = 'predicted Mild NPDR (argmax=1) on referable boundary';
        elseif q < Q_USABLE
            route = 'HUMAN_REVIEW'; reason = sprintf('quality %.3f in [0.35,0.60)', q);
        elseif confidence < CONF_HIGH || uncertainty > UNC_HIGH
            route = 'HUMAN_REVIEW'; reason = sprintf('low confidence %.3f / high uncertainty %.3f', confidence, uncertainty);
        else
            route = 'SCREENING_OUTPUT'; reason = sprintf('non-referable + usable + confident (conf %.3f)', confidence);
        end

        cases{end+1} = struct('id', ref.id, 'true_label', ref.true_label, ...
            'argmax_severity', pred, 'confidence', confidence, 'uncertainty', uncertainty, ...
            'ref_prob', ref_prob, 'quality', q, 'quality_bucket', quality_bucket, ...
            'route', route, 'route_reason', reason);
    end

    % Expected routes (Python-side frozen policy, from X2-E reports + policy analysis)
    expect = containers.Map(...
        {'0083ee8054ee','0304bedad8fe','9b4fc15df3c8','054b1b305160'},...
        {'REFER','SCREENING_OUTPUT','HUMAN_REVIEW','HUMAN_REVIEW'});
    ok = true;
    for i = 1:numel(cases)
        cases{i}.route_matches_python = strcmp(cases{i}.route, expect(cases{i}.id));
        ok = ok && cases{i}.route_matches_python;
    end
    result.execution_status='EXECUTED';
    result.matched_all_python_routes = ok;
    result.pass = ok;
    result.cases = cases;
    fprintf('MATLAB screening: routes match Python=%d\n', ok);
    for i=1:numel(cases), fprintf('  %s -> %s (conf %.3f unc %.3f ref %.3f q %.3f)\n', ...
        cases{i}.id, cases{i}.route, cases{i}.confidence, cases{i}.uncertainty, cases{i}.ref_prob, cases{i}.quality); end
catch ME
    result.execution_status='ERROR'; result.error=ME.message;
    fprintf('MATLAB SCREENING ERROR: %s\n', ME.message);
end
if ~exist(fullfile(ROOT,'results'),'dir'), mkdir(fullfile(ROOT,'results')); end
fid=fopen(fullfile(ROOT,'results','x2_f_matlab_screening.json'),'w','n','UTF-8');
fwrite(fid, jsonencode(result), 'char'); fclose(fid);
end

function p = softmax(z)
e = exp(z - max(z));
p = e ./ sum(e);
end