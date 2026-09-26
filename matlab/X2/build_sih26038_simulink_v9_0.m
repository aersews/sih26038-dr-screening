function build_sih26038_simulink_v9_0(scenario)
%build_sih26038_simulink_v9_0  X2 workflow-aware screening queue model.
%  Operational workload simulator over a 1-minute-resolution discrete grid
%  (base Simulink, no SimEvents required), mirroring the v8.12 queue
%  topology but routing the acquisition stream through the X2 *workflow-aware*
%  pipeline fractions measured on the frozen validation set:
%
%    recapture_fraction  -> flagged for retake (quality gate FAIL, q<0.35)
%    auto_screen_fraction-> SCREENING_OUTPUT (no human resource)
%    human_review_fraction-> HUMAN_REVIEW (mid-level reviewer queue)
%    refer_fraction       -> REFER (ophthalmologist queue)
%
%  Fractions are read from the base workspace so each scenario can vary them.
%  This is a workload/capacity simulation, not a clinical simulator.

if nargin < 1, scenario = 'BASE'; end
model = 'sih26038_screening_workflow_v9_0';
if bdIsLoaded(model), close_system(model, 0); end
new_system(model);
open_system(model);

% ---- scenario parameters (assumptions; replace with measured deployment) ----
switch upper(scenario)
    case 'LOW'
        acquisition_rate  = 5.0;   % images/hour (rural clinic baseline)
    case 'HIGH'
        acquisition_rate  = 40.0;  % images/hour (urban campaign surge)
    otherwise
        acquisition_rate  = 10.0;  % district baseline
end
auto_screen_fraction = 0.3356;   % SCREENING_OUTPUT            (X2 val, frozen)
human_review_fraction = 0.2401;  % HUMAN_REVIEW                (X2 val, frozen)
refer_fraction        = 0.4243;  % REFER -> ophthalmologist    (X2 val, frozen)
recapture_fraction    = 0.0;     % quality FAIL, q<0.35 (0 on APTOS; deploy to measure)
mid_pool              = 4;       % parallel mid-level reviewer pools
mid_capacity          = 20;      % reviews/hour/pool
refer_pool            = 2;       % ophthalmologist pools
refer_capacity        = 15;      % reviews/hour/pool
recapture_service     = 5;       % retake-advice disposition / hour (deployment param)
bandwidth_mbps        = 20;      % uplink bandwidth
image_mb              = 2.5;     % compressed image size
annual_target         = 100000;  % district annual screening planning target
working_days          = 250;     % clinic-working days per year
hours_per_day         = 8;
simulation_hours      = 24;
step_seconds          = 60;

frac_sum = auto_screen_fraction + human_review_fraction + refer_fraction + recapture_fraction;
assert(abs(frac_sum - 1) < 1e-6, 'fractions must sum to 1');

assignin('base','scenario',scenario);
assignin('base','acquisition_rate',acquisition_rate);
assignin('base','auto_screen_fraction',auto_screen_fraction);
assignin('base','human_review_fraction',human_review_fraction);
assignin('base','refer_fraction',refer_fraction);
assignin('base','recapture_fraction',recapture_fraction);
assignin('base','mid_pool',mid_pool);
assignin('base','mid_capacity',mid_capacity);
assignin('base','refer_pool',refer_pool);
assignin('base','refer_capacity',refer_capacity);
assignin('base','recapture_service',recapture_service);
assignin('base','bandwidth_mbps',bandwidth_mbps);
assignin('base','image_mb',image_mb);
assignin('base','annual_target',annual_target);
assignin('base','working_days',working_days);
assignin('base','hours_per_day',hours_per_day);
assignin('base','simulation_hours',simulation_hours);
assignin('base','step_seconds',step_seconds);

% ------------------------- arrival + bandwidth gate -------------------------
add_block('simulink/Sources/Constant', [model '/Arrivals per step'], ...
    'Value','acquisition_rate*step_seconds/3600','Position',[30 70 210 110]);
add_block('simulink/Sources/Constant', [model '/Transfer capacity per step'], ...
    'Value','bandwidth_mbps*1e6*step_seconds/(image_mb*8e6)','Position',[30 290 220 330]);
add_block('simulink/Math Operations/MinMax', [model '/Bandwidth limited arrivals'], ...
    'Function','min','Inputs','2','Position',[260 280 350 320]);

% --------------------------- workflow routing gains --------------------------
% recapture flow = arrivals * recapture_fraction (quality gate FAIL)
add_block('simulink/Math Operations/Gain', [model '/Recapture flow per step'], ...
    'Gain','recapture_fraction','Position',[250 100 340 135]);
% graded = arrivals * (1 - recapture_fraction)
add_block('simulink/Math Operations/Gain', [model '/Graded arrivals'], ...
    'Gain','1-recapture_fraction','Position',[250 180 340 220]);
% auto-screen (no human resource)
add_block('simulink/Math Operations/Gain', [model '/Auto screen flow per step'], ...
    'Gain','auto_screen_fraction','Position',[400 240 490 280]);
add_block('simulink/Sinks/To Workspace', [model '/Auto-screen log'], ...
    'VariableName','auto_screen_log','SaveFormat','Timeseries','SampleTime','step_seconds','Position',[530 240 640 280]);
% mid-review arrivals
add_block('simulink/Math Operations/Gain', [model '/Mid arrivals per step'], ...
    'Gain','human_review_fraction','Position',[400 140 490 180]);
% referral arrivals
add_block('simulink/Math Operations/Gain', [model '/Refer arrivals per step'], ...
    'Gain','refer_fraction','Position',[400 40 490 80]);

% ------------------- recapture queue (quality-gate channel) ------------------
make_service_queue(model,'Recapture','Recapture flow per step','recapture_service*step_seconds/3600');
% ------------------- mid-level reviewer queue (HUMAN_REVIEW) -----------------
make_service_queue(model,'Mid','Mid arrivals per step','mid_pool*mid_capacity*step_seconds/3600');
% ------------------- ophthalmologist queue (REFER) ---------------------------
make_service_queue(model,'Refer','Refer arrivals per step','refer_pool*refer_capacity*step_seconds/3600');

% -------------------------------- wiring ------------------------------------
add_line(model,'Arrivals per step/1','Bandwidth limited arrivals/1');
add_line(model,'Transfer capacity per step/1','Bandwidth limited arrivals/2');
add_line(model,'Bandwidth limited arrivals/1','Recapture flow per step/1');
add_line(model,'Bandwidth limited arrivals/1','Graded arrivals/1');
add_line(model,'Graded arrivals/1','Mid arrivals per step/1');
add_line(model,'Graded arrivals/1','Refer arrivals per step/1');
add_line(model,'Graded arrivals/1','Auto screen flow per step/1');
add_line(model,'Auto screen flow per step/1','Auto-screen log/1');

set_param(model,'Solver','FixedStepDiscrete','FixedStep','step_seconds','StopTime','simulation_hours*3600');
save_system(model);
fprintf('Built %s.slx (scenario=%s)\n', model, scenario);
fprintf('arrivals/hr=%.1f auto=%.4f mid=%.4f refer=%.4f recap=%.4f\n', ...
    acquisition_rate, auto_screen_fraction, human_review_fraction, refer_fraction, recapture_fraction);
end

% -----------------------------------------------------------------------------
%  replicates the v8.12 service queue: prev + arrivals - min(backlog+arr, cap)
% -----------------------------------------------------------------------------
function make_service_queue(model, prefix, src_gain, service_expr)
add_block('simulink/Sources/Constant', [model '/' prefix ' service per step'], ...
    'Value', service_expr, 'Position',[30 400 220 440]);
add_block('simulink/Math Operations/Sum', [model '/' prefix ' queue update'], ...
    'Inputs','++-','Position',[300 300 345 350]);
add_block('simulink/Discrete/Unit Delay', [model '/' prefix ' queue memory'], ...
    'SampleTime','step_seconds','InitialCondition','0','Position',[390 300 470 340]);
add_block('simulink/Discontinuities/Saturation', [model '/' prefix ' nonneg queue'], ...
    'LowerLimit','0','UpperLimit','1e6','Position',[510 300 620 340]);
add_block('simulink/Sinks/To Workspace', [model '/' prefix ' queue log'], ...
    'VariableName',[prefix '_queue_log'],'SaveFormat','Timeseries','SampleTime','step_seconds','Position',[660 300 760 340]);
add_block('simulink/Math Operations/Add', [model '/' prefix ' backlog'], ...
    'Inputs','++','Position',[285 400 325 440]);
add_block('simulink/Math Operations/MinMax', [model '/' prefix ' actual service'], ...
    'Function','min','Inputs','2','Position',[390 400 490 440]);
add_block('simulink/Sinks/To Workspace', [model '/' prefix ' throughput log'], ...
    'VariableName',[prefix '_throughput_log'],'SaveFormat','Timeseries','SampleTime','step_seconds','Position',[530 400 650 440]);

add_line(model,[src_gain '/1'],[prefix ' queue update/2']);
add_line(model,[prefix ' service per step/1'],[prefix ' queue update/3']);
add_line(model,[prefix ' queue memory/1'],[prefix ' queue update/1']);
add_line(model,[prefix ' queue update/1'],[prefix ' nonneg queue/1']);
add_line(model,[prefix ' nonneg queue/1'],[prefix ' queue memory/1']);
add_line(model,[prefix ' nonneg queue/1'],[prefix ' queue log/1']);
add_line(model,[prefix ' queue memory/1'],[prefix ' backlog/1']);
add_line(model,[src_gain '/1'],[prefix ' backlog/2']);
add_line(model,[prefix ' backlog/1'],[prefix ' actual service/1']);
add_line(model,[prefix ' service per step/1'],[prefix ' actual service/2']);
add_line(model,[prefix ' actual service/1'],[prefix ' throughput log/1']);
end