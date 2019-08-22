function  LL = MBMF_complexity_llik(x,subdata)

% parameters
b = x(1);           % softmax inverse temperature
lr = x(2);          % learning rate
lambda = x(3);      % eligibility trace decay
w_low = x(4);           % mixing weight
w_high0 = x(5);           % mixing weight
w_high1 = x(6);           % mixing weight

% initialization
Qmf_top = zeros(1,3);
Qmf_middle = zeros(6,1);
Qmf_terminal = zeros(3,1);            % Q(s,a): state-action value function for Q-learning

LL = 0;

% loop through trials
for t = 1:length(subdata.choice0)
    
    if subdata.missed(t) == 1
        continue
    end
    
    %% likelihoods
    if subdata.high_effort(t)==1 % high effort trial
        % level 0
        
        Qmb_middle = zeros(3,2);
        
        for state = 1:3
            Qmb_middle(state,:) = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)*Qmf_terminal;   % find model-based values at stage 1
        end
                
        Qmb_top = subdata.Tm_top(subdata.stims0(t,:),:)*max(Qmb_middle,[],2);                           % find model-based values at stage 0
        
        Q_top = w_high0*Qmb_top' + (1-w_high0)*Qmf_top(subdata.stims0(t,:));                            % mix TD and model value
        action = subdata.choice0(t)==subdata.stims0(t,:);
        LL = LL + b*Q_top(action)-logsumexp(b*Q_top);
        
        % level 1
        stims1 = subdata.stims1(t,1:2);
        w = w_high1;
        
    else % low effort trial
        
        stims1 = subdata.stims1(t,:);
        w = w_low;
        
    end
    
    % level 1
    Qmb_middle = subdata.Tm_middle(stims1,:)*Qmf_terminal;                     % find model-based values at stage 0
    Q_middle = w*Qmb_middle + (1-w)*Qmf_middle(stims1);                        % mix TD and model value
    action = subdata.choice1(t)==stims1;
    LL = LL + b*Q_middle(action)-logsumexp(b*Q_middle);
    
    
    %% updating
    
    dtQ = zeros(3,1);
    
    if subdata.high_effort(t)==1
        % top level
        dtQ(1) = Qmf_middle(subdata.choice1(t)) - Qmf_top(subdata.choice0(t));
        Qmf_top(subdata.choice0(t)) = Qmf_top(subdata.choice0(t)) + lr*dtQ(1);
    end
    
    %middle level
    dtQ(2) = Qmf_terminal(subdata.state2(t)) - Qmf_middle(subdata.choice1(t));
    Qmf_middle(subdata.choice1(t)) = Qmf_middle(subdata.choice1(t)) + lr*dtQ(2);
    if subdata.high_effort(t)==1
        Qmf_top(subdata.choice0(t)) = Qmf_top(subdata.choice0(t)) + lambda*lr*dtQ(2);
    end
    
    %terminal level
    dtQ(3) = subdata.win(t) - Qmf_terminal(subdata.state2(t));
    Qmf_terminal(subdata.state2(t)) = Qmf_terminal(subdata.state2(t)) + lr*dtQ(3);
    Qmf_middle(subdata.choice1(t)) = Qmf_middle(subdata.choice1(t)) + lambda*lr*dtQ(3);
    if subdata.high_effort(t)==1
        Qmf_top(subdata.choice0(t)) = Qmf_top(subdata.choice0(t)) + (lambda^2)*lr*dtQ(3);
    end
    
end

end
