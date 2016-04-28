function c = getTopContribution(data, percentage)

count = length(data{1});
onePercent = round(percentage * count);

totalTraffic = sum(data{5});

topOnePercent = sort(data{5}, 'descend');
c = sum(topOnePercent(1:onePercent))/totalTraffic;

end