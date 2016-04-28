function meta = getTraceMetadata(trace, times_std)

fid = fopen(trace);
data = textscan(fid, '%f%s%s%s%f%f');
fclose(fid);

s = mean(data{5}) + times_std*std(data{5});

meta.trace = trace;
[min, max, avg, eavg] = getActiveFlowNumbers(data, s);
meta.totalNumberOfFlows = length(data{1});
meta.averageActiveFlows = avg;
meta.minActiveFlows = min;
meta.maxActiveFlows = max;
meta.elephants = getElephants(data, 'TOTAL', s);
meta.avgActiveElephants = eavg;
meta.meanDuration = getMeanElephantDuration(meta.elephants);
meta.elephantTrafficContrib = getElephantTrafficContribution(data, meta.elephants);
meta.elephantCountContrib = length(meta.elephants{1})/length(data{1});
meta.topOnePercentageContrib = getTopContribution(data, 0.01);

end