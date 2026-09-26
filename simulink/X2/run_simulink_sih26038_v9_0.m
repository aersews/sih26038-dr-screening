function result = run_simulink_sih26038_v9_0(ROOT)
%run_simulink_sih26038_v9_0  Phase G: build + execute the X2 workflow-aware
%  Simulink queue model across LOW / BASE / HIGH load scenarios, then derive
%  the annualized 100k planning check (demand vs human-attention capacity).
%  Writes X2_SIMULINK_SCENARIOS.csv and results JSON under ROOT/results.

if nargin < 1, ROOT = fileparts(mfilename('fullpath')); end

result = struct();
result.test = 'phaseG_simulink_workflow_v9_0';
result.execution_status = 'REQUIRES_EXTERNAL_EXECUTION';
result.pass = false;
rows = struct([]);

if ~exist('simulink', 'file')
    result.reason = 'Simulink not installed on this host.';
    retjson(fullfile(ROOT,'results','simulink_result_v9_0.json'), result);
    return;
end

model = 'sih26038_screening_workflow_v9_0';
result.model = model;
result.scenarios = [];

try
    addpath(genpath(ROOT));
    bdclose('all');

    scenarios = {'LOW','BASE','HIGH'};
    for s = 1:numel(scenarios)
        sc = scenarios{s};
        build_sih26038_simulink_v9_0(sc);
        if ~bdIsLoaded(model), load_system(model); end
        set_param(model,'StopTime','86400');

        fprintf('Simulating %s (scenario=%s)...\n', model, sc);
        simOut = sim(model, 'ReturnWorkspaceOutputs','on');

        qm  = double(simOut.get('Mid_queue_log').Data(:));
        thm = double(simOut.get('Mid_throughput_log').Data(:));
        qr  = double(simOut.get('Refer_queue_log').Data(:));
        thr = double(simOut.get('Refer_throughput_log').Data(:));
        qc  = double(simOut.get('Recapture_queue_log').Data(:));
        thc = double(simOut.get('Recapture_throughput_log').Data(:));
        au  = double(simOut.get('auto_screen_log').Data(:));
        t   = double(simOut.get('Mid_queue_log').Time(:));
        steps = numel(t);

        acqu  = evalin('base','acquisition_rate');
        fAuto = evalin('base','auto_screen_fraction');
        fMid  = evalin('base','human_review_fraction');
        fRef  = evalin('base','refer_fraction');
        fRecap= evalin('base','recapture_fraction');
        midPool  = evalin('base','mid_pool');
        midCap   = evalin('base','mid_capacity');
        refPool  = evalin('base','refer_pool');
        refCap   = evalin('base','refer_capacity');
        annualTarget = evalin('base','annual_target');
        workDays = evalin('base','working_days');
        hrsPerDay= evalin('base','hours_per_day');

        human_queue    = qm + qr + qc;
        human_through  = thm + thr + thc;
        arrivals_total = acqu * steps * 60/3600;
        auto_total     = sum(au);

        % 24h immediately: is the human queue drained by sim end?
        drained = abs(human_queue(end)) < 1e-9;

        % annualized demand model: district target X images/year
        mean_rate_hr = annualTarget / (workDays * hrsPerDay);         % images/hr avg
        human_cap_hr = midPool*midCap + refPool*refCap + eval_in_base('recapture_service');
        demand_human_hr = mean_rate_hr * (fMid + fRef + fRecap);
        demand_auto_hr  = mean_rate_hr * fAuto;
        margin_hr = human_cap_hr - demand_human_hr;                    % excess capacity/hr
        max_vol_yr = human_cap_hr / max(fMid+fRef+fRecap, 1e-9) * workDays*hrsPerDay;

        rec = struct( ...
            'scenario', sc, ...
            'acquisition_rate_hr', acqu, ...
            'auto_screen_fraction', fAuto, 'human_review_fraction', fMid, ...
            'refer_fraction', fRef, 'recapture_fraction', fRecap, ...
            'steps', steps, 'simulation_hours', 24, 'step_seconds', 60, ...
            'total_arrivals', arrivals_total, ...
            'total_auto_screened', auto_total, ...
            'total_mid_reviewed', sum(thm), 'total_referred_and_reviewed', sum(thr), ...
            'total_recaptured', sum(thc), ...
            'total_human_attention', sum(human_through), ...
            'mean_human_queue', mean(human_queue), 'max_human_queue', max(human_queue), ...
            'p95_human_queue', prctile_manual(human_queue,95), 'end_human_queue', human_queue(end), ...
            'queue_drained_at_24h', drained, ...
            'utilization_vs_capacity', sum(human_through)/(24*(midPool*midCap+refPool*refCap+eval_in_base('recapture_service'))), ...
            'annualized_100k_mean_rate_hr', mean_rate_hr, ...
            'annualized_demand_human_hr', demand_human_hr, ...
            'annualized_demand_auto_hr', demand_auto_hr, ...
            'annualized_human_capacity_hr', human_cap_hr, ...
            'annualized_hr_margin', margin_hr, ...
            'annualized_max_sustainable_yr', max_vol_yr, ...
            'annualized_100k_feasible', margin_hr >= 0);

        result.scenarios = [result.scenarios; rec];
        if isempty(rows), rows = rec; else, rows(end+1) = rec; end
        fprintf('  %s: arrivals=%.2f auto=%.2f human=%.2f meanQ=%.3f drained=%d feasible=%d\n', ...
            sc, arrivals_total, auto_total, sum(human_through), mean(human_queue), drained, rec.annualized_100k_feasible);
    end
    bdclose('all');
    result.execution_status = 'EXECUTED';
    result.pass = true;

    % write CSV
    S = struct2table(rows);
    csvpath = fullfile(ROOT,'results','X2_SIMULINK_SCENARIOS.csv');
    writetable(S, csvpath);
    fprintf('Wrote %s\n', csvpath);
catch ME
    result.execution_status = 'ERROR';
    result.error = ME.message;
    fprintf('SIMULINK WORKFLOW ERROR: %s\n', ME.message);
end
retjson(fullfile(ROOT,'results','simulink_result_v9_0.json'), result);
fprintf('Done. evidence at results/simulink_result_v9_0.json\n');
end

function retjson(fn, r)
if ~exist(fileparts(fn),'dir'), mkdir(fileparts(fn)); end
fid = fopen(fn,'w','n','UTF-8'); fwrite(fid, jsonencode(r), 'char'); fclose(fid);
end

function v = eval_in_base(e)
v = evalin('base', e);
end

function p = prctile_manual(x, pct)
xs = sort(x(:)); n = numel(xs);
p = xs(min(n, max(1, ceil(pct/100*n))));
end