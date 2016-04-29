%% Plot figures used in ZOOM evaluation
% Load result struct containing accuracy data
load('final_struct.mat'); output = 'figs/ispdsl';

% Define config parameters
close all;
paperUnits = 'centimeters';
printTitle = 0;
dpi = 600;
fontsize = 8;
linewidth = 2;
sizex = 10;
sizey = 5;
legendpos = 'NorthWest';
if (~isdir(output))
    mkdir(output);
end
%% Stacked bar plots for different s_ele

fig = figure(45);
std1 = [final.ZoomBase.nflows16.ntop1.time1.accuracy(1) final.ZoomBase.nflows16.ntop1.time2.accuracy(1) final.ZoomBase.nflows16.ntop1.time5.accuracy(1) ...
    final.ZoomBase.nflows16.ntop4.time1.accuracy(1) final.ZoomBase.nflows16.ntop4.time2.accuracy(1) final.ZoomBase.nflows16.ntop4.time5.accuracy(1) ...
    final.ZoomBase.nflows16.ntop8.time1.accuracy(1) final.ZoomBase.nflows16.ntop8.time2.accuracy(1) final.ZoomBase.nflows16.ntop8.time5.accuracy(1)]';

std10 = [final.ZoomBase.nflows16.ntop1.time1.accuracy(10) final.ZoomBase.nflows16.ntop1.time2.accuracy(10) final.ZoomBase.nflows16.ntop1.time5.accuracy(10) ...
    final.ZoomBase.nflows16.ntop4.time1.accuracy(10) final.ZoomBase.nflows16.ntop4.time2.accuracy(10) final.ZoomBase.nflows16.ntop4.time5.accuracy(10) ...
    final.ZoomBase.nflows16.ntop8.time1.accuracy(10) final.ZoomBase.nflows16.ntop8.time2.accuracy(10) final.ZoomBase.nflows16.ntop8.time5.accuracy(10)]';

std30 = [final.ZoomBase.nflows16.ntop1.time1.accuracy(30) final.ZoomBase.nflows16.ntop1.time2.accuracy(30) final.ZoomBase.nflows16.ntop1.time5.accuracy(30) ...
    final.ZoomBase.nflows16.ntop4.time1.accuracy(30) final.ZoomBase.nflows16.ntop4.time2.accuracy(30) final.ZoomBase.nflows16.ntop4.time5.accuracy(30) ...
    final.ZoomBase.nflows16.ntop8.time1.accuracy(30) final.ZoomBase.nflows16.ntop8.time2.accuracy(30) final.ZoomBase.nflows16.ntop8.time5.accuracy(30)]';

cmap = copper(3);
h = bar(1:length(std1), [std30 std10-std30 std1-std10], 0.5, 'stack');
set(h(1), 'FaceColor', cmap(1,:));
set(h(2), 'FaceColor', cmap(2,:));
set(h(3), 'FaceColor', cmap(3,:));
xlabels = {'1,1', '1,2', '1,5', ...
    '4,1', '4,2', '4,5', ...
    '8,1', '8,2', '8,5'};
set(gca,'XTickLabel',xlabels);
set(gca,'YTick',0:0.2:1);
ylim([0 1.2]);

hl = legend('s_{ele} = 30', 's_{ele} = 10', 's_{ele} = 1', 'location', [0.518 0.875 0 0], 'orientation', 'horizontal');

ylabel('Accuracy');
xlabel('n_{top},t_{wait}');
set(gca, 'Fontsize', fontsize);
save2pdf(strcat(output, '/accuracy_for_elephantthreshold'), fig, dpi, fontsize, 0.5, [0 0 sizex sizey]);
close(fig);

%% Plot accuracy vs elephant count and n_top for n_flows = 16

fig = figure(27); hold on;
box on; grid on;

cmap = copper(3);

style = '-';
solid1 = plot(final.total_elephant_count, final.ZoomBase.nflows16.ntop1.time1.accuracy, style, 'color', cmap(1,:));
solid2 = plot(final.total_elephant_count, final.ZoomBase.nflows16.ntop1.time2.accuracy, style, 'color', cmap(2,:));
solid3 = plot(final.total_elephant_count, final.ZoomBase.nflows16.ntop1.time5.accuracy, style, 'color', cmap(3,:));
style = '--';
dashed1 = plot(final.total_elephant_count, final.ZoomBase.nflows16.ntop4.time1.accuracy, style, 'color', cmap(1,:));
plot(final.total_elephant_count, final.ZoomBase.nflows16.ntop4.time2.accuracy, style, 'color', cmap(2,:));
plot(final.total_elephant_count, final.ZoomBase.nflows16.ntop4.time5.accuracy, style, 'color', cmap(3,:));
style = ':';
dotted1 = plot(final.total_elephant_count, final.ZoomBase.nflows16.ntop8.time1.accuracy, style, 'color', cmap(1,:));
plot(final.total_elephant_count, final.ZoomBase.nflows16.ntop8.time2.accuracy, style, 'color', cmap(2,:));
plot(final.total_elephant_count, final.ZoomBase.nflows16.ntop8.time5.accuracy, style, 'color', cmap(3,:));
dummy_solid1 = plot(0.01:0.02,0.01:0.02, '-', 'color', cmap(1,:), 'Marker', 'None');

% Workaround to place two legends in one figure
% Manipulated legend function mylegend that does not remove already present
% legend 
lh1 = mylegend([solid1 solid2 solid3], '1', '2', '5', 'Location', [0.84 0.35 0 0]);
v = get(lh1,'title');
set(v,'string','t_{wait}');
lh2 = mylegend([dummy_solid1 dashed1 dotted1], '1', '4', '8', 'Location', [0.715 0.35 0 0]);
v = get(lh2,'title');
set(v,'string','n_{top}');

ylim([0 1]);
set(gca,'YTick',0:0.2:1);
set(gca, 'Fontsize', fontsize);
xlabel('Number of elephant flows');
ylabel('Accuracy');
save2pdf(strcat(output, '/ntop'), fig, dpi, fontsize, 1, [0 0 sizex sizey]);
close(fig);

%% Plot accuracy vs elephant count for different n_flows and t_wait = 1

fig = figure(11); hold on;
box on; grid on;

cmap = copper(3);

style = '-';
plot(final.ZoomBase.nflows16.ntop1.time1.elephant_count, final.ZoomBase.nflows16.ntop1.time1.accuracy, style, 'color', cmap(3,:));
plot(final.ZoomBase.nflows16.ntop4.time1.elephant_count, final.ZoomBase.nflows16.ntop4.time1.accuracy, style, 'color', cmap(2,:));
plot(final.ZoomBase.nflows16.ntop8.time1.elephant_count, final.ZoomBase.nflows16.ntop8.time1.accuracy, style, 'color', cmap(1,:));
style = '--';
plot(final.ZoomBase.nflows4.ntop1.time1.elephant_count, final.ZoomBase.nflows4.ntop1.time1.accuracy, style, 'color', cmap(3,:));
plot(final.ZoomBase.nflows4.ntop2.time1.elephant_count, final.ZoomBase.nflows4.ntop2.time1.accuracy, style, 'color', cmap(2,:));
style = ':';
plot(final.ZoomBase.nflows2.ntop1.time1.elephant_count, final.ZoomBase.nflows2.ntop1.time1.accuracy, style, 'color', cmap(3,:));

ylim([0 1]);
set(gca,'YTick',0:0.2:1);
set(gca, 'Fontsize', fontsize);
xlabel('Number of elephant flows');
ylabel('Accuracy');
save2pdf(strcat(output, '/nflows'), fig, dpi, fontsize, 1, [0 0 sizex sizey]);
close(fig);

%% Plot accuracy vs elephant count for different n_flows/n_top ratios and different t_wait

fig = figure(11); hold on;
box on; grid on;

cmap = copper(3);

style = '-';
plot(final.ZoomBase.nflows16.ntop8.time1.elephant_count, final.ZoomBase.nflows16.ntop8.time1.accuracy, style, 'color', cmap(1,:));
plot(final.ZoomBase.nflows16.ntop8.time5.elephant_count, final.ZoomBase.nflows16.ntop8.time5.accuracy, style, 'color', cmap(2,:));
style = '--';
plot(final.ZoomBase.nflows4.ntop2.time1.elephant_count, final.ZoomBase.nflows4.ntop2.time1.accuracy, style, 'color', cmap(1,:));
plot(final.ZoomBase.nflows4.ntop2.time5.elephant_count, final.ZoomBase.nflows4.ntop2.time5.accuracy, style, 'color', cmap(2,:));
style = ':';
plot(final.ZoomBase.nflows2.ntop1.time1.elephant_count, final.ZoomBase.nflows2.ntop1.time1.accuracy, style, 'color', cmap(1,:));
plot(final.ZoomBase.nflows2.ntop1.time5.elephant_count, final.ZoomBase.nflows2.ntop1.time5.accuracy, style, 'color', cmap(2,:));

ylim([0 1]);
set(gca,'YTick',0:0.2:1);
set(gca, 'Fontsize', fontsize);
xlabel('Number of elephant flows');
ylabel('Accuracy');
save2pdf(strcat(output, '/runtime'), fig, dpi, fontsize, 1, [0 0 sizex sizey]);
close(fig);

%% Plot bar chart combining parameter combinations, varying t_wait

times = [1 2 5];

fig = figure();
hold on;
cols = copper(4);
cols(1,:) = [];
ci_vector = [];
acc_vector = [];
for i = times
    tmp = [final.ZoomBase.nflows16.ntop8.(['time' num2str(i)]).accuracy', final.ZoomBase.nflows16.ntop4.(['time' num2str(i)]).accuracy', ...
        final.ZoomBase.nflows16.ntop1.(['time' num2str(i)]).accuracy', final.ZoomBase.nflows4.ntop2.(['time' num2str(i)]).accuracy', ...
        final.ZoomBase.nflows4.ntop1.(['time' num2str(i)]).accuracy', final.ZoomBase.nflows2.ntop1.(['time' num2str(i)]).accuracy'];
    acc_vector = [acc_vector mean(tmp)];
    [~,~,ci,~] = ttest(tmp);
    ci = ci(2) - mean(tmp);
    ci_vector = [ci_vector ci];
end

errorbar_groups(acc_vector, ci_vector, 'FigID', fig, 'bar_colors', cols);
ylim([0 1]);
set(gca, 'XTickLabel', {'1', '2', '5'});
xlabel('t_{wait}');
ylabel('Accuracy');
save2pdf(strcat(output, '/accuracy_by_twait'), fig, dpi, fontsize, 1, [0 0 sizex sizey]);
close(fig);

%% Plot bar chart combining parameter combinations, varying the elephant threshold

nflows = [2 4 16];
ntop = [0 0 1; 0 2 1; 8 4 1];
twait = [1 2 5];
a_vec = zeros(30, 1);
ci_vec = zeros(30, 1);
c_vec = zeros(30, 1);

for i = 1:30
    tmp = [];
    c = 0;
    tmp2 = [];
    for flows = nflows
        c = c+1;
        for top = ntop(c,:)
            if top == 0
                continue;
            end
            for wait = twait
                tmp = [tmp final.ZoomBase.(['nflows' num2str(flows)]).(['ntop' num2str(top)]).(['time' num2str(wait)]).accuracy(i)];
                tmp2 = [tmp2 final.ZoomBase.(['nflows' num2str(flows)]).(['ntop' num2str(top)]).(['time' num2str(wait)]).elephant_count(i)];
            end
        end
    end
    a_vec(i) = mean(tmp);
    [~,~,ci,~] = ttest(tmp);
    ci = ci(2) - mean(tmp);
    ci_vec(i) = ci;
    c_vec(i) = mean(tmp2);
end
fig = figure();
hold on;
cols = copper(4);
cols(1,:) = [];

bar(1:30, a_vec, 'facecolor', cols(1,:));
errorbar(1:30, a_vec, ci_vec, 'color', copper(1));
xlim([0 31]);

xlabel('Threshold in times std');
ylabel('Accuracy');
save2pdf(strcat(output, '/accuracy_by_treshold_combined'), fig, dpi, fontsize, 1, [0 0 sizex sizey]);
close(fig);

%% Plot bar chart combining parameter combinations, varying the elephant threshold; twait=5


nflows = [2 4 16];
ntop = [0 0 1; 0 2 1; 8 4 1];
twait = [5]; % Adjust here to plot for 1, 2 or 5
a_vec = zeros(30, 1);
ci_vec = zeros(30, 1);
c_vec = zeros(30, 1);

for i = 1:30
    tmp = [];
    c = 0;
    tmp2 = [];
    for flows = nflows
        c = c+1;
        for top = ntop(c,:)
            if top == 0
                continue;
            end
            for wait = twait
                tmp = [tmp final.ZoomBase.(['nflows' num2str(flows)]).(['ntop' num2str(top)]).(['time' num2str(wait)]).accuracy(i)];
                tmp2 = [tmp2 final.ZoomBase.(['nflows' num2str(flows)]).(['ntop' num2str(top)]).(['time' num2str(wait)]).elephant_count(i)];
            end
        end
    end
    a_vec(i) = mean(tmp);
    [~,~,ci,~] = ttest(tmp);
    ci = ci(2) - mean(tmp);
    ci_vec(i) = ci;
    c_vec(i) = mean(tmp2);
end
fig = figure();
hold on;
cols = copper(4);
cols(1,:) = [];

bar(1:30, a_vec, 'facecolor', cols(1,:));
errorbar(1:30, a_vec, ci_vec, 'color', copper(1));
xlim([0 31]);
xlabel('Threshold in times std');
ylabel('Accuracy');
save2pdf(strcat(output, '/accuracy_by_treshold_twait', num2str(twait)), fig, dpi, fontsize, 1, [0 0 sizex sizey]);
close(fig);
