function [min, maxi, avg, eavg] = getActiveFlowNumbers(data, size)

count = 0;
e_count = 0;
maxTime = max(data{1}+data{6});
min = Inf;
maxi = -Inf;
for i = 1:1:maxTime
    i
    current = getActiveFlowCountAtTime(data, i);
    count = count + current;
    e_count = e_count + getActiveElephantCountAtTime(data, i, size);
    if (maxi < current)
        maxi = current;
    end
    if (min > current)
        min = current;
    end
end
avg = count/maxTime;
eavg = e_count/maxTime;