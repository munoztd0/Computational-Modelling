function output = C_ii_MBMF_sim(params, c, rews, model) %taking out b
% This function should generates the likelihood of each model/paramters
ntrials = length(c);

LL = 0;

if model == 1
    
    % parameters model 1
    b = params(1);           % softmax inverse temperature
    lr = params(4);          % learning rate
    lambda = params(5);      % eligibility trace decay
    w = 0; %x(4);           % mixing weight
    
    % initialization high
    Qmf1 = zeros(1,3);
    Qmf2 = zeros(3,2);
    Qmf3 = zeros(3,1);                    % Q(s,a): state-action value function for Q-learning
    Tm = cell(2,1);
    Tm{1} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix
    Tm{2}(:,:,1) = [1 0 0; 0 1 0];        % transition matrix
    Tm{2}(:,:,2) = [1 0 0; 0 0 1];        % transition matrix
    Tm{2}(:,:,3) = [0 1 0; 0 0 1];        % transition matrix

    output.high.A = zeros(ntrials,2);
    output.high.R = zeros(ntrials,1);
    output.high.S = zeros(ntrials,3);

    Qmb2 = zeros(3,2);


    
    
    % initialization low
    Qmf = zeros(2,3);
    Q2 = zeros(3,1);                      % Q(s,a): state-action value function for Q-learning
    Tm_low{1} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix
    Tm_low{2} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix

    output.low.A = zeros(ntrials,2);
    output.low.R = zeros(ntrials,1);
    output.low.S = zeros(ntrials,2);
    
    for k = 1:ntrials 
        
        s1_stims = datasample(1:3,2,'Replace',false);
        
        %high effort
        if c(k) == 1 
            
            Tm1 = Tm{1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2(s,:) = Tm{2}(:,:,s)*Qmf3;
            end
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            Qmb1 = Tm1*max(Qmb2,[],2);

            s(1) = 1;
            
  

            %% choices + updating
            % level 0
            Q = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
            ps = exp(b*Q)/sum(exp(b*Q));                      %compute choice probabilities for each action
            action = find(rand<cumsum(ps),1);                 % choose

            a(1) = s1_stims(action);
            LL = LL + b*Q(a(1))-logsumexp(b*Q);

            s(2) = find(Tm{1}(a(1),:));
            
            %bug here
           
            % level 1

            Q = w*Qmb2(s(2),:) + (1-w)*Qmf2(s(2),:);
            ps = exp(b*Q)/sum(exp(b*Q));                      %compute choice probabilities for each action
            a(2) = find(rand<cumsum(ps),1);                   % choose
            
            LL = LL + b*Q(a(2))-logsumexp(b*Q);
            
            s(3) = find(Tm{2}(a(2),:,s(2)));

            % level 2

            reward = rews(k,s(3));

            %% updating
            % level 1
            dtQ(1) = Qmf2(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);

            % level 2
            dtQ(2) = Qmf3(s(3)) - Qmf2(s(2),a(2));
            Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lr*dtQ(2);
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);

            % level 3
            dtQ(3) = reward - Qmf3(s(3));
            Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
            Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lambda*lr*dtQ(3);
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);

            %% store stuff
            output.high.A(k,:) = a;
            output.high.R(k,1) = rews(k,s(3));
            output.high.S(k,:) = s;
            output.high.s1_stims(k,:) = s1_stims;
            
            %action = a==s1_stims;
            
%             Qmb_middle = Tm{2}*Qmf3;   
%             Q_middle = w*Qmb2 + (1-w)*Qmf2(s1_stims); %s1_stims);    
%             lik = lik + b*Q_middle(action)-logsumexp(b*Q_middle);
%             Q(action) = Q(action) + lr * dtQ(3); % simple RL  
            
%             Qmb_middle = subdata.Tm_middle(stims1,:)*Qmf_terminal;                     % find model-based values at stage 0
%             Q_middle = w*Qmb_middle + (1-w)*Qmf_middle(stims1);                        % mix TD and model value
%             action = subdata.choice1(t)==stims1;
%             LL = LL + b*Q_middle(action)-logsumexp(b*Q_middle);


        else
            %low effort

            s1 = ceil(rand*2);

            Qmb = Tm_low{s1}*Q2;                          % compute model-based value function

            Q = w*Qmb + (1-w)*Qmf(s1,:)';                 % mix TD and model value

            ps = exp(b*Q)/sum(exp(b*Q));                  % compute choice probabilities for each action
            a = find(rand<cumsum(ps),1);                  % choose

            s2 = a;

            dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
            Qmf(s1,a) = Qmf(s1,a) + lr*dtQ(1);            % update TD value function

            dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)

            Q2(s2) = Q2(s2) + lr*dtQ(2);                  % update TD value function
            Qmf(s1,a) = Qmf(s1,a) + lambda*lr*dtQ(2);     % eligibility trace

            % store stuff
            output.low.A(k,1) = a;
            output.low.R(k,1) = rews(k,s2);
            output.low.S(k,:) = [s1 s2];
            
%             lik = lik + b*Qmd2(a)-logsumexp(b*Qmf2);
%             Q(a) = Q(a) + lr * PE; % simple RL  



           
        end     
        

        
%         Qmb_middle = subdata.Tm_middle(stims1,:)*Qmf_terminal;                     % find model-based values at stage 0
%         Q_middle = w*Qmb_middle + (1-w)*Qmf_middle(stims1);                        % mix TD and model value
%         action = subdata.choice1(t)==stims1;
%         LL = LL + b*Q_middle(action)-logsumexp(b*Q_middle);

    end
    
    
  end

end




