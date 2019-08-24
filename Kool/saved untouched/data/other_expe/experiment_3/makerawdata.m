function groupdata = makerawdata

% This function takes the raw data and turns it into a matlab structure
% with the behavior and trial information for each participant in a
% separate field.

load subinfo
load data

nrsubs = size(subinfo,1);

for s = 1:nrsubs
    
    trials = cell2mat(data(strcmp(cellstr(data(:,1)),cellstr(subinfo(s,1))),2:25));
    firsttrial  = trials(1,:);
    trials(trials(:,19)==1,:) = []; % throwout practice
    
    subdata.id = subinfo(s,1);
    subdata.gender = subinfo(s,3);
    subdata.age = cell2mat(subinfo(s,2));
    
    subdata.N = size(trials,1);
    
    subdata.high_effort = trials(:,1);
    subdata.state0 = trials(:,2);
    subdata.stim_0_1 = trials(:,3);
    subdata.stim_0_2 = trials(:,4);
    subdata.stims0 = trials(:,3:4);
    subdata.rt0 = trials(:,5);
    subdata.choice0 = trials(:,6);
    subdata.response0 = trials(:,7);
    subdata.state1 = trials(:,8);
    subdata.stim_1_1 = trials(:,9);
    subdata.stim_1_2 = trials(:,10);
    subdata.stim_1_3 = trials(:,11);
    subdata.stims1 = trials(:,9:11);
    subdata.rt1 = trials(:,12);
    subdata.choice1 = trials(:,13);
    subdata.response1 = trials(:,14);
    subdata.rt2 = trials(:,15);
    subdata.win = trials(:,16);
    subdata.state2 = trials(:,17);
    subdata.score = trials(:,18);
    subdata.practice = trials(:,19);
    subdata.probs1 = trials(:,20);
    subdata.probs2 = trials(:,21);
    subdata.probs3 = trials(:,22);
    subdata.probs = trials(:,20:22);
    subdata.trial_number = trials(:,23);
    subdata.time_elapsed = trials(:,24);
    
    subdata.rocket_order = cell2mat(subinfo(s,5:10));
    
    subdata.Tm_top = crosstab(subdata.choice0(subdata.high_effort==1&subdata.choice0~=-1), ...
        subdata.state1(subdata.high_effort==1&subdata.choice0~=-1))>0;
    subdata.Tm_middle = crosstab(subdata.choice1(subdata.choice1~=-1),subdata.state2(subdata.choice1~=-1))>0;
    
    subdata.middle_stims{1} = [subdata.rocket_order(1) subdata.rocket_order(2) subdata.rocket_order(3);
        subdata.rocket_order(4) subdata.rocket_order(5) subdata.rocket_order(6)];
    subdata.middle_stims{2} = [subdata.rocket_order(1) subdata.rocket_order(5);
        subdata.rocket_order(2) subdata.rocket_order(6);
        subdata.rocket_order(3) subdata.rocket_order(4)];
    
    subdata.missed = subdata.rt2==-1;
    
    subdata.tasktime = (subdata.time_elapsed(200)-subdata.time_elapsed(1))/1000/60;
    subdata.beforepracticetime = firsttrial(1,24)/1000/60;
    subdata.instructiontime = (subdata.time_elapsed(1))/1000/60;
    subdata.totaltime = (subdata.time_elapsed(200))/1000/60;
    
    subdata.loweffort_errors = cell2mat(subinfo(s,11));
    subdata.higheffort_errors = cell2mat(subinfo(s,12));
    
    groupdata.subdata(s) = subdata;
    
end

end

