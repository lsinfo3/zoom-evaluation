function [leg,labelhandles,outH,outM] = mylegend(varargin)
%LEGEND Display legend.
%   LEGEND(string1,string2,string3, ...) puts a legend on the current plot
%   using the specified strings as labels. LEGEND works on line graphs,
%   bar graphs, pie graphs, ribbon plots, etc.  You can label any
%   solid-colored patch or surface object.  The fontsize and fontname for
%   the legend strings matches the axes fontsize and fontname.
%
%   LEGEND(H,string1,string2,string3, ...) puts a legend on the plot
%   containing the handles in the vector H using the specified strings as
%   labels for the corresponding handles.
%
%   LEGEND(M), where M is a string matrix or cell array of strings, and
%   LEGEND(H,M) where H is a vector of handles to lines and patches also
%   works.
%
%   LEGEND(AX,...) puts a legend on the axes with handle AX.
%
%   LEGEND OFF removes the legend from the current axes and deletes
%   the legend handle.
%   LEGEND(AX,'off') removes the legend from the axis AX.
%
%   LEGEND TOGGLE toggles legend on or off.  If no legend exists for the
%   current axes one is created using default strings. The default
%   string for an object is the value of the DisplayName property
%   if it is non-empty and otherwise it is a string of the form
%   'data1','data2', etc.
%   LEGEND(AX,'toggle') toggles legend for axes AX
%
%   LEGEND HIDE makes legend invisible.
%   LEGEND(AX,'hide') makes legend on axes AX invisible.
%   LEGEND SHOW makes legend visible. If no legend exists for the
%   current axes one is created using default strings.
%   LEGEND(AX,'show') makes legend on axes AX visible.
%
%   LEGEND BOXOFF  makes legend background box invisible when legend is
%   visible.
%   LEGEND(AX,'boxoff') for axes AX makes legend background box invisible when
%   legend is visible.
%   LEGEND BOXON makes legend background box visible when legend is visible.
%   LEGEND(AX,'boxon') for axes AX making legend background box visible when
%   legend is visible.
%
%   LEGH = LEGEND returns the handle to legend on the current axes or
%   empty if none exists.
%
%
%   LEGEND(...,'Location',LOC) adds a legend in the specified
%   location, LOC, with respect to the axes.  LOC may be either a
%   1x4 position vector or one of the following strings:
%       'North'              inside plot box near top
%       'South'              inside bottom
%       'East'               inside right
%       'West'               inside left
%       'NorthEast'          inside top right (default for 2-D plots)
%       'NorthWest'          inside top left
%       'SouthEast'          inside bottom right
%       'SouthWest'          inside bottom left
%       'NorthOutside'       outside plot box near top
%       'SouthOutside'       outside bottom
%       'EastOutside'        outside right
%       'WestOutside'        outside left
%       'NorthEastOutside'   outside top right (default for 3-D plots)
%       'NorthWestOutside'   outside top left
%       'SouthEastOutside'   outside bottom right
%       'SouthWestOutside'   outside bottom left
%       'Best'               least conflict with data in plot
%       'BestOutside'        least unused space outside plot
%   If the legend does not fit in the 1x4 position vector the position
%   vector is resized around the midpoint to fit the preferred legend size.
%   Moving the legend manually by dragging with the mouse or setting
%   the Position property will set the legend Location property to 'none'.
%
%   LEGEND(...,'Orientation',ORIENTATION) creates a legend with the
%   legend items arranged in the specified ORIENTATION. Allowed
%   values for ORIENTATION are 'vertical' (the default) and 'horizontal'.
%
%   [LEGH,OBJH,OUTH,OUTM] = LEGEND(...) returns a handle LEGH to the
%   legend axes; a vector OBJH containing handles for the text, lines,
%   and patches in the legend; a vector OUTH of handles to the
%   lines and patches in the plot; and a cell array OUTM containing
%   the text in the legend.
%
%   Examples:
%       x = 0:.2:12;
%       plot(x,besselj(1,x),x,besselj(2,x),x,besselj(3,x));
%       legend('First','Second','Third','Location','NorthEastOutside')
%
%       b = bar(rand(10,5),'stacked'); colormap(summer); hold on
%       x = plot(1:10,5*rand(10,1),'marker','square','markersize',12,...
%                'markeredgecolor','y','markerfacecolor',[.6 0 .6],...
%                'linestyle','-','color','r','linewidth',2); hold off
%       legend([b,x],'Carrots','Peas','Peppers','Green Beans',...
%                 'Cucumbers','Eggplant')


%   Unsupported APIs for internal use:
%
%   LOC strings can be abbreviated NE, SO, etc or lower case.
%
%   LEGEND('-DynamicLegend') or LEGEND(AX,'-DynamicLegend')
%   creates a legend that adds new entries when new plots appear
%   in the peer axes.
%
%   LEGEND(LI,string1,string2,string3) creates a legend for legendinfo
%   objects LI with strings string1, etc.
%   LEGEND(LI,M) creates a legend for legendinfo objects LI where M is a
%   string matrix or cell array of strings corresponding to the legendinfo
%   objects.

%   Copyright 1984-2015 The MathWorks, Inc.

% Legend no longer supports more than one output argument
% Warn the user and ignore additional output arguments.

args = varargin;

% Continue warning that the v6 form will go away in the future.
if (nargin > 1 ...
        && matlab.internal.strfun.ischarlike(args{1}) ...
        && ~matlab.internal.strfun.ischarlike(args{2}) ...
        && strcmp(args{1},'v6'))
    warning(message('MATLAB:legend:DeprecatedV6Argument'));
end

%--------------------------------------------------------
% Begin building the legend
%--------------------------------------------------------
matlab.graphics.illustration.Legend.empty;
narg = nargin;

% HANDLE FINDLEGEND CASES FIRST
if narg==2 ...
        && matlab.internal.strfun.ischarlike(args{1}) ...
        && strcmpi(args{1},'-find') ...
        && ~isempty(args{2}) ...
        && ishghandle(args{2},'axes')

    [leg,labelhandles,outH,outM] = setOutArgs(args{2});
    
    return;
end

% add flag to create compatible legend
version = 'off';
if nargout > 1
    version = 'on';
end

arg = 1;

% GET AXES FROM INPUTS
ha = matlab.graphics.axis.Axes.empty;

% use the current axes by default if one exists, but do not create one
old_currfig = get(0,'CurrentFigure');
if ~isempty(old_currfig) && ishghandle(old_currfig)
    old_currax = get(old_currfig,'CurrentAxes');
    if ~isempty(old_currax)
        ha = old_currax;
    end
end

% determine peer axes from inputs
if narg > 0  && ...
        ~isempty(args{1}) && ...
        length(args{1})==1 && ...
        ishghandle(args{1}) && ...
        isa(handle(args{1}),'matlab.graphics.mixin.LegendTarget')
    % legend(ax,...)
    ha = handle(args{1});
    arg = arg + 1;
elseif narg > 0 && ...
        ~matlab.internal.strfun.ischarlike(args{1}) && ...
        ~isempty(args{1}) && ...
        all(ishghandle(args{1})) % legend(children,strings,...)
    ha = ancestor(args{1}(1),'axes');
    if isempty(ha)
        obj = args{1}(1);
        if ~isempty(obj) % Provide a better error message if we can.
            error(message('MATLAB:legend:InvalidPeerHandle', getClassName(obj)));
        else
            error(message('MATLAB:legend:InvalidPeerParameter'));
        end
    end
else
    % use the current axes if one exists, but do not create one.
    if isempty(ha)        
        % @todo - i18n: new user visible warning.
        warning(message('MATLAB:legend:NoCurrentAxes'));
        % @todo - until all of legend can handle the empty ha case
        % handle the early return cases here.  Conventionally, all output
        % arg processing should be handled below at the end of main.
        
        [leg,labelhandles,outH,outM] = setOutArgs(ha);
       
        return
    end
end

% Error if given uiaxes
if isa(ha,'matlab.ui.control.UIAxes')
    error(message('MATLAB:ui:uiaxes:general'));
end

% cast double to MCOS handle
if ~isobject(ha)
    ha = handle(ha);
end

% LOOK FOR -DEFAULTSTRINGS option flag
% dfltstrings=false;
% if narg >= arg && all(ischar(args{arg})) && ...
%         all(strcmpi(args{arg},'-defaultstrings'))
%     dfltstrings=true;
%     arg = arg + 1;
% end

% PROCESS REMAINING INPUTS
msg = '';
if narg < arg % [a,b,c,d] = legend (with no inputs)
    [leg,labelhandles,outH,outM] = setOutArgs(ha);
    return;
elseif narg >= arg && matlab.internal.strfun.ischarlike(args{arg})
    switch char(lower(args{arg}))
        case {'off', 'deletelegend'}
            delete_legend(find_legend(ha));
        case 'resizelegend'
            % pass
        case 'toggle'
            l = find_legend(ha);
            if isempty(l) || strcmpi(get(l, 'Visible'), 'off')
                legend(ha, 'show');
            else
                legend(ha, 'hide');
            end
        case 'show'
            l = find_legend(ha);
            if isempty(l)
                [~, msg] = make_legend(ha, args(arg+1:end), version);
            else
                set(l, 'Visible', 'on');
            end
        case 'hide'
            l = find_legend(ha);
            set(l, 'Visible', 'off');
        case 'boxon'
            l = find_legend(ha);
            set(l, 'Box', 'on');
        case 'boxoff'
            l = find_legend(ha);
            set(l, 'Box', 'off');
        otherwise
            [~, msg] = make_legend(ha, args(arg:end), version);
    end
else % narg > 1
    [~,msg] = make_legend(ha,args(arg:end),version);
end
if ~isempty(msg)
    warning(msg);
end

% PROCESS OUTPUTS
if nargout>0
    [leg,labelhandles,outH,outM] = setOutArgs(ha);
end

% before going, be sure to reset current figure and axes
if ~isempty(old_currfig) && ishghandle(old_currfig) && ~strcmpi(get(old_currfig,'beingdeleted'),'on')
    set(0,'CurrentFigure',old_currfig);
    if ~isempty(old_currax) && ishghandle(old_currax) && ~strcmpi(get(old_currax,'beingdeleted'),'on')
        set(old_currfig,'CurrentAxes',old_currax);
    end
end


%----------------------
% Helper functions
%----------------------

%----------------------------------------------------%
function [leg,warnmsg] = make_legend(ha,argin,version_flag)

warnmsg = [];

% find and delete existing legend
%leg = find_legend(ha);
%if ~isempty(leg)
%    delete_legend(leg);
%end

% create legend
fig = ancestor(ha,'figure');
parent = get(ha,'Parent');
leg = matlab.graphics.illustration.Legend;
leg.doPostSetup(version_flag);
leg.Visible = 'off';

% determine if axes is 2D
isAxes2D = is2D(ha);

% process args
[orient,location,position,children,listen,strings,propargs] = process_inputs(ha,argin); %#ok

% set position if empty
if isempty(position)
    position = -1;
end

% check PV pairs
check_pv_args(propargs);

if ~isempty(children)
    % check that all children from user are Legendable
    validateLegendable(children);
    auto_children = false;
else
    % if isempty(children), get children from axes
    [children, warnmsg] = getAutoChildren(ha);
    if isempty(children)
        leg = [];
        return;
    end
    auto_children = true;
end

% fill in strings if needed
set_children_and_strings(leg,children,strings,auto_children);

if strcmp(get(ha,'color'),'none')
    leg.Color_I = get(fig,'Color');
else
    leg.Color_I = get(ha,'Color');
end
leg.TextColor_I = get(parent,'DefaultTextColor');
leg.EdgeColor_I = get(parent,'DefaultAxesXColor');

% set the peer axes
leg.Axes = ha;

% apply 3D default
if ~isAxes2D
    leg.Location = 'northeastoutside';
elseif isa(ha, 'matlab.graphics.axis.PolarAxes')
    leg.Location = 'eastoutside';
end
if ~isempty(location)
    leg.Location = location;
end
if ~isempty(orient)
    leg.Orientation = orient;
end

% set other properties passed in varargin
if ~isempty(propargs)
    set(leg,propargs{:});      
end

%Set the position manually, if specified
if ~isempty(position) && length(position)==4
  leg.Position = position;
end

% now make visible
set(leg,'Visible','on');

%----------------------------------------------------%
function delete_legend(leg)

if ~isempty(leg) && ishghandle(leg) && ~strcmpi(get(leg,'beingdeleted'),'on')
    delete(leg);
end

%----------------------------------------------------%
function leg = find_legend(ha)

% Using the "LegendPeerHandle" appdata, we will find the legend peered to
% the current axes. This handle may be invalid due to copy/paste effects.
% In this case, the appdata will be reset.
leg = matlab.graphics.illustration.Legend.empty;
if isempty(ha) || ~ishghandle(ha)
    return;
end
if ~isappdata(ha,'LegendPeerHandle')
    return;
end
leg = getappdata(ha,'LegendPeerHandle');
if ~ishghandle(leg) || ~isequal(get(leg,'Axes'),ha)
    % Reset the "LegendPeerHandle" appdata
    rmappdata(ha,'LegendPeerHandle');
    leg = matlab.graphics.illustration.Legend.empty;
end

%-----------------------------------------------------%
function [leg,hobjs,outH,outM] = find_legend_info(ha)

leg = find_legend(ha);

if ~isempty(leg) && strcmp(leg.version,'on')
    drawnow;
    outH = leg.PlotChildren;
    outM = leg.String(:).';
    hobjs = [leg.ItemText(:); leg.ItemTokens(:)];
else
    outH = [];
    outM = [];
    hobjs = [];
end

%----------------------------------------------------%
function [orient,location,position,children,listen,strings,propargs] = process_inputs(ax,argin)

orient=''; 
location='';
position=[];
children = []; 
strings = {}; 
propargs = {};
listen = false;

nargs = length(argin);
if nargs==0
    return;
end

if matlab.internal.strfun.ischarlike(argin{1}) && strcmpi(argin{1},'-DynamicLegend')
    listen = true;
    argin(1) = [];
    nargs = nargs-1;
    if nargs==0
        return;
    end
end

% Get location strings long and short form. The short form is the
% long form without any of the lower case characters.
% hard code the enumeration values until we can query the datatype directly
locations = {'North','South','East', 'West','NorthEast','SouthEast','NorthWest','SouthWest','NorthOutside','SouthOutside','EastOutside','WestOutside','NorthEastOutside','SouthEastOutside','NorthWestOutside','SouthWestOutside','Best','BestOutside','none'};
locationAbbrevs = cell(1,length(locations));
for k=1:length(locations)
    str = locations{k};
    locationAbbrevs{k} = str(str>='A' & str<='Z');
end

% Loop over inputs and determine strings, handles and options
n = 1;
foundAllStrings = false;
while n <= nargs
    if matlab.internal.strfun.ischarlike(argin{n})
        switch lower(argin{n})
            case 'orientation'
                if n < nargs && matlab.internal.strfun.ischarlike(argin{n+1})
                    if strncmpi(argin{n+1}, 'hor', 3)
                        orient = 'horizontal';
                    elseif strncmpi(argin{n+1}, 'ver', 3)
                        orient = 'vertical';
                    else
                        error(message('MATLAB:legend:UnknownParameterOrientation'));
                    end
                else
                    error(message('MATLAB:legend:UnknownParameterOrientation'));
                end
                n = n+1; % skip orientation
            case 'location'
                if n < nargs && isnumeric(argin{n+1}) && length(argin{n+1})==4
                    % found 'Location', POS
                    position = argin{n+1};
                    location = 'none';
                elseif n < nargs && matlab.internal.strfun.ischarlike(argin{n+1})
                    locationCmp = strcmpi(argin{n+1}, locations);
                    abbrevsCmp = strcmpi(argin{n+1}, locationAbbrevs);
                    if any(locationCmp)
                        % found 'Location', LOC
                        location = char(argin{n+1});
                    elseif any(abbrevsCmp)
                        % found 'Location', ABBREV
                        location = locations{abbrevsCmp};
                    else
                        error(message('MATLAB:legend:UnknownParameterLocation'));
                    end
                else
                    error(message('MATLAB:legend:UnknownParameterLocation'));
                end
                n = n+1; % skip location
            otherwise
                if foundAllStrings && n < nargs
                    % found a PV pair
                    if ~strcmpi(argin{n}, 'UserData') && matlab.internal.strfun.ischarlike(argin{n+1})
                        argin{n+1} = char(argin{n+1});
                    end
                    propargs = [propargs, {char(argin{n})}, argin(n+1)]; %#ok<AGROW>
                    n = n+1;
                else
                    % found a string for legend entry
                    strings{end+1} = char(argin{n}); %#ok<AGROW> % single item string
                end
        end
    elseif isnumeric(argin{n}) && length(argin{n})==1 && mod(argin{n},1)==0
        warning(message('MATLAB:legend:InvalidLocationSpecifier'));
    elseif isnumeric(argin{n}) && length(argin{n})==4 && ...
            (n > 1 || ~all(ishghandle(argin{n})))
        % to use position vector either it must not be the first argument,
        % or if it is, then the values must not all be handles - in which
        % case the argument will be considered to be the plot children
        % This is an undocumented API for backwards compatibility with
        % Basic Fitting.
        position = argin{n};
        fig = ancestor(ax,'figure');
        position = hgconvertunits(fig,position,'points','normalized', fig);
        center = position(1:2)+position(3:4)/2;
        % .001 is a small number so that legend will resize to fit and centered
        position = [center-.001 0.001 0.001];
        location = 'none';
    elseif iscell(argin{n}) || isstring(argin{n})
        % found cell array of strings for legend entries
        if ~matlab.internal.strfun.iscellstrlike(argin{n})
            error(message('MATLAB:legend:InvalidCellParameter'));
        end
        strings = cellstr(argin{n});
        foundAllStrings = true;
    elseif n==1 && all(ishghandle(argin{n}))
        % found handles to put in legend
        % make sure to return objects, not doubles
        children=handle(argin{n});
    else
        error(message('MATLAB:legend:UnknownParameter'));
    end
    n = n + 1;
end
strings = strings(:).';

%----------------------------------------------------------------%
% args must be an even number of string,value pairs.
function check_pv_args(args)

n=length(args);
% check that every p is a property
for i=1:2:n
    metaClass = ?matlab.graphics.illustration.Legend;
    propNames = cellfun(@(x) (x.Name), metaClass.Properties, 'UniformOutput', false);
    if ~any(strcmpi(propNames,args{i}))
        error(message('MATLAB:legend:UnknownProperty', args{ i }));
    elseif strcmpi(args{i},'Parent')
        if ~ishghandle(args{i+1},'figure') && ~ishghandle(args{i+1},'uipanel')
            error(message('MATLAB:legend:InvalidParent', get(args{i+1},'Type')));
        end
    end
end

%----------------------------------------------------------------%
function validateLegendable(children)

% Objects input by user must be Legendable
if ~isempty(children)
    allLegendable = true;
    for i=1:numel(children)
        % isa operates on the class of the hetarray, not the individual
        % elements of the array.  So it cannot be used to check an array of
        % graphics objects against a mixin.
        if ~isa(children(i),'matlab.graphics.mixin.Legendable')
            allLegendable = false;
            break
        end
    end
    if ~allLegendable
        % @TODO - message catalog
        error(message('MATLAB:legend:ObjectsNotLegendable'));
    end
end

%----------------------------------------------------------------%
function [children, warnmsg] = getAutoChildren(ha)

warnmsg = [];
children = graph2dhelper ('get_legendable_children', ha);
% if still no children, warn and return empty
if isempty(children)
    warnmsg = message('MATLAB:legend:PlotEmpty');
    hfig=ancestor(ha,'figure');
    ltogg = uigettool(hfig,'Annotation.InsertLegend');
    if ~isempty(ltogg)
        set(ltogg,'State','off');
    end
end

%----------------------------------------------------------------%
function set_children_and_strings(hLeg,ch,str,auto_children)

auto_strings = false;
if isempty(str)
    auto_strings = true;
end

% expand strings if possible
if (length(ch) ~= 1) && (length(str) == 1) && (size(str{1},1) > 1)
    str = cellstr(str{1});
end
% if empty, create strings
if auto_strings
    if auto_children && length(ch) > 50,
        % only automatically add first 50 to cut down on huge lists
        ch = ch(1:50);
    end
    if numel(ch) == 1
        str = {get(ch,'DisplayName')};
    else
        str = get(ch,'DisplayName')';
    end
    startSubscript = 1;
    for k=1:length(ch)
        if isprop(ch(k),'DisplayName') &&...
                isempty(get(ch(k),'DisplayName'))
            % Let's reuse any available index, starting with 1.
            % If an object is deleted, it's DisplayName (e.g. dataX) may be reused
            % by the next Legendable object added to the scene.
            done = false;
            ss = startSubscript;
            while ~done
                tryStr = ['data',num2str(ss)];
                if ~ismember(tryStr,str)
                    str{k} = tryStr;
                    startSubscript = ss+1;
                    done = true;
                else
                    ss = ss + 1;
                end
            end
                      
            set(ch(k),'DisplayName_I',str{k});
            % @TODO as of 12b we set the DisplayName if it is empty
            % along with auto-label assignment.  This allows an
            % auto-assigned DisplayName to be persistent with the
            % Legendable object.  Eventually, this auto-assigning should be
            % the job of PLOT functions, not legend, but LEGEND needs
            % DisplayName to be persistent to support entry
            % synchronization.
        end
    end
else
    % trim children or strings
    if length(str) ~= length(ch)
        if ~auto_children || length(str) > length(ch)
            warning(message('MATLAB:legend:IgnoringExtraEntries'));
        end
        m = min(length(str),length(ch));
        ch = ch(1:m);
        str = str(1:m);
    end
    for k=1:length(ch)
        displayNameStr = deblank(str{k});
        % If the strings provided are a CHAR matrix, then we must split
        % them up using \n characters into a single char. g964785
        if ~isempty(displayNameStr) && ~isvector(displayNameStr)
            tempDisplayStr = deblank(displayNameStr(1,:));
            for l = 2:size(displayNameStr,1)
               tempDisplayStr = sprintf('%s\n%s', tempDisplayStr, deblank(displayNameStr(l,:)));
            end
            displayNameStr = tempDisplayStr;
        end
        ch(k).DisplayName = displayNameStr; 
    end
end
% str = deblank(str);
hLeg.PlotChildren_I = handle(ch);

%----------------------------------------------------------------%
function className = getClassName(obj)
% getClassName returns the class name with the package name omitted

className = class(obj);
idx = strfind(className,'.');
if ~isempty(idx)
    className = className(idx(end)+1:end);
end 

%----------------------------------------------------------------%
function [leg,labelhandles,outH,outM] = setOutArgs(arg)
[varargout{1:4}] = find_legend_info(arg);
    
if nargout > 0
    leg = varargout{1};
end
if nargout > 1
    labelhandles = varargout{2};
end
if nargout > 2
    outH = varargout{3};
end
if nargout > 3
    outM = varargout{4};
end

    
  
