%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright � 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function EEG = resetflag(EEG, bflag)

% flag = binario converted to decimal.
% for instance, flag = 5  means  reseting for flags 1 and flag 3  (xxxxxxxxxxxxx0x0)

if nargin==1
        bflag = 65353; % reset all flags
end

if ~isfield(EEG, 'EVENTLIST')
        error('EVENTLIST structure was not found!')
end
if ~isfield(EEG.EVENTLIST, 'eventinfo')
        error('eventinfo field was not found!')
end
if isempty(EEG.EVENTLIST.eventinfo)
        error('eventinfo field is empty!')
end

if isfield(EEG.event,'flag')
        fprintf('\nWARNING: The flag field also exist at EEG.event.\n')
        fprintf('But it was not reseted by this function. Please, use update_EEG_event_field.m in case you need it\n')
end

fin   = length(EEG.EVENTLIST.eventinfo);

if bflag==65535
        flagM  = num2cell(zeros(1,fin));
        [EEG.EVENTLIST.eventinfo(1:fin).flag] = flagM{:};

elseif bflag<65535 && bflag>0
        rbit =  num2cell(bitand([EEG.EVENTLIST.eventinfo(1:fin).flag], 65535-bflag));
        [EEG.EVENTLIST.eventinfo(1:fin).flag] = rbit{:};
end

%
% Update flags at EEG.epoch (if any)
%
if isfield(EEG,'epoch')
        if ~isempty(EEG.epoch)
                for i=1:EEG.trials
                        if length(EEG.epoch(i).eventlatency) == 1

                                itemx = cell2mat(EEG.epoch(i).eventitem);
                                EEG.epoch(i).eventflag = {EEG.EVENTLIST.eventinfo(itemx).flag};

                        elseif length(EEG.epoch(i).eventlatency) > 1

                                nitem = length(EEG.epoch(i).eventitem);

                                for t=1:nitem
                                        itemx = EEG.epoch(i).eventitem{t};
                                        EEG.epoch(i).eventflag{t} = EEG.EVENTLIST.eventinfo(itemx).flag;
                                end
                        else
                                error(['ERPLAB: There was not latency at the epoch ' num2str(i)])
                        end
                end
        end
end

fprintf('Flags were resetted.')