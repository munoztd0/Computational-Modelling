function output = C_ii_nested_sim(params, c, rews, model) %taking out b
% This function should generates the likelihood of each model/paramters


%%
b1 = params(1);           % softmax inverse temperature low or 1
lr = params(2);          % learning rate
lambda = params(3);      % eligibility trace decay
w1 = params(4);
w2 = params(5);
w3 = params(6);

% initialization high
Qmf1 = zeros(1,3);

Qmf2 = cell(1,2);
Qmf2{1,1} = zeros(3,2); %for high
Qmf2{1,2} = zeros(2,3); %for low

Qmf3 = zeros(3,1);                    % Q(s,a): state-action value function for Q-learning
ps = zeros(1,3);
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


%% store stuff


for k = 1:200
    
    s1_stims = datasample(1:3,2,'Replace',false);
    
    if model == 1 %MF
     
        lambda = 0;
     %high effort
        if c(k) == 1 
            
            cond = 1;
               %notes:
            %$Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end
            
            
            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));
           
            % level 0
            Q1(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims);
            
            s(1) = 1;
                     
            ps1 = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));
            
            mat = zeros(1,size(ps,2));
            mat(1:size(ps1,1),1:size(ps1,2)) = ps1;
            ps(k,:) =  mat;           
            %compute choice probabilities for each action       
                         
            rand1 = rand;
            action = find(rand1<cumsum(ps(k,:)),1);                 
            % choose action

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));
            
            % store stuff           
            output.rand1(k,1) = rand1;
            output.action(k,:) = action;
            
            Q2 = w1*Qmb2{cond}(s(2),:) + (1-w1)*Qmf2{cond}(s(2),:);
        
        else
            s(1) = 0;          
            
            %Qmb = Tm{s1}*Q2;                              % compute model-based value function
    
            %Q = w*Qmb + (1-w1)*Qmf(s1,:)';
            
            cond = 2;
            rand1 = ceil(rand*2);
            s(2) = rand1;
            Qmb2{cond} = Tm{s(2),2}*Qmf3;    
            %Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3;
            
            % store stuff
            output.rand1(k,1) = rand1;
            output.action(k,:) = 0;
                     % compute model-based value function
            
            Q2 = w1*Qmb2{cond}(s(2),:) + (1-w1)*Qmf2{cond}(s(2),:);
        end
        
         %Q2(2,:) remplacer
        
        ps2 = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
        
        mat = zeros(1,size(ps,2));
        mat(1:size(ps2,1),1:size(ps2,2)) = ps2;
        ps(k,:) =  mat;   
        
        rand2 = rand;        
                   
        a(2) = find(rand2<cumsum(ps(k,:)),1);                   % choose

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
        
    
    % store stuff
    output.A(k,:) = a; %faire gaffe au cond =2
    output.R(k,1) = reward;
    output.S(k,:) = s;
    output.s1_stims(k,:) = s1_stims;
    output.rand2(k,1) = rand2;
    output.ps(k,:) = ps(k,:);  
   
   
    elseif model == 2 
        lambda = 0;
        %high effort
        if c(k) == 1 
            
            cond = 1;
               %notes:
            %$Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end
            
            
            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));
           
            % level 0
            Q1(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims);
            
            s(1) = 1;
                     
            ps1 = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));
            
            mat = zeros(1,size(ps,2));
            mat(1:size(ps1,1),1:size(ps1,2)) = ps1;
            ps(k,:) =  mat;           
            %compute choice probabilities for each action       
                         
            rand1 = rand;
            action = find(rand1<cumsum(ps(k,:)),1);                 
            % choose action

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));
            
            % store stuff           
            output.rand1(k,1) = rand1;
            output.action(k,:) = action;
            
            Q2 = w1*Qmb2{cond}(s(2),:) + (1-w1)*Qmf2{cond}(s(2),:);
       
        else
            s(1) = 0;          
            
            %Qmb = Tm{s1}*Q2;                              % compute model-based value function
    
            %Q = w*Qmb + (1-w1)*Qmf(s1,:)';
            
            cond = 2;
            rand1 = ceil(rand*2);
            s(2) = rand1;
            Qmb2{cond} = Tm{s(2),2}*Qmf3;    
            %Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3;
            
            % store stuff
            output.rand1(k,1) = rand1;
            output.action(k,:) = 0;
                     % compute model-based value function
            
            Q2 = w2*Qmb2{cond}(s(2),:) + (1-w2)*Qmf2{cond}(s(2),:);
        end
        
         %Q2(2,:) remplacer
        
        ps2 = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
        
        mat = zeros(1,size(ps,2));
        mat(1:size(ps2,1),1:size(ps2,2)) = ps2;
        ps(k,:) =  mat;   
        
        rand2 = rand;        
                   
        a(2) = find(rand2<cumsum(ps(k,:)),1);                   % choose

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
        
    
    % store stuff
    output.A(k,:) = a; %faire gaffe au cond =2
    output.R(k,1) = reward;
    output.S(k,:) = s;
    output.s1_stims(k,:) = s1_stims;
    output.rand2(k,1) = rand2;
    output.ps(k,:) = ps(k,:);  
    
    elseif model == 3 % mix 1 w
      
        lambda = 0;
        
        %high effort
        if c(k) == 1 
            
            cond = 1;
               %notes:
            %$Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end
            
            
            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));
           
            % level 0
            Q1(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims);
            
            s(1) = 1;
                     
            ps1 = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));
            
            mat = zeros(1,size(ps,2));
            mat(1:size(ps1,1),1:size(ps1,2)) = ps1;
            ps(k,:) =  mat;           
            %compute choice probabilities for each action       
                         
            rand1 = rand;
            action = find(rand1<cumsum(ps(k,:)),1);                 
            % choose action

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));
            
            % store stuff           
            output.rand1(k,1) = rand1;
            output.action(k,:) = action;
            
            Q2 = w2*Qmb2{cond}(s(2),:) + (1-w2)*Qmf2{cond}(s(2),:);
        else
            s(1) = 0;          
            
            %Qmb = Tm{s1}*Q2;                              % compute model-based value function
    
            %Q = w*Qmb + (1-w1)*Qmf(s1,:)';
            
            cond = 2;
            rand1 = ceil(rand*2);
            s(2) = rand1;
            Qmb2{cond} = Tm{s(2),2}*Qmf3;    
            %Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3;
            
            % store stuff
            output.rand1(k,1) = rand1;
            output.action(k,:) = 0;
                     % compute model-based value function
            
            Q2 = w3*Qmb2{cond}(s(2),:) + (1-w3)*Qmf2{cond}(s(2),:);
        end
        
         %Q2(2,:) remplacer
        
        ps2 = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
        
        mat = zeros(1,size(ps,2));
        mat(1:size(ps2,1),1:size(ps2,2)) = ps2;
        ps(k,:) =  mat;   
        
        rand2 = rand;        
                   
        a(2) = find(rand2<cumsum(ps(k,:)),1);                   % choose

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
        
    
    % store stuff
    output.A(k,:) = a; %faire gaffe au cond =2
    output.R(k,1) = reward;
    output.S(k,:) = s;
    output.s1_stims(k,:) = s1_stims;
    output.rand2(k,1) = rand2;
    output.ps(k,:) = ps(k,:);  
   
    
    elseif model == 4 % mix 2 w
        
        lambda=0;
         w1 = 0.5;  
        %high effort
        if c(k) == 1 
            
            cond = 1;
               %notes:
            %$Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end
            
            
            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));
           
            % level 0
            Q1(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims);
            
            s(1) = 1;
                     
            ps1 = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));
            
            mat = zeros(1,size(ps,2));
            mat(1:size(ps1,1),1:size(ps1,2)) = ps1;
            ps(k,:) =  mat;           
            %compute choice probabilities for each action       
                         
            rand1 = rand;
            action = find(rand1<cumsum(ps(k,:)),1);                 
            % choose action

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));
            
            % store stuff           
            output.rand1(k,1) = rand1;
            output.action(k,:) = action;
            
            Q2 = w2*Qmb2{cond}(s(2),:) + (1-w2)*Qmf2{cond}(s(2),:);
        else
            s(1) = 0;          
            
            %Qmb = Tm{s1}*Q2;                              % compute model-based value function
    
            %Q = w*Qmb + (1-w1)*Qmf(s1,:)';
            
            cond = 2;
            rand1 = ceil(rand*2);
            s(2) = rand1;
            Qmb2{cond} = Tm{s(2),2}*Qmf3;    
            %Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3;
            
            % store stuff
            output.rand1(k,1) = rand1;
            output.action(k,:) = 0;
                     % compute model-based value function
            
            Q2 = w3*Qmb2{cond}(s(2),:) + (1-w3)*Qmf2{cond}(s(2),:);
        end
        
         %Q2(2,:) remplacer
        
        ps2 = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
        
        mat = zeros(1,size(ps,2));
        mat(1:size(ps2,1),1:size(ps2,2)) = ps2;
        ps(k,:) =  mat;   
        
        rand2 = rand;        
                   
        a(2) = find(rand2<cumsum(ps(k,:)),1);                   % choose

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
        
    
    % store stuff
    output.A(k,:) = a; %faire gaffe au cond =2
    output.R(k,1) = reward;
    output.S(k,:) = s;
    output.s1_stims(k,:) = s1_stims;
    output.rand2(k,1) = rand2;
    output.ps(k,:) = ps(k,:);  
   
   
    elseif model == 5 % mix 1 w
        lambda=0;
        
        w2 = 0.5;
        %high effort
        if c(k) == 1 
            
            cond = 1;
               %notes:
            %$Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end
            
            
            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));
           
            % level 0
            Q1(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims);
            
            s(1) = 1;
                     
            ps1 = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));
            
            mat = zeros(1,size(ps,2));
            mat(1:size(ps1,1),1:size(ps1,2)) = ps1;
            ps(k,:) =  mat;           
            %compute choice probabilities for each action       
                         
            rand1 = rand;
            action = find(rand1<cumsum(ps(k,:)),1);                 
            % choose action

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));
            
            % store stuff           
            output.rand1(k,1) = rand1;
            output.action(k,:) = action;
            
            Q2 = w2*Qmb2{cond}(s(2),:) + (1-w2)*Qmf2{cond}(s(2),:);
        else
            s(1) = 0;          
            
            %Qmb = Tm{s1}*Q2;                              % compute model-based value function
    
            %Q = w*Qmb + (1-w1)*Qmf(s1,:)';
            
            cond = 2;
            rand1 = ceil(rand*2);
            s(2) = rand1;
            Qmb2{cond} = Tm{s(2),2}*Qmf3;    
            %Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3;
            
            % store stuff
            output.rand1(k,1) = rand1;
            output.action(k,:) = 0;
                     % compute model-based value function
            
            Q2 = w3*Qmb2{cond}(s(2),:) + (1-w3)*Qmf2{cond}(s(2),:);
        end
        
         %Q2(2,:) remplacer
        
        ps2 = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
        
        mat = zeros(1,size(ps,2));
        mat(1:size(ps2,1),1:size(ps2,2)) = ps2;
        ps(k,:) =  mat;   
        
        rand2 = rand;        
                   
        a(2) = find(rand2<cumsum(ps(k,:)),1);                   % choose

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
        
    
    % store stuff
    output.A(k,:) = a; %faire gaffe au cond =2
    output.R(k,1) = reward;
    output.S(k,:) = s;
    output.s1_stims(k,:) = s1_stims;
    output.rand2(k,1) = rand2;
    output.ps(k,:) = ps(k,:);  
   
    
    elseif model == 6 % mix 2 w
        
        %high effort
        if c(k) == 1 
            
            cond = 1;
               %notes:
            %$Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
            %disp(max(Qmb2,[],2));
            %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
            %(s1_stims) = (subdata.stims0(t,:))
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1

            for s = 1:3
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end
            
            
            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));
           
            % level 0
            Q1(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims);
            
            s(1) = 1;
                     
            ps1 = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));
            
            mat = zeros(1,size(ps,2));
            mat(1:size(ps1,1),1:size(ps1,2)) = ps1;
            ps(k,:) =  mat;           
            %compute choice probabilities for each action       
                         
            rand1 = rand;
            action = find(rand1<cumsum(ps(k,:)),1);                 
            % choose action

            a(1) = s1_stims(action);

            s(2) = find(Tm{1,1}(a(1),:));
            
            % store stuff           
            output.rand1(k,1) = rand1;
            output.action(k,:) = action;
            
            Q2 = w2*Qmb2{cond}(s(2),:) + (1-w2)*Qmf2{cond}(s(2),:);
        else
            s(1) = 0;          
            
            %Qmb = Tm{s1}*Q2;                              % compute model-based value function
    
            %Q = w*Qmb + (1-w1)*Qmf(s1,:)';
            
            cond = 2;
            rand1 = ceil(rand*2);
            s(2) = rand1;
            Qmb2{cond} = Tm{s(2),2}*Qmf3;    
            %Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3;
            
            % store stuff
            output.rand1(k,1) = rand1;
            output.action(k,:) = 0;
                     % compute model-based value function
            
            Q2 = w3*Qmb2{cond}(s(2),:) + (1-w3)*Qmf2{cond}(s(2),:);
        end
        
         %Q2(2,:) remplacer
        
        ps2 = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
        
        mat = zeros(1,size(ps,2));
        mat(1:size(ps2,1),1:size(ps2,2)) = ps2;
        ps(k,:) =  mat;   
        
        rand2 = rand;        
                   
        a(2) = find(rand2<cumsum(ps(k,:)),1);                   % choose

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
        
    
    % store stuff
    output.A(k,:) = a; %faire gaffe au cond =2
    output.R(k,1) = reward;
    output.S(k,:) = s;
    output.s1_stims(k,:) = s1_stims;
    output.rand2(k,1) = rand2;
    output.ps(k,:) = ps(k,:);  
   
     
   end       
end
