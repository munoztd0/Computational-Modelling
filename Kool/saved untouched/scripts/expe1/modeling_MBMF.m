function  LL = MBMF_complexity_llik(x,subdata)

dbstop if error
% Loglikelihood function for Experiment 1

% parameters
b = x(1);           % softmax inverse temperature
lr = x(2);          % learning rate
lambda = x(3);      % eligibility trace decay
w_low = x(4);           % mixing weight
w_high0 = x(5);           % mixing weight
w_high1 = x(6);           % mixing weight

% initialization
% Q(s,a): state-action value function for Q-learning for different stages
Qmf_top = zeros(1,3);
Qmf_middle = zeros(6,1);
Qmf_terminal = zeros(3,1);

LL = 0;

% loop through trials
for t = 1:length(subdata.choice0)
    
    if subdata.missed(t) == 1 %if missed =1 it skips the iteration loop to the next one
        continue
    end
    
    %% likelihoods
    if subdata.high_effort(t)==1 % high effort trial
        % level 0
        
        Qmb_middle = zeros(3,2);
        for state = 1:3  %% index the 3 rows
            Qmb_middle(state,:) = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)*Qmf_terminal;   % find model-based values at stage 1
        end
        %# middle_stim{2} because 2nd column is for high effort
        % subdata.Tm_middle(subdata.middle_stims{2}(state,:),:) # this
        % takes the nth (state) row of the middle_stims{2} which then take
        % does input (e.g. 6 1) as indexes for choosing which row from Tm_middle
               
        
        Qmb_top = subdata.Tm_top(subdata.stims0(t,:),:)*max(Qmb_middle,[],2); %# maximun of each row 
        % find model-based values at stage 0
        %# same principle than above
        
        Q_top = w_high0*Qmb_top' + (1-w_high0)*Qmf_top(subdata.stims0(t,:)); %# output to proba                           % mix TD and model value
        action = subdata.choice0(t)==subdata.stims0(t,:); %# which one did it choose at S=0
        LL = LL + b*Q_top(action)-logsumexp(b*Q_top); %# LogLik
        %# only for high effort top
        
        % level 1
        stims1 = subdata.stims1(t,1:2); %# because there is only 2 rockets in high effort
        w = w_high1;
        
    else % low effort trial
        
        stims1 = subdata.stims1(t,:);
        w = w_low;
        %# stim1 exist only for low effort
    end
    
    % level 1 for both
    Qmb_middle = subdata.Tm_middle(stims1,:)*Qmf_terminal;                     % find model-based values at stage 0
    Q_middle = w*Qmb_middle + (1-w)*Qmf_middle(stims1);                        % mix TD and model value
    action = subdata.choice1(t)==stims1;
    LL = LL + b*Q_middle(action)-logsumexp(b*Q_middle);
    
    
    %% updating %# for MF
    
    dtQ = zeros(3,1); 
    
    if subdata.high_effort(t)==1
        % top level
        dtQ(1) = Qmf_middle(subdata.choice1(t)) - Qmf_top(subdata.choice0(t)); %# delta rule
        Qmf_top(subdata.choice0(t)) = Qmf_top(subdata.choice0(t)) + lr*dtQ(1);
    end
    
    %middle level
    dtQ(2) = Qmf_terminal(subdata.state2(t)) - Qmf_middle(subdata.choice1(t));
    Qmf_middle(subdata.choice1(t)) = Qmf_middle(subdata.choice1(t)) + lr*dtQ(2);
    if subdata.high_effort(t)==1
        Qmf_top(subdata.choice0(t)) = Qmf_top(subdata.choice0(t)) + lambda*lr*dtQ(2);
    end
    
    %terminal level
    dtQ(3) = subdata.points(t) - Qmf_terminal(subdata.state2(t)); %# Reward - Expected value of action
    Qmf_terminal(subdata.state2(t)) = Qmf_terminal(subdata.state2(t)) + lr*dtQ(3);
    Qmf_middle(subdata.choice1(t)) = Qmf_middle(subdata.choice1(t)) + lambda*lr*dtQ(3);
    if subdata.high_effort(t)==1
        Qmf_top(subdata.choice0(t)) = Qmf_top(subdata.choice0(t)) + (lambda^2)*lr*dtQ(3);
    end
    
end

end
