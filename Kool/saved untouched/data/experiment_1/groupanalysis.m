function groupdata = groupanalysis

groupdata = makerawdata(1/9);

nrsubs = length(groupdata.subdata);

s = 0;

for i = 1:nrsubs
    
    subdata = groupdata.subdata(i);
    
    groupdata.gender(i,1) = subdata.gender;
    groupdata.age(i,1) = subdata.age;
    
    if mean(subdata.missed) < 0.2 % throw out participants with more than >20% trials missed
        
        s = s + 1;
        groupdata.i(s,1) = i;
        
        groupdata.id(s,1) = subdata.id;
        
        groupdata.instructiontime(s,1) = subdata.instructiontime; % time it took to read instructions
        groupdata.tasktime(s,1) = subdata.tasktime; % time it took to complete main task
        groupdata.totaltime(s,1) = subdata.totaltime; % total time in experiment
        
        groupdata.missed(s,1) = mean(subdata.missed); % percentage of timed out trials
        groupdata.nrtrials(s,1) = length(subdata.missed); % number of trials

        groupdata.rewardrate(s,1) = mean(subdata.points((~subdata.missed))) - mean(subdata.rews(:)); % average reward rate (corrected by chance performance)
        
    end
    
end
    

end

