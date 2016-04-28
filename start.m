%% Entrypoint of the ZOOM Evaluation
clear all; % Clean old variables
close all; % Close all open figures

%% Parse flow data from traces
% ISPDSL-II 20 minute trace
trace = './data/20100106-030946-0.dsl_60.0.flow';
input = './results_ISPDSL-II';
fid = fopen(trace);
data = textscan(fid, '%f%s%s%s%f%f');
fclose(fid);
%

algorithm='ZoomBase';
resStruct = [];
temp = struct('algorithm', algorithm, 'nflows', 16, 'ntop', 8, 'time', 1); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 16, 'ntop', 8, 'time', 2); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 16, 'ntop', 8, 'time', 5); resStruct = [resStruct; temp];

temp = struct('algorithm', algorithm, 'nflows', 16, 'ntop', 4, 'time', 1); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 16, 'ntop', 4, 'time', 2); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 16, 'ntop', 4, 'time', 5); resStruct = [resStruct; temp];

temp = struct('algorithm', algorithm, 'nflows', 16, 'ntop', 1, 'time', 1); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 16, 'ntop', 1, 'time', 2); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 16, 'ntop', 1, 'time', 5); resStruct = [resStruct; temp];

temp = struct('algorithm', algorithm, 'nflows', 4, 'ntop', 2, 'time', 1); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 4, 'ntop', 2, 'time', 2); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 4, 'ntop', 2, 'time', 5); resStruct = [resStruct; temp];

temp = struct('algorithm', algorithm, 'nflows', 4, 'ntop', 1, 'time', 1); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 4, 'ntop', 1, 'time', 2); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 4, 'ntop', 1, 'time', 5); resStruct = [resStruct; temp];

temp = struct('algorithm', algorithm, 'nflows', 2, 'ntop', 1, 'time', 1); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 2, 'ntop', 1, 'time', 2); resStruct = [resStruct; temp];
temp = struct('algorithm', algorithm, 'nflows', 2, 'ntop', 1, 'time', 5); resStruct = [resStruct; temp];

clear temp algorithm; % Clear temporary variables

%% Evaluate Accuracy

elephant_criterion = 'TOTAL';
times_std = 1:50;

for i=1:length(resStruct)
    % User Feedback
    disp(strcat(int2str(i), '/', int2str(length(resStruct))));
    % Read files from directory of current parameter combination
    current_dir = strcat(input,'/', resStruct(i).algorithm, '/', num2str(resStruct(i).nflows), '/', num2str(resStruct(i).ntop), '/', num2str(resStruct(i).time), '/');    
    files = dir(current_dir);
    files = files(~[files.isdir]);
    files = sort_nat({files.name});
   

    clear mean_accuracy fP_percent_vector fN_percent_vector;
    mean_accuracy_vector = zeros(length(times_std),1);
    elephant_count_vector = zeros(length(times_std),1);
    mean_recall_vector = zeros(length(times_std),1);
    elephant_threshold_vector = zeros(length(times_std),1);
    elephant_duration_vector = zeros(length(times_std),1);
    total_elephant_count_vector = zeros(length(times_std),1);
    % Iterate over result files regarding the current parameter combination
    for u = times_std
        elephant_threshold = mean(data{5})+u*std(data{5}); %  Flows larger than the average + x times the standard deviation are considered elephants
        mean_accuracy = [];
        mean_recall = [];
        fP_percent_vector = [];
        fN_percent_vector = [];
        mean_active_elephants_vector = [];
        for j=1:length(files)

            % Get starting time of algorithm run
            tmp = strsplit(files{j}, '_');
            st_time = str2double(tmp(2));

            % Find active flows at current time
            active_flows = getActiveFlowsAtTime(data, st_time);

            % Parse result file
            fid = fopen(strcat(current_dir, files{j}));
            result_data = textscan(fid,'%s%s%s%s%d','CommentStyle','#','delimiter',';');
            fclose(fid);
            algo.src = result_data{1}; % Source IP
            algo.dst = result_data{3}; % Destination IP
            algo.bps = result_data{5}; % Transmission rate in bit per second

            % Interate over all flows found by the algorithm
            clear algo_indy; algo_indy = [];
            for k=1:length(algo.src)
                % Get Flows detected by ZoomBase
                if (strcmp(resStruct(i).algorithm,'ZoomBase'))
                    src_indy = find(strcmp(active_flows{2}, algo.src{k})); % Find active flows with matching src
                    dst_indy = find(strcmp(active_flows{3}, algo.dst{k})); % Find active flows with matching dst
                    flow_indy = intersect(src_indy, dst_indy); % Intersect the found indices
                    algo_indy = [algo_indy; flow_indy]; % Append indices to the flows found by the algorithm
                else % Get Flows detected by ZoomTT
                    src_indy = find(strcmp(active_flows{2}, algo.src{k})); % Find active flows with matching src
                end
            end
            if (length(algo_indy) > length(algo.src))
               algo_indy = algo_indy(end-length(algo.src)+1:end); 
            end
            elephants_indy = getElephantIndices(active_flows, elephant_criterion, elephant_threshold); % Get elephants active at the current time

            if (~isempty(elephants_indy))
                found = intersect(elephants_indy, algo_indy); % Get elephants detected by the algorithm

                fP_percent = ((resStruct(i).ntop - length(found)) / resStruct(i).ntop); % fP based on ntop
                fP_percent_vector = [fP_percent_vector fP_percent];
                fN_percent = length(found) / length(elephants_indy); % fP based on active elephants
                fN_percent_vector = [fN_percent_vector fN_percent];
                mean_accuracy = [mean_accuracy 1-fP_percent];
                mean_recall = [mean_recall fN_percent];
                mean_active_elephants_vector = [mean_active_elephants_vector length(elephants_indy)];
            end
        end
        mean_accuracy_vector(u) = mean(mean_accuracy);
        elephant_count_vector(u) = mean(mean_active_elephants_vector);
        mean_recall_vector(u) = mean(mean_recall);
        elephant_threshold_vector(u) = elephant_threshold;
        elephant_duration_vector(u) = mean(data{6}(getElephantIndices(data, 'TOTAL', elephant_threshold)));
        total_elephant_count_vector(u) = getElephantCount(data, 'TOTAL', elephant_threshold);
    end
    
    % Generate struct containing relevant data regarding all evaluated
    % parameter combinations
    final.(resStruct(i).algorithm).(['nflows',  num2str(resStruct(i).nflows)]).(['ntop', num2str(resStruct(i).ntop)]).(['time', num2str(resStruct(i).time)]).accuracy = mean_accuracy_vector;
    final.(resStruct(i).algorithm).(['nflows',  num2str(resStruct(i).nflows)]).(['ntop', num2str(resStruct(i).ntop)]).(['time', num2str(resStruct(i).time)]).recall = mean_recall_vector;
    final.(resStruct(i).algorithm).(['nflows',  num2str(resStruct(i).nflows)]).(['ntop', num2str(resStruct(i).ntop)]).(['time', num2str(resStruct(i).time)]).elephant_count = elephant_count_vector;
    final.(resStruct(i).algorithm).(['nflows',  num2str(resStruct(i).nflows)]).(['ntop', num2str(resStruct(i).ntop)]).(['time', num2str(resStruct(i).time)]).elephant_threshold = elephant_threshold_vector;
    final.(resStruct(i).algorithm).(['nflows',  num2str(resStruct(i).nflows)]).(['ntop', num2str(resStruct(i).ntop)]).(['time', num2str(resStruct(i).time)]).elephant_duration = elephant_duration_vector;
end
final.total_elephant_count = total_elephant_count_vector;

% Save final struct to the disk for later reusal
save('final_struct', 'final');






