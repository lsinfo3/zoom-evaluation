function data = getActiveFlowsAtTime(data, time)

    fstart = data{1};
%     fsrc = data{2};
%     fsport = data{3};
%     fdst = data{3};
%     fdport = data{5};
%     fprot = data{4};
%     fsize = data{5};
    fduration = data{6};
    fend = fstart+fduration;
    
    indyStart = find(fstart<=time);
    indyEnd = find(fend>=time);
    indy = intersect(indyStart,indyEnd);
    
    [data{1} sort_indy] = sort(data{1}(indy));
    data{2} = data{2}(indy);
    data{2} = data{2}(sort_indy);
    data{3} = data{3}(indy);
    data{3} = data{3}(sort_indy);
    data{4} = data{4}(indy);
    data{4} = data{4}(sort_indy);
    data{5} = data{5}(indy);
    data{5} = data{5}(sort_indy);
    data{6} = data{6}(indy);
    data{6} = data{6}(sort_indy);
%     data{7} = data{7}(indy);
%     data{8} = data{8}(indy);

end