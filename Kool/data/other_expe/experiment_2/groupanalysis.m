function groupdata = groupanalysis

groupdata = makerawdata(1/9);

nrsubs = length(groupdata.subdata);

s = 0;

for i = 1:nrsubs
    
    subdata = groupdata.subdata(i);
    
    groupdata.gender(i,1) = subdata.gender;
    groupdata.age(i,1) = subdata.age;
    
    if mean(subdata.missed) < 0.2  % throw out participants with more than >20% trials missed
        
        s = s + 1;
        groupdata.i(s,1) = i;
        
        groupdata.id(s,1) = subdata.id;
        
        groupdata.instructiontime(s,1) = subdata.instructiontime; % time it took to read instructions
        groupdata.tasktime(s,1) = subdata.tasktime; % time it took to complete main task
        groupdata.totaltime(s,1) = subdata.totaltime; % total time in experiment
        
        groupdata.missed(s,1) = mean(subdata.missed); % percentage of timed out trials
        groupdata.nrtrials(s,1) = length(subdata.missed); % number of trials
        
        groupdata.rewardrate(s,1) = mean(subdata.points((~subdata.missed&~subdata.probe_trial))) - mean(mean(subdata.rews(~subdata.probe_trial,:))); % average reward rate (corrected by chance performance)
        
        groupdata.practice_errors(s,1) = subdata.loweffort_errors; % number of low effort practice errors
        groupdata.practice_errors(s,2) = subdata.higheffort_errors; % number of high effort practice errors
        
        %% probe accuracy
        
        % lo accuracy
        groupdata.lo_probe_acc(s,1) = mean(subdata.probe_target(subdata.probe_trial&~subdata.probe_effort&~(subdata.rt1==-1))==subdata.state2(subdata.probe_trial&~subdata.probe_effort&~(subdata.rt1==-1)));

        % hi accuracy
        reachable_states = zeros(3,2);
        for a = 1:3
            middle_state = subdata.Tm_top(a,:); % find middle state for current action
            middle_actions = subdata.middle_stims{2}(middle_state,1:2);
            reachable_states(a,1) = find(subdata.Tm_middle(middle_actions(1),:));
            reachable_states(a,2) = find(subdata.Tm_middle(middle_actions(2),:));
        end
                
        higheffort_probe_trials = find(subdata.probe_trial&subdata.probe_effort&~(subdata.rt0==-1));
        
        score = 0;
        for j = 1:length(higheffort_probe_trials)
            t = higheffort_probe_trials(j);
            if ismember(subdata.probe_target(t),reachable_states(subdata.choice0(t),:))
                score = score+1;
            end
        end
        
        groupdata.hi_probe_acc(s,1) = score/length(higheffort_probe_trials);
        
    end
    
end

end

