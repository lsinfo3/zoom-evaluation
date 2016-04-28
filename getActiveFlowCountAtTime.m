function r = getActiveFlowCountAtTime(data, time)

    fstart = data{1};
%     fsrc = data{2};
%     fsport = data{3};
%     fdst = data{4};
%     fdport = data{5};
%     fprot = data{6};
%     fsize = data{7};
    fduration = data{6};
    fend = fstart+fduration;
    
    indyStart = find(fstart<=time);
    indyEnd = find(fend>=time);
    indy = intersect(indyStart,indyEnd);
    
    r = length(indy);

end