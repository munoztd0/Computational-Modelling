% This function generates the likelihood of each model/paramters

function lik = compute_model_ll(params,con, output, rews,model)


ntrials = length(con); 


% parameters
b1 = params(1);           % softmax inverse temperature low
b2 = params(2);           % softmax inverse temperature high0
b3 = params(3);           % softmax inverse temperature hig1
lr = params(4);          % learning rate
lambda = params(5);      % eligibility trace decay
w1 = params(6);           % mixing weight low
w2 = params(7);           % mixing weight high0
w3 = params(8);           % mixing weight high1


% initialization
lik   = 0;
Qmf_top = zeros(1,3);
Qmf_middle = zeros(6,1);
Qmf_terminal = zeros(3,1);            
% Q(s,a): state-action value function for Q-learning





% loop through trials
for t = 1:length(con)
    
   if con(k) == 1  % high effort trial
        
        S = output.S;
        A = output.A;
        R = outpur.R;
        s1 = output.s1_stims
        % level 0
        
        Qmb_middle = zeros(3,2);
        
        for state = 1:3
            Qmb_middle(state,:) = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)*Qmf_terminal;   % find model-based values at stage 1
        end
                
        Qmb_top = subdata.Tm_top(subdata.stims0(t,:),:)*max(Qmb_middle,[],2);                           % find model-based values at stage 0
        
        Q_top = w_high0*Qmb_top' + (1-w_high0)*Qmf_top(subdata.stims0(t,:));                            % mix TD and model value
        action = subdata.choice0(t)==subdata.stims0(t,:);
        LL = LL + b_high0*Q_top(action)-logsumexp(b_high0*Q_top);
        
        % level 1
        stims1 = subdata.stims1(t,1:2);
        w = w_high1;
        b = b_high1;
        
    else % low effort trial
        
        stims1 = subdata.stims1(t,:);
        w = w_low;
        b = b_low;
        
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
    dtQ(3) = subdata.points(t) - Qmf_terminal(subdata.state2(t));
    Qmf_terminal(subdata.state2(t)) = Qmf_terminal(subdata.state2(t)) + lr*dtQ(3);
    Qmf_middle(subdata.choice1(t)) = Qmf_middle(subdata.choice1(t)) + lambda*lr*dtQ(3);
    if subdata.high_effort(t)==1
        Qmf_top(subdata.choice0(t)) = Qmf_top(subdata.choice0(t)) + (lambda^2)*lr*dtQ(3);
    end
    
end

%% Kool

% initialization
Qmf1 = zeros(1,3);
Qmf2 = zeros(3,2);
Qmf3 = zeros(3,1);                    % Q(s,a): state-action value function for Q-learning
Tm = cell(2,1);
Tm{1} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix
Tm{2}(:,:,1) = [1 0 0; 0 1 0];        % transition matrix
Tm{2}(:,:,2) = [1 0 0; 0 0 1];        % transition matrix
Tm{2}(:,:,3) = [0 1 0; 0 0 1];        % transition matrix
N = size(rews,1);
output.A = zeros(N,2);
output.R = zeros(N,1);
output.S = zeros(N,3);

Qmb2 = zeros(3,2);

% loop through trials
for t = 1:ntrials
    
    s1_stims = datasample(1:3,2,'Replace',false);
    
    Tm1 = Tm{1}(s1_stims,:); % temporary Tm1
    
    for state = 1:3
        Qmb2(state,:) = Tm{2}(:,:,state)*Qmf3;
    end
    
    disp(max(Qmb2,[],2))
    
    Qmb1 = Tm1*max(Qmb2,[],2);
    
    s(1) = 1;
    
    %% choices + updating
    % level 1
    
    Q = w*Qmb1' + (1-w)*Qmf1(s1_stims);               % mix TD and model value
    ps = exp(b*Q)/sum(exp(b*Q));                      %compute choice probabilities for each action
    action = find(rand<cumsum(ps),1);                 % choose
    a(1) = s1_stims(action);
    
    s(2) = find(Tm{1}(a(1),:));
    
    % level 2
    
    Q = w*Qmb2(s(2),:) + (1-w)*Qmf2(s(2),:);
    ps = exp(b*Q)/sum(exp(b*Q));                      %compute choice probabilities for each action
    a(2) = find(rand<cumsum(ps),1);                   % choose
    
    s(3) = find(Tm{2}(a(2),:,s(2)));
    
    % level 3
    
    reward = rews(t,s(3));
    
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
    output.A(t,:) = a;
    output.R(t,1) = rews(t,s(3));
    output.S(t,:) = s;
    output.s1_stims(t,:) = s1_stims;
        
end
end
% 
% function lik = compute_model_LL(params,s,a,r,model)
% 
%         %% Kool parameters %%%
% 
% %         b = x(1);           % softmax inverse temperature
% %         lr = x(2);          % learning rate
% %         lambda = x(3);      % eligibility trace decay
% %         w_low = x(4);           % mixing weight
% %         w_high0 = x(5);           % mixing weight
% %         w_high1 = x(6);           % mixing weight
% 
% 
% 
% beta1 = params(1);                                                              % choice temperature
% beta2 = params(2);
% lr1   = params(3);                                                             % supraliminal learning rate
% lr2   = params(4);                                                             % subliminal learning rate
% pi1   = params(5);
% pi2   = params(6);
% 
% Q     = zeros(1,2);
% 
% lik   = 0;
% prevC = rand>.5 +1;
% 
% pST = 0;
% pCT = 0;
% 
% for i = 1:length(a)
%     
%     
%     if a(i)
%                 
%         per = (prevC == a(i))*2-1;  % perseveration
%         dQ = Q(a(i)) - Q(3-a(i));
%         
%         PE =  r(i) - Q(a(i));
%         
%         ST = s(i)==1;
%         CT = s(i)==0;        
%         
%        if model==1
%             
%             lik = lik + log(1./(1+exp(-beta1 *dQ)));
%             Q(a(i)) = Q(a(i)) + lr1 * PE; % simple RL
%             
%        elseif model==2
%             
%             lik = lik + log(1./(1+exp(-beta1 *dQ)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1) * PE; % simple RL  
%             
%         elseif model==3
%             
%             lik = lik + log(1./(1+exp(-beta1 *dQ)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2) * PE ;  % RL with different LR for Sub and consc 
%             
%         elseif model==4
%             
%             lik = lik + log(1./(1+exp(-beta1 *dQ - pi1*per)));
%             Q(a(i)) = Q(a(i)) + lr1 * PE; % simple RL
%             
%        elseif model==5
%             
%             lik = lik + log(1./(1+exp(-beta1 *dQ - pi1*per)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1).* PE; % simple RL 
% 
%         elseif model==6
%             
%             lik = lik + log(1./(1+exp(-beta1 *dQ - pi1*per)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
% 
%         elseif model==7
%             
%             lik = lik + log(1./(1+exp(-beta1 *dQ - (pi1*pCT + pi2*pST)*per)));
%             Q(a(i)) = Q(a(i)) + lr1.* PE; % simple RL
%        
%        elseif model==8
%             
%             lik = lik + log(1./(1+exp(-beta1 *dQ - (pi1*pCT + pi2*pST)*per)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1).* PE; % simple RL
%             
%         elseif model==9
%             
%             lik = lik + log(1./(1+exp(-beta1 *dQ - (pi1*pCT + pi2*pST)*per)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
%             
%        elseif model==10
%             
%             lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ)));
%             Q(a(i)) = Q(a(i)) + lr1 * PE; % simple RL
%             
%        elseif model==11
%             
%             lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1) * PE; % simple RL
%             
%         elseif model==12
%             
%             lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2) * PE ;  % RL with different LR for Sub and consc
%             
%         elseif model==13
%             
%             lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - pi1*per)));
%             Q(a(i)) = Q(a(i)) + lr1 * PE; % simple RL
%             
%        elseif model==14
%             
%             lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST)*dQ - pi1*per)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1).* PE; % simple RL
% 
%         elseif model==15
%             
%             lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - pi1*per)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
% 
%         elseif model==16
%             
%             lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - (pi1*pCT + pi2*pST)*per)));
%             Q(a(i)) = Q(a(i)) + lr1.* PE; % simple RL
%        
%        elseif model==17
%             
%             lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - (pi1*pCT + pi2*pST)*per)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1).* PE; % simple RL
%             
%         elseif model==18
%             
%             lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - (pi1*pCT + pi2*pST)*per)));
%             Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
%             
%        end
%        
%             prevC = a(i);
%             pCT = CT;
%             pST = ST;
%         
%     end
% end
% 
% lik = -lik;                                                                               % loglikelyhood vector
