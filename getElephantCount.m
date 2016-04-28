function count = getElephantCount(data, varargin)
    dFlag = 0; % Duration
    bFlag = 0; % Bandwidth
    tFlag = 0; % Total transfered bytes
    % Parse arguments
    while ~isempty(varargin)
        switch upper(varargin{1})
            case 'DURATION'
                dFlag = 1;
                bFlag = 0;
                tFlag = 0;
                eduration = varargin{2};
                varargin(1:2) = [];
            case 'BANDWIDTH'
                dFlag = 0;
                bFlag = 1;
                tFlag = 0;
                ebandwidth = varargin{2};
                varargin(1:2) = [];
            case 'TOTAL'
                dFlag = 0;
                bFlag = 0;
                tFlag = 1;
                etotal = varargin{2};
                varargin(1:2) = [];
        end
    end
    
    if (dFlag)
        indy = find(data{6}>eduration);
    elseif(bFlag)
        fbandwidth = data{5}./data{6};
        indy = find(fbandwidth>ebandwidth);
    elseif(tFlag)
        indy = find(data{5}>etotal);
    end
    
    count = length(indy);
end

