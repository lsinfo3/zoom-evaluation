function data = getElephants(data, varargin)
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
    
    data{1} = data{1}(indy);
    data{2} = data{2}(indy);
    data{3} = data{3}(indy);
    data{4} = data{4}(indy);
    data{5} = data{5}(indy);
    data{6} = data{6}(indy);
%     data{7} = data{7}(indy);
%     data{8} = data{8}(indy);
end