function output = C_ii_MBMF_sim(params, c, rews, model) %taking out b
% This function should generates the likelihood of each model/paramters


%%
b1 = params(1);           % softmax inverse temperature low or 1
lr = params(2);          % learning rate
lambda = params(3);      % eligibility trace decay

% initialization high
Qmf1 = zeros(1,3);

Qmf2 = cell(1,2);
Qmf2{1,1} = zeros(3,2); %for high
Qmf2{1,2} = zeros(2,3); %for low

Qmf3 = zeros(3,1);                    % Q(s,a): state-action value function for Q-learning

Tm = cell(2,2);

%for high
Tm{1,1} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix
Tm{2,1}(:,:,1) = [1 0 0; 0 1 0];        % transition matrix
Tm{2,1}(:,:,2) = [1 0 0; 0 0 1];        % transition matrix
Tm{2,1}(:,:,3) = [0 1 0; 0 0 1];        % transition matrix

%for low
Tm{1,2} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix
Tm{2,2} = [1 0 0; 0 1 0; 0 0 1]; 



%rands
rand1 = rand;


%% store stuff
% output.high.A = zeros(ntrials ,2);
% output.high.R = zeros(ntrials ,1);
% output.high.S = zeros(ntrials ,3);
% output.low.A(k,1) = a;
% output.low.Q(k,:) = low_Q;

for k = 1:200
    
    s1_stims = datasample(1:3,2,'Replace',false);
    
    if model == 1

        % parameters model12 = simple MF
        w = 0;          % mixing weight

        %high effort
        if c(k) == 1 
            
            cond = 1;
               %notes:
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            %Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            %for s = 1:3
                %Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            %end

            %Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            s(1) = 1;
            
            
            % level 0
            Q1(1,:) = Qmf1(s1_stims); 
            ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));            
            %compute choice probabilities for each action       
            
            
            
            rand1 = rand;
            action = find(rand1<cumsum(ps),1);                 
            % choose action

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));
            
            % store stuff           
            output.rand1(k) = rand1;
                       
        else          
            cond = 2;
            rand1 = ceil(rand*2);
            s(2) = rand1;
            
            % store stuff
            output.rand1(k) = rand1;            
            
        end
        
        Q2 = Qmf2{cond}(s(2),:);
        
        ps(k) = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
            
        rand2 = rand;        
                   
        a(2) = find(rand2<cumsum(ps),1);                   % choose

        if c(k) == 1
            s(3) = find(Tm{2,1}(a(2),:,s(2)));
        else
            s(3) = a(2);
        end
        % level 2
        reward = rews(k,s(3));
        
        %% updating
        if c(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
        end
        % level 2
        dtQ(2) = Qmf3(s(3)) - Qmf2{cond}(s(2),a(2));
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lr*dtQ(2);
        
        if c(k) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
        end
        
        % level 3
        dtQ(3) = reward - Qmf3(s(3));
        Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lambda*lr*dtQ(3);
        
        if c(k) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
        end
        
    end
    
    % store stuff
    output.A(k,:) = a; %faire gaffe au cond =2
    output.R(k,1) = reward;
    output.S(k,:) = s;
    output.s1_stims(k,:) = s1_stims;
    output.rand2(k) = rand2;
    
   end       
end
