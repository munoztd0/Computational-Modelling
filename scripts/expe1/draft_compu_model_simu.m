% This function generates the likelihood of each model/paramters

function [PE,pc,Q,ch,r] = compute_model_simu(params,s,b,model)


%% Parameters
% beta1 = params(1);                                                             % choice temperature
% beta2 = params(2);                                                             % choice temperature
% lr1   = params(3);                                                             % supraliminal learning rate
% lr2   = params(4);                                                             % subliminal learning rate
% pi1   = params(5);
% pi2   = params(6);

ntrials = length(s); 


% parameters
b1 = params(1);           % softmax inverse temperature low
b2 = params(2);           % softmax inverse temperature high0
b3 = params(3);           % softmax inverse temperature hig1
lr = params(4);          % learning rate
lambda = params(5);      % eligibility trace decay
w1 = params(6);           % mixing weight low
w2 = params(7);           % mixing weight high0
w3 = params(7);           % mixing weight high1

% x = params
% s = con 
% b = cor 
% mod = model

%% Kool

%function  output = MBMF_high_effort_arm_sim(x,rews)

% parameters
% b = x(1);           % softmax inverse temperature
% lr = x(2);          % learning rate
% lambda = x(3);      % eligibility trace decay
% w = x(4);           % mixing weight

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
% end
% 
% 
% %% pre-Allocate
% choice0 = randi([1 3],200,1);
% choice1 = randi([1 6],200,1);
% 
% condition = s;
% 
% state2 = randi([1 3],200,1);
% 
% %points payoffs of these mines changed over the course of the experiment according to independent random walks. 
% %One of the alien's reward distributions was initialized randomly within a range of 1–3 points, one within a range of 4–6 points, and the last within a range of 7–9 points. They then drifted according to a Gaussian random walk (σ = 2), with reflecting bounds at 0 and 9 
% 
% 
% %% pre alocate  Mael
% Q    = zeros(ntrials,2);
% ch   = NaN(ntrials,1);
% pc   = NaN(ntrials,1);                % the likelihood of the observed choice
% PE   = NaN(ntrials,1);
% r    = NaN(ntrials,1);
% per  = NaN(ntrials,1);
% dQ   = NaN(ntrials,1);
% 
% %% initialization
% dtQ = zeros(3,1);
% Qmf_top = zeros(1,3);
% Qmf_middle = zeros(6,1);
% Qmf_terminal = zeros(3,1);            
% % Q(s,a): state-action value function for Q-learning
% 
% LL = 0;
% 
% %% loop through trials
% for k = 1:length(ntrials)
%     
%     if model ==1
%         
%         %dtQ = zeros(3,1);
%         
% %         pc(k) = (1./(1+exp(-beta1 *dQ(k)))); softmax?
% %         
% %         choice0(k)   = 2 - (rf1(k) < pc(k));
% %         rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
% %         r(k)    =  rwd*2-1;
% %         PE(k)   =  r(k) - Q(k,ch(k));
% %         
% %         Q(k+1,ch(k)) = Q(k,ch(k)) + lr1 * PE(k);
% %     
%         if condition(k)==1
%             % top level
%             dtQ(1) = Qmf_middle(choice1(k)) - Qmf_top(choice0(k));
%             Qmf_top(choice0(k)) = Qmf_top(choice0(k)) + lr*dtQ(1);
%         end
% 
%         %middle level
%         dtQ(2) = Qmf_terminal(state2(k)) - Qmf_middle(choice1(k));
%         Qmf_middle(choice1(k)) = Qmf_middle(choice1(k)) + lr*dtQ(2);
%         if subdata.high_effort(t)==1
%             Qmf_top(choice0(k)) = Qmf_top(choice0(k)) + lambda*lr*dtQ(2);
%         end
% 
%         %terminal level
%         dtQ(3) = subdata.points(t) - Qmf_terminal(state2(k));
%         Qmf_terminal(state2(k)) = Qmf_terminal(state2(k)) + lr*dtQ(3);
%         Qmf_middle(choice1(k)) = Qmf_middle(choice1(k)) + lambda*lr*dtQ(3);
%         if subdata.high_effort(t)==1
%             Qmf_top(choice0(k)) = Qmf_top(choice0(k)) + (lambda^2)*lr*dtQ(3);
%         end
%         
%     elseif model ==6
%         % shoud be w =0; %MF
%         if s(k)==1 % high effort trial
%             % level 0
% 
%             Qmb_middle = zeros(3,2);
% 
%             for state = 1:3
%                 Qmb_middle(state,:) = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)*Qmf_terminal;   % find model-based values at stage 1
%             end
% 
%             Qmb_top = subdata.Tm_top(subdata.stims0(k,:),:)*max(Qmb_middle,[],2);                           % find model-based values at stage 0
% 
%             Q_top = w2*Qmb_top' + (1-w2)*Qmf_top(subdata.stims0(k,:));                            % mix TD and model value
%             action = subdata.choice0(k)==subdata.stims0(k,:);
%             LL = LL + b2*Q_top(action)-logsumexp(b2*Q_top);
% 
%             % level 1
%             stims1 = subdata.stims1(k,1:2);
%             w = w3;
%             b = b3;
% 
%         else % low effort trial
% 
%             stims1 = subdata.stims1(k,:);
%             w = w1;
%             b = b1;
% 
%         end
% 
%         % level 1
%         Qmb_middle = subdata.Tm_middle(stims1,:)*Qmf_terminal;                     % find model-based values at stage 0
%         Q_middle = w*Qmb_middle + (1-w)*Qmf_middle(stims1);                        % mix TD and model value
%         action = subdata.choice1(k)==stims1;
%         LL = LL + b*Q_middle(action)-logsumexp(b*Q_middle);
% 
% 
%         %% updating
% 
%         dtQ = zeros(3,1);
% 
%         if subdata.high_effort(k)==1
%             % top level
%             dtQ(1) = Qmf_middle(subdata.choice1(k)) - Qmf_top(subdata.choice0(k));
%             Qmf_top(subdata.choice0(k)) = Qmf_top(subdata.choice0(k)) + lr*dtQ(1);
%         end
% 
%         %middle level
%         dtQ(2) = Qmf_terminal(subdata.state2(k)) - Qmf_middle(subdata.choice1(k));
%         Qmf_middle(subdata.choice1(k)) = Qmf_middle(subdata.choice1(k)) + lr*dtQ(2);
%         if subdata.high_effort(k)==1
%             Qmf_top(subdata.choice0(k)) = Qmf_top(subdata.choice0(k)) + lambda*lr*dtQ(2);
%         end
% 
%         %terminal level
%         dtQ(3) = subdata.points(k) - Qmf_terminal(subdata.state2(k));
%         Qmf_terminal(subdata.state2(k)) = Qmf_terminal(subdata.state2(k)) + lr*dtQ(3);
%         Qmf_middle(subdata.choice1(k)) = Qmf_middle(subdata.choice1(k)) + lambda*lr*dtQ(3);
%         if subdata.high_effort(k)==1
%             Qmf_top(subdata.choice0(k)) = Qmf_top(subdata.choice0(k)) + (lambda^2)*lr*dtQ(3);
%         end
%     
%     
%     
%     elseif model ==2
%         
%         w=0; %MB
%     
%     elseif model ==3
%         
%         w=0; %MF
%         
%     elseif model ==4
%         
%         w=1; %MB
%     
%     elseif model ==6
%         
%     end    
%             
% end
% 
% end
