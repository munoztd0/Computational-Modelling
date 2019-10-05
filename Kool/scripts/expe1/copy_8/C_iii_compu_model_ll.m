% This function generates the likelihood of each model/paramters

function lik = C_iii_compu_model_ll(params, con, output, rews, model)


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
          
% Q(s,a): state-action value function for Q-learning

%function lik = compute_model_LL(params,s,a,r,model)
%I have S A R S

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


Qmb2 = cell(1,2);
Qmb2{1,1} = zeros(3,2);
Qmb2{1,2} = zeros(3,1);      % transition matrix


for i = 1:200
   
   s1_stims = output.s1_stims(i,:); 
   rand1 = output.rand1(i);
   rand2 = output.rand2(i);
   
   if model==1
      
        w = 0;
      
        if con(i) == 1 
        
            cond = 1;
            
            %notes:
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            s(1) = 1;
            
            
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
            ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action
            
            
            action = find(rand1<cumsum(ps),1);                 % choose

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));

            lik = lik + b1*Q1(action)-logsumexp(b1*Q1); %action or A1
                       
        else
            
            cond = 2;
            s(2) = rand1;           
            
            Qmb2{cond} = Tm{s(2),2}*Qmb2{cond} ;                          % compute model-based value function

            
        end
        
        
        Q2 = w*Qmb2{cond}(s(2),:) + (1-w)*Qmf2{cond}(s(2),:); %Q2(2,:) remplacer
        
        ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
            
                   
        a(2) = find(rand2<cumsum(ps),1);                   % choose
        
        lik = lik + b1*Q2(a(2))-logsumexp(b1*Q2);
        
        if con(i) == 1
            s(3) = find(Tm{2,1}(a(2),:,s(2)));
        else
            s(3) = a(2);
        end
        % level 2
        reward = rews(i,s(3));
        
        %% updating
        if con(i) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
        end
        % level 2
        dtQ(2) = Qmf3(s(3)) - Qmf2{cond}(s(2),a(2));
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lr*dtQ(2);
        
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
        end
        
        % level 3
        dtQ(3) = reward - Qmf3(s(3));
        Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lambda*lr*dtQ(3);
       
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
       end
      
   elseif model==2
      
        w = 1;
      
        if con(i) == 1 
        
            cond = 1;
            
            %notes:
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            s(1) = 1;
            
            
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
            ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action
            
            
            action = find(rand1<cumsum(ps),1);                 % choose

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));

            lik = lik + b1*Q1(action)-logsumexp(b1*Q1); %action or A1
                       
        else
            
            cond = 2;
            s(2) = rand1;           
            
            Qmb2{cond} = Tm{s(2),2}*Qmb2{cond} ;                          % compute model-based value function

            
        end
        
        
        Q2 = w*Qmb2{cond}(s(2),:) + (1-w)*Qmf2{cond}(s(2),:); %Q2(2,:) remplacer
        
        ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
            
                   
        a(2) = find(rand2<cumsum(ps),1);                   % choose
        
        lik = lik + b1*Q2(a(2))-logsumexp(b1*Q2);
        
        if con(i) == 1
            s(3) = find(Tm{2,1}(a(2),:,s(2)));
        else
            s(3) = a(2);
        end
        % level 2
        reward = rews(i,s(3));
        
        %% updating
        if con(i) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
        end
        % level 2
        dtQ(2) = Qmf3(s(3)) - Qmf2{cond}(s(2),a(2));
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lr*dtQ(2);
        
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
        end
        
        % level 3
        dtQ(3) = reward - Qmf3(s(3));
        Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lambda*lr*dtQ(3);
       
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
       end
      
        
   elseif model==3
      
        w = 0;
      
        if con(i) == 1 
        
            cond = 1;
            
            %notes:
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            s(1) = 1;
            
            
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
            ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action
            
            
            action = find(rand1<cumsum(ps),1);                 % choose

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));

            lik = lik + b1*Q1(action)-logsumexp(b1*Q1); %action or A1
                       
        else
            
            cond = 2;
            s(2) = rand1;           
            
            Qmb2{cond} = Tm{s(2),2}*Qmb2{cond} ;                          % compute model-based value function

            
        end
        
        
        Q2 = w*Qmb2{cond}(s(2),:) + (1-w)*Qmf2{cond}(s(2),:); %Q2(2,:) remplacer
        
        if con(i) == 1
                
                ps = exp(b2*Q2)/sum(exp(b2*Q2));                      %compute choice probabilities for each action
                a(2) = find(rand2<cumsum(ps),1);                   % choose
                lik = lik + b2*Q2(a(2))-logsumexp(b2*Q2);
        else
                ps = exp(b3*Q2)/sum(exp(b3*Q2));                      %compute choice probabilities for each action
                a(2) = find(rand2<cumsum(ps),1);                   % choose
                lik = lik + b3*Q2(a(2))-logsumexp(b3*Q2);
        end
        
        if con(i) == 1
            s(3) = find(Tm{2,1}(a(2),:,s(2)));
        else
            s(3) = a(2);
        end
        % level 2
        reward = rews(i,s(3));
        
        %% updating
        if con(i) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
        end
        % level 2
        dtQ(2) = Qmf3(s(3)) - Qmf2{cond}(s(2),a(2));
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lr*dtQ(2);
        
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
        end
        
        % level 3
        dtQ(3) = reward - Qmf3(s(3));
        Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lambda*lr*dtQ(3);
       
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
        end
        
    elseif model==4
      
        w = 1;
      
        if con(i) == 1 
        
            cond = 1;
            
            %notes:
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            s(1) = 1;
            
            
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
            ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action
            
            
            action = find(rand1<cumsum(ps),1);                 % choose

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));

            lik = lik + b1*Q1(action)-logsumexp(b1*Q1); %action or A1
                       
        else
            
            cond = 2;
            s(2) = rand1;           
            
            Qmb2{cond} = Tm{s(2),2}*Qmb2{cond} ;                          % compute model-based value function

            
        end
        
        
        Q2 = w*Qmb2{cond}(s(2),:) + (1-w)*Qmf2{cond}(s(2),:); %Q2(2,:) remplacer
        
        if con(i) == 1
                
            ps = exp(b2*Q2)/sum(exp(b2*Q2));                      %compute choice probabilities for each action
            a(2) = find(rand2<cumsum(ps),1);                   % choose
            lik = lik + b2*Q2(a(2))-logsumexp(b2*Q2);
        else
             ps = exp(b3*Q2)/sum(exp(b3*Q2));                      %compute choice probabilities for each action
             a(2) = find(rand2<cumsum(ps),1);                   % choose
             lik = lik + b3*Q2(a(2))-logsumexp(b3*Q2);
        end
        
        if con(i) == 1
            s(3) = find(Tm{2,1}(a(2),:,s(2)));
        else
            s(3) = a(2);
        end
        % level 2
        reward = rews(i,s(3));
        
        %% updating
        if con(i) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
        end
        % level 2
        dtQ(2) = Qmf3(s(3)) - Qmf2{cond}(s(2),a(2));
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lr*dtQ(2);
        
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
        end
        
        % level 3
        dtQ(3) = reward - Qmf3(s(3));
        Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lambda*lr*dtQ(3);
       
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
        end
        
   elseif model==5
      
        w = w1;
      
        if con(i) == 1 
        
            cond = 1;
            
            %notes:
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            s(1) = 1;
            
            
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
            ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action
            
            
            action = find(rand1<cumsum(ps),1);                 % choose

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));

            lik = lik + b1*Q1(action)-logsumexp(b1*Q1); %action or A1
                       
        else
            
            cond = 2;
            s(2) = rand1;           
            
            Qmb2{cond} = Tm{s(2),2}*Qmb2{cond} ;                          % compute model-based value function

            
        end
        
        
        Q2 = w*Qmb2{cond}(s(2),:) + (1-w)*Qmf2{cond}(s(2),:); %Q2(2,:) remplacer
        
        if con(i) == 1
                
            ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
            a(2) = find(rand2<cumsum(ps),1);                   % choose
            lik = lik + b1*Q2(a(2))-logsumexp(b1*Q2);
        else
             ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
             a(2) = find(rand2<cumsum(ps),1);                   % choose
             lik = lik + b1*Q2(a(2))-logsumexp(b1*Q2);
        end
        
        if con(i) == 1
            s(3) = find(Tm{2,1}(a(2),:,s(2)));
        else
            s(3) = a(2);
        end
        % level 2
        reward = rews(i,s(3));
        
        %% updating
        if con(i) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
        end
        % level 2
        dtQ(2) = Qmf3(s(3)) - Qmf2{cond}(s(2),a(2));
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lr*dtQ(2);
        
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
        end
        
        % level 3
        dtQ(3) = reward - Qmf3(s(3));
        Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lambda*lr*dtQ(3);
       
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
        end
        
   elseif model==6
      
        w = w1;
      
        if con(i) == 1 
        
            cond = 1;
            
            %notes:
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            s(1) = 1;
            
            
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
            ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action
            
            
            action = find(rand1<cumsum(ps),1);                 % choose

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));

            lik = lik + b1*Q1(action)-logsumexp(b1*Q1); %action or A1
                       
        else
            
            cond = 2;
            s(2) = rand1;           
            
            Qmb2{cond} = Tm{s(2),2}*Qmb2{cond} ;                          % compute model-based value function

            
        end
        
        
        Q2 = w*Qmb2{cond}(s(2),:) + (1-w)*Qmf2{cond}(s(2),:); %Q2(2,:) remplacer
        
        if con(i) == 1
                
            ps = exp(b2*Q2)/sum(exp(b2*Q2));                      %compute choice probabilities for each action
            a(2) = find(rand2<cumsum(ps),1);                   % choose
            lik = lik + b2*Q2(a(2))-logsumexp(b2*Q2);
        else
             ps = exp(b3*Q2)/sum(exp(b3*Q2));                      %compute choice probabilities for each action
             a(2) = find(rand2<cumsum(ps),1);                   % choose
             lik = lik + b3*Q2(a(2))-logsumexp(b3*Q2);
        end
        
        if con(i) == 1
            s(3) = find(Tm{2,1}(a(2),:,s(2)));
        else
            s(3) = a(2);
        end
        % level 2
        reward = rews(i,s(3));
        
        %% updating
        if con(i) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
        end
        % level 2
        dtQ(2) = Qmf3(s(3)) - Qmf2{cond}(s(2),a(2));
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lr*dtQ(2);
        
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
        end
        
        % level 3
        dtQ(3) = reward - Qmf3(s(3));
        Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lambda*lr*dtQ(3);
       
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
        end
        
   elseif model==7
      
      
        if con(i) == 1 
        
            cond = 1;
            
            %notes:
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            s(1) = 1;
            
            
            % level 0
            Q1(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims); 
            ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action
            
            
            action = find(rand1<cumsum(ps),1);                 % choose

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));

            lik = lik + b1*Q1(action)-logsumexp(b1*Q1); %action or A1
                       
        else
            
            cond = 2;
            s(2) = rand1;           
            
            Qmb2{cond} = Tm{s(2),2}*Qmb2{cond} ;                          % compute model-based value function

            
        end
        
        if con(i) == 1
            Q2 = w2*Qmb2{cond}(s(2),:) + (1-w2)*Qmf2{cond}(s(2),:); %Q2(2,:) remplacer
        else
            Q2 = w3*Qmb2{cond}(s(2),:) + (1-w3)*Qmf2{cond}(s(2),:); %Q2(2,:)     
        end
        
        if con(i) == 1
                
            ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
            a(2) = find(rand2<cumsum(ps),1);                   % choose
            lik = lik + b1*Q2(a(2))-logsumexp(b1*Q2);
        else
             ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
             a(2) = find(rand2<cumsum(ps),1);                   % choose
             lik = lik + b1*Q2(a(2))-logsumexp(b1*Q2);
        end
        
        if con(i) == 1
            s(3) = find(Tm{2,1}(a(2),:,s(2)));
        else
            s(3) = a(2);
        end
        % level 2
        reward = rews(i,s(3));
        
        %% updating
        if con(i) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
        end
        % level 2
        dtQ(2) = Qmf3(s(3)) - Qmf2{cond}(s(2),a(2));
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lr*dtQ(2);
        
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
        end
        
        % level 3
        dtQ(3) = reward - Qmf3(s(3));
        Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lambda*lr*dtQ(3);
       
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
        end     
        
   elseif model==8
      
      
        if con(i) == 1 
        
            cond = 1;
            
            %notes:
            %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            s(1) = 1;
            
            
            % level 0
            Q1(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims); 
            ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action
            
            
            action = find(rand1<cumsum(ps),1);                 % choose

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));

            lik = lik + b1*Q1(action)-logsumexp(b1*Q1); %action or A1
                       
        else
            
            cond = 2;
            s(2) = rand1;           
            
            Qmb2{cond} = Tm{s(2),2}*Qmb2{cond} ;                          % compute model-based value function

            
        end
        
        if con(i) == 1
            Q2 = w2*Qmb2{cond}(s(2),:) + (1-w2)*Qmf2{cond}(s(2),:); %Q2(2,:) remplacer
        else
            Q2 = w3*Qmb2{cond}(s(2),:) + (1-w3)*Qmf2{cond}(s(2),:); %Q2(2,:)     
        end
        
        if con(i) == 1
                
            ps = exp(b2*Q2)/sum(exp(b2*Q2));                      %compute choice probabilities for each action
            a(2) = find(rand2<cumsum(ps),1);                   % choose
            lik = lik + b2*Q2(a(2))-logsumexp(b2*Q2);
        else
             ps = exp(b3*Q2)/sum(exp(b3*Q2));                      %compute choice probabilities for each action
             a(2) = find(rand2<cumsum(ps),1);                   % choose
             lik = lik + b3*Q2(a(2))-logsumexp(b3*Q2);
        end
        
        if con(i) == 1
            s(3) = find(Tm{2,1}(a(2),:,s(2)));
        else
            s(3) = a(2);
        end
        % level 2
        reward = rews(i,s(3));
        
        %% updating
        if con(i) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(s(2),a(2)) - Qmf1(a(1));
            Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);
        end
        % level 2
        dtQ(2) = Qmf3(s(3)) - Qmf2{cond}(s(2),a(2));
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lr*dtQ(2);
        
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);
        end
        
        % level 3
        dtQ(3) = reward - Qmf3(s(3));
        Qmf3(s(3)) = Qmf3(s(3)) + lr*dtQ(3);
        Qmf2{cond}(s(2),a(2)) = Qmf2{cond}(s(2),a(2)) + lambda*lr*dtQ(3);
       
        if con(i) == 1
            Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);
        end          
   end    
end
      

lik = -lik;                                                                               % loglikelyhood vector
end