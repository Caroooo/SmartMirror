function [ reminders ] = get_reminders( pname ) 
%
% get_reminders.m - Function returns the reminder messages for the
%                   input person
%
% Input: pname - person for whom messages need to be retrieved
%
% Output: reminders - cell array of stored reminders
%
%% Read stored reminders
fname=fopen('reminder.txt');
frecord=textscan(fname,'%s %s %s %s %s','Delimiter',',');
fclose(fname);

%% Find relevant reminders
numrows=max(cellfun('size',frecord,1));
reminders={};
reminder_count=0;
for i=1:numrows
    rname=upper(frecord{1}{i});
    tf=strcmp(pname,rname);
    if tf
        ptype=frecord{2}{i};
        pdow=frecord{3}{i};
        pday=frecord{4}{i};
        pmessage=frecord{5}{i};
        % Daily Reminders
        if ptype=='1'
            reminder_count=reminder_count+1;
            reminders{reminder_count}=pmessage;
        end
        % Weekly Reminders
        if ptype=='2'
            [DayNumber]=weekday(date);
            if DayNumber==pdow
                reminder_count=reminder_count+1;
                reminders{reminder_count}=pmessage;
            end
        end
        % Monthly Reminders
        if ptype=='3'
            [Day]=day(date);
            if num2str(Day)==pday
                reminder_count=reminder_count+1;
                reminders{reminder_count}=pmessage;
            end
        end
    end
end