function  output = MBMF_high_effort_top_arm_sim(x,probs)

% parameters
b = x(1);           % softmax inverse temperature
lr = x(2);          % learning rate
lambda = x(3);      % eligibility trace decay
w_hi_top = x(4);    % mixing weight
w_hi_mid = 0.5;     % mixing weight

% initialization
Qmf1 = zeros(1,3);
Qmf2 = zeros(3,2);
Qmf3 = zeros(3,1);                    % Q(s,a): state-action value function for Q-learning
Tm = cell(2,1);
Tm{1} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix
Tm{2}(:,:,1) = [1 0 0; 0 1 0];        % transition matrix
Tm{2}(:,:,2) = [1 0 0; 0 0 1];        % transition matrix
Tm{2}(:,:,3) = [0 1 0; 0 0 1];        % transition matrix
N = size(probs,1);
output.A = zeros(N,2);
output.R = zeros(N,1);
output.S = zeros(N,3);

Qmb2 = zeros(3,2);

% loop through trials
for t = 1:N
    
    s1_stims = datasample(1:3,2,'Replace',false);
    
    Tm1 = Tm{1}(s1_stims,:); % temporary Tm1
    
    for state = 1:3
        Qmb2(state,:) = Tm{2}(:,:,state)*Qmf3;
    end
    
    Qmb1 = Tm1*max(Qmb2,[],2);
    
    s(1) = 1;
    
    %% choices + updating
    % level 1
    
    Q = w_hi_top*Qmb1' + (1-w_hi_top)*Qmf1(s1_stims);       % mix TD and model value
    ps = exp(b*Q)/sum(exp(b*Q));                            % compute choice probabilities for each action
    action = find(rand<cumsum(ps),1);                       % choose
    a(1) = s1_stims(action);
    
    s(2) = find(Tm{1}(a(1),:));
    
    % level 2
    
    Q = w_hi_mid*Qmb2(s(2),:) + (1-w_hi_mid)*Qmf2(s(2),:);
    ps = exp(b*Q)/sum(exp(b*Q));                            % compute choice probabilities for each action
    a(2) = find(rand<cumsum(ps),1);                         % choose
    
    s(3) = find(Tm{2}(a(2),:,s(2)));
    
    % level 3
    
    r = rand < probs(t,s(3));
    
    %% updating
    % level 1
    dtQ(1) = Qmf2(s(2),a(2)) - Qmf1(a(1));
    Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
    
    % level 2
    dtQ(2) = Qmf3(s(3)) - Qmf2(s(2),a(2));
    Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lr*dtQ(2);
    Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
    
    % level 3
    dtQ(3) = r - Qmf3(s(3));
    Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
    Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lambda*lr*dtQ(3);
    Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
    
    %% store stuff
    output.A(t,:) = a;
    output.R(t,1) = r;
    output.S(t,:) = s;
    output.s1_stims(t,:) = s1_stims;
        
end

end