% This function generates the likelihood of each model/paramters
%dbstop if error

function lik = C_iii_kool_model_ll(params, con, output, model)


% parameters
b1 = params(1);           % softmax inverse temperature low or 1
b2 = params(2); 
b3 = params(3); 
lr1 = params(4);          % learning rate
lr2 = params(5);          % learning rate
w1 = params(6);
w2 = params(7);



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


lambda = 0.5;

for k = 1:200
   
   s1_stims = output.s1_stims(k,:); 
   S = output.S(k,:);
   A = output.A(k,:);
   A1 = output.action(k,1);
   R = output.R(k,1);
   
    if model == 1 %2w  / no lambda  / 1beta 1 alpha
        
        w = 0.5;

       
        if con(k) == 1 
        
            cond = 1;
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1
            for s = 1:3 %watchout
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));         
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims);  
            %ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action

            lik = lik + b1*Q1(A1)-logsumexp(b1*Q1); %action or A1
            
            Q2 = w1*Qmb2{cond}(S(2),:) + (1-w1)*Qmf2{cond}(S(2),:);          
        else
            
            cond = 2;                 

            Qmb2{cond} = Tm{S(2),2}*Qmf3; 
            
            %Qmb2{cond} = Tm{S(2),2}*Qmb2{cond} ;                          % compute model-based value function
             Q2 = w2*Qmb2{cond}(S(2),:) + (1-w2)*Qmf2{cond}(S(2),:);
        end
              
        %Q2(2,:) remplacer
        
        %ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
                              
        
        lik = lik + b1*Q2(A(2))-logsumexp(b1*Q2);
               
        
        % level 2
        
        %% updating
        if con(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(S(2),A(2)) - Qmf1(A1);
            Qmf1(A(1)) = Qmf1(A(1)) + lr1*dtQ(1);
        end
        
        % level 2
        dtQ(2) = Qmf3(S(3)) - Qmf2{cond}(S(2),A(2));
        
        Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr1*dtQ(2);
       
        if con(k) == 1
            
            Qmf1(A(1)) = Qmf1(A(1)) + lambda*lr1*dtQ(2);
        end
        
        %level 3
        dtQ(3) = R - Qmf3(S(3));
        Qmf3(S(3)) = Qmf3(S(3)) + lr1*dtQ(3);
        Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr1*dtQ(3);
        
        if con(k) == 1  
            Qmf1(A(1)) = Qmf1(A(1)) + (lambda^2)*lr1*dtQ(3);     
        end
        
        
    elseif model == 2 %2 betas / 1 alpha/ 2w  / no lambda 
        
          w = 0.5;

       
        if con(k) == 1 
        
            cond = 1;
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1
            for s = 1:3 %watchout
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));         
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims);  
            %ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action

            lik = lik + b1*Q1(A1)-logsumexp(b1*Q1); %action or A1
            
            Q2 = w1*Qmb2{cond}(S(2),:) + (1-w1)*Qmf2{cond}(S(2),:);     
            
            lik = lik + b1*Q2(A(2))-logsumexp(b1*Q2);
        else
            
            cond = 2;                 

            Qmb2{cond} = Tm{S(2),2}*Qmf3; 
            
            %Qmb2{cond} = Tm{S(2),2}*Qmb2{cond} ;                          % compute model-based value function
             Q2 = w2*Qmb2{cond}(S(2),:) + (1-w2)*Qmf2{cond}(S(2),:);
             
             lik = lik + b2*Q2(A(2))-logsumexp(b2*Q2);
        end
              
        %Q2(2,:) remplacer
        
        %ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action

        % level 2
        
        %% updating
        if con(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(S(2),A(2)) - Qmf1(A1);
            Qmf1(A(1)) = Qmf1(A(1)) + lr1*dtQ(1);
        end
        
        % level 2
        dtQ(2) = Qmf3(S(3)) - Qmf2{cond}(S(2),A(2));
        
        Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr1*dtQ(2);
       
        if con(k) == 1
            
            Qmf1(A(1)) = Qmf1(A(1)) + lambda*lr1*dtQ(2);
        end
        
        %level 3
        dtQ(3) = R - Qmf3(S(3));
        Qmf3(S(3)) = Qmf3(S(3)) + lr1*dtQ(3);
        Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr1*dtQ(3);
        
        if con(k) == 1  
            Qmf1(A(1)) = Qmf1(A(1)) + (lambda^2)*lr1*dtQ(3);     
        end
        
        
    elseif model == 3 %3 betas / 1 alpha/ 2w  / no lambda
          
        w = 0.5;
      
        if con(k) == 1 
        
            cond = 1;
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1
            for s = 1:3 %watchout
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));         
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims);  
            %ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action

            lik = lik + b1*Q1(A1)-logsumexp(b1*Q1); %action or A1
            
            Q2 = w1*Qmb2{cond}(S(2),:) + (1-w1)*Qmf2{cond}(S(2),:);     
            
            lik = lik + b2*Q2(A(2))-logsumexp(b2*Q2);
        else
            
            cond = 2;                 

            Qmb2{cond} = Tm{S(2),2}*Qmf3; 
            
            %Qmb2{cond} = Tm{S(2),2}*Qmb2{cond} ;                          % compute model-based value function
             Q2 = w2*Qmb2{cond}(S(2),:) + (1-w2)*Qmf2{cond}(S(2),:);
             
             lik = lik + b3*Q2(A(2))-logsumexp(b3*Q2);
        end
              
        %Q2(2,:) remplacer
        
        %ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action

        % level 2
        
        %% updating
        if con(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(S(2),A(2)) - Qmf1(A1);
            Qmf1(A(1)) = Qmf1(A(1)) + lr1*dtQ(1);
        end
        
        % level 2
        dtQ(2) = Qmf3(S(3)) - Qmf2{cond}(S(2),A(2));
        
        Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr1*dtQ(2);
       
        if con(k) == 1
            
            Qmf1(A(1)) = Qmf1(A(1)) + lambda*lr1*dtQ(2);
        end
        
        %level 3
        dtQ(3) = R - Qmf3(S(3));
        Qmf3(S(3)) = Qmf3(S(3)) + lr1*dtQ(3);
        Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr1*dtQ(3);
        
        if con(k) == 1  
            Qmf1(A(1)) = Qmf1(A(1)) + (lambda^2)*lr1*dtQ(3);     
        end
        
    elseif model == 4 %2 alphas / 1beta/ 2w  / no lambda  
        
          w = 0.5;
      
        if con(k) == 1 
        
            cond = 1;
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1
            for s = 1:3 %watchout
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));         
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims);  
            %ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action

            lik = lik + b1*Q1(A1)-logsumexp(b1*Q1); %action or A1
            
            Q2 = w1*Qmb2{cond}(S(2),:) + (1-w1)*Qmf2{cond}(S(2),:);     
            
            lik = lik + b1*Q2(A(2))-logsumexp(b1*Q2);
        else
            
            cond = 2;                 

            Qmb2{cond} = Tm{S(2),2}*Qmf3; 
            
            %Qmb2{cond} = Tm{S(2),2}*Qmb2{cond} ;                          % compute model-based value function
             Q2 = w2*Qmb2{cond}(S(2),:) + (1-w2)*Qmf2{cond}(S(2),:);
             
             lik = lik + b1*Q2(A(2))-logsumexp(b1*Q2);
        end
              
        %Q2(2,:) remplacer
        
        %ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action

        % level 2
        
        %% updating
        if con(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(S(2),A(2)) - Qmf1(A1);
            Qmf1(A(1)) = Qmf1(A(1)) + lr1*dtQ(1);
        end
        
        % level 2
        dtQ(2) = Qmf3(S(3)) - Qmf2{cond}(S(2),A(2));
        
        
        if con(k) == 1
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr1*dtQ(2);
            Qmf1(A(1)) = Qmf1(A(1)) + lambda*lr1*dtQ(2);
        else
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr2*dtQ(2);
        end
        
        %level 3
        dtQ(3) = R - Qmf3(S(3));
       
        if con(k) == 1  
            Qmf3(S(3)) = Qmf3(S(3)) + lr1*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr1*dtQ(3);
            Qmf1(A(1)) = Qmf1(A(1)) + (lambda^2)*lr1*dtQ(3);     
        else
            Qmf3(S(3)) = Qmf3(S(3)) + lr2*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr2*dtQ(3);
        end
        
    elseif model == 5 %2 alphas / 2beta / 2w  / no lambda
        
        w = 0.5;
      
        if con(k) == 1 
        
            cond = 1;
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1
            for s = 1:3 %watchout
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));         
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims);  
            %ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action

            lik = lik + b1*Q1(A1)-logsumexp(b1*Q1); %action or A1
            
            Q2 = w1*Qmb2{cond}(S(2),:) + (1-w1)*Qmf2{cond}(S(2),:);     
            
            lik = lik + b1*Q2(A(2))-logsumexp(b1*Q2);
        else
            
            cond = 2;                 

            Qmb2{cond} = Tm{S(2),2}*Qmf3; 
            
            %Qmb2{cond} = Tm{S(2),2}*Qmb2{cond} ;                          % compute model-based value function
             Q2 = w2*Qmb2{cond}(S(2),:) + (1-w2)*Qmf2{cond}(S(2),:);
             
             lik = lik + b2*Q2(A(2))-logsumexp(b2*Q2);
        end
              
        %Q2(2,:) remplacer
        
        %ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action

        % level 2
        
        %% updating
        if con(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(S(2),A(2)) - Qmf1(A1);
            Qmf1(A(1)) = Qmf1(A(1)) + lr1*dtQ(1);
        end
        
        % level 2
        dtQ(2) = Qmf3(S(3)) - Qmf2{cond}(S(2),A(2));
        
        
        if con(k) == 1
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr1*dtQ(2);
            Qmf1(A(1)) = Qmf1(A(1)) + lambda*lr1*dtQ(2);
        else
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr2*dtQ(2);
        end
        
        %level 3
        dtQ(3) = R - Qmf3(S(3));
       
        if con(k) == 1  
            Qmf3(S(3)) = Qmf3(S(3)) + lr1*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr1*dtQ(3);
            Qmf1(A(1)) = Qmf1(A(1)) + (lambda^2)*lr1*dtQ(3);     
        else
            Qmf3(S(3)) = Qmf3(S(3)) + lr2*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr2*dtQ(3);
        end
        
    elseif model == 6 %full 7  / no lambda
        
               w = 0.5;
      
        if con(k) == 1 
        
            cond = 1;
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1
            for s = 1:3 %watchout
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));         
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims);  
            %ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action

            lik = lik + b1*Q1(A1)-logsumexp(b1*Q1); %action or A1
            
            Q2 = w1*Qmb2{cond}(S(2),:) + (1-w1)*Qmf2{cond}(S(2),:);     
            
            lik = lik + b2*Q2(A(2))-logsumexp(b2*Q2);
        else
            
            cond = 2;                 

            Qmb2{cond} = Tm{S(2),2}*Qmf3; 
            
            %Qmb2{cond} = Tm{S(2),2}*Qmb2{cond} ;                          % compute model-based value function
             Q2 = w2*Qmb2{cond}(S(2),:) + (1-w2)*Qmf2{cond}(S(2),:);
             
             lik = lik + b3*Q2(A(2))-logsumexp(b3*Q2);
        end
              
        %Q2(2,:) remplacer
        
        %ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action

        % level 2
        
        %% updating
        if con(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(S(2),A(2)) - Qmf1(A1);
            Qmf1(A(1)) = Qmf1(A(1)) + lr1*dtQ(1);
        end
        
        % level 2
        dtQ(2) = Qmf3(S(3)) - Qmf2{cond}(S(2),A(2));
        
        
        if con(k) == 1
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr1*dtQ(2);
            Qmf1(A(1)) = Qmf1(A(1)) + lambda*lr1*dtQ(2);
        else
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr2*dtQ(2);
        end
        
        %level 3
        dtQ(3) = R - Qmf3(S(3));
       
        if con(k) == 1  
            Qmf3(S(3)) = Qmf3(S(3)) + lr1*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr1*dtQ(3);
            Qmf1(A(1)) = Qmf1(A(1)) + (lambda^2)*lr1*dtQ(3);     
        else
            Qmf3(S(3)) = Qmf3(S(3)) + lr2*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr2*dtQ(3);
        end
        
        
    elseif model == 7 %full 7  / no lambda w0
        
        w = 0.5;
      
        if con(k) == 1 
        
            cond = 1;
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1
            for s = 1:3 %watchout
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));         
            % level 0
            Q1(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims);  
            %ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action

            lik = lik + b1*Q1(A1)-logsumexp(b1*Q1); %action or A1
            
            Q2 = w*Qmb2{cond}(S(2),:) + (1-w)*Qmf2{cond}(S(2),:);     
            
            lik = lik + b2*Q2(A(2))-logsumexp(b2*Q2);
        else
            
            cond = 2;                 

            Qmb2{cond} = Tm{S(2),2}*Qmf3; 
            
            %Qmb2{cond} = Tm{S(2),2}*Qmb2{cond} ;                          % compute model-based value function
             Q2 = w2*Qmb2{cond}(S(2),:) + (1-w2)*Qmf2{cond}(S(2),:);
             
             lik = lik + b3*Q2(A(2))-logsumexp(b3*Q2);
        end
              
        %Q2(2,:) remplacer
        
        %ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action

        % level 2
        
        %% updating
        if con(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(S(2),A(2)) - Qmf1(A1);
            Qmf1(A(1)) = Qmf1(A(1)) + lr1*dtQ(1);
        end
        
        % level 2
        dtQ(2) = Qmf3(S(3)) - Qmf2{cond}(S(2),A(2));
        
        
        if con(k) == 1
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr1*dtQ(2);
            Qmf1(A(1)) = Qmf1(A(1)) + lambda*lr1*dtQ(2);
        else
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr2*dtQ(2);
        end
        
        %level 3
        dtQ(3) = R - Qmf3(S(3));
       
        if con(k) == 1  
            Qmf3(S(3)) = Qmf3(S(3)) + lr1*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr1*dtQ(3);
            Qmf1(A(1)) = Qmf1(A(1)) + (lambda^2)*lr1*dtQ(3);     
        else
            Qmf3(S(3)) = Qmf3(S(3)) + lr2*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr2*dtQ(3);
        end
        
        
    elseif model == 8 %full 6  / no lambda
        
        lr = 0.5; %??
        b = 0.5; % ??
        w = 0.5;
        lambda = 0.5;
        %b2 = b1;
        %lr2 = lr1;
        %w2 = w1;
        
        
        if con(k) == 1 
        
            cond = 1;
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1
            for s = 1:3 %watchout
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));         
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims);  
            %ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action

            lik = lik + b*Q1(A1)-logsumexp(b*Q1); %action or A1
            
            Q2 = w1*Qmb2{cond}(S(2),:) + (1-w1)*Qmf2{cond}(S(2),:);          
        else
            
            cond = 2;                 

            Qmb2{cond} = Tm{S(2),2}*Qmf3; 
            
            %Qmb2{cond} = Tm{S(2),2}*Qmb2{cond} ;                          % compute model-based value function
             Q2 = w2*Qmb2{cond}(S(2),:) + (1-w2)*Qmf2{cond}(S(2),:);
        end
              
        %Q2(2,:) remplacer
        
        %ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
                              
        if con(k) == 1
            lik = lik + b1*Q2(A(2))-logsumexp(b1*Q2);
        else
            lik = lik + b2*Q2(A(2))-logsumexp(b2*Q2);
        end
               
        
        % level 2
        
        %% updating
        if con(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(S(2),A(2)) - Qmf1(A1);
            Qmf1(A(1)) = Qmf1(A(1)) + lr1*dtQ(1);
        end
        
        % level 2
        dtQ(2) = Qmf3(S(3)) - Qmf2{cond}(S(2),A(2));
        
        
        if con(k) == 1
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr1*dtQ(2);
            Qmf1(A(1)) = Qmf1(A(1)) + lambda*lr1*dtQ(2);
        else
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr2*dtQ(2);
        end
        
        %level 3
        dtQ(3) = R - Qmf3(S(3));
       
        if con(k) == 1  
            Qmf3(S(3)) = Qmf3(S(3)) + lr1*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr1*dtQ(3);
            Qmf1(A(1)) = Qmf1(A(1)) + (lambda^2)*lr1*dtQ(3);     
        else
            Qmf3(S(3)) = Qmf3(S(3)) + lr2*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr2*dtQ(3);
        end
        
    elseif model == 9 %full 6  + lambda
        
        lr = 0.5; %??
        b = 0.5; % ??
        w = 0.5;
        %lambda = 0.5;
        %b2 = b1;
        %lr2 = lr1;
        %w2 = w1;
              
        if con(k) == 1 
        
            cond = 1;
            
            Tm1 = Tm{1,1}(s1_stims,:); % temporary Tm1
            for s = 1:3 %watchout
                Qmb2{1,1}(s,:) = Tm{2,1}(:,:,s)*Qmf3; %= Qmb middle
            end

            Qmb1 = Tm1*max(Qmb2{cond},[],2);  %=Qmb top
            
            %disp(max(Qmb2{cond},[],2));         
            % level 0
            Q1(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims);  
            %ps = exp(b1*Q1(1,:))/sum(exp(b1*Q1(1,:)));                      %compute choice probabilities for each action

            lik = lik + b*Q1(A1)-logsumexp(b*Q1); %action or A1
            
            Q2 = w1*Qmb2{cond}(S(2),:) + (1-w1)*Qmf2{cond}(S(2),:);          
        else
            
            cond = 2;                 

            Qmb2{cond} = Tm{S(2),2}*Qmf3; 
            
            %Qmb2{cond} = Tm{S(2),2}*Qmb2{cond} ;                          % compute model-based value function
             Q2 = w2*Qmb2{cond}(S(2),:) + (1-w2)*Qmf2{cond}(S(2),:);
        end
              
        %Q2(2,:) remplacer
        
        %ps = exp(b1*Q2)/sum(exp(b1*Q2));                      %compute choice probabilities for each action
                              
        if con(k) == 1
            lik = lik + b1*Q2(A(2))-logsumexp(b1*Q2);
        else
            lik = lik + b2*Q2(A(2))-logsumexp(b2*Q2);
        end
               
        
        % level 2
        
        %% updating
        if con(k) == 1   
            %level 1
            dtQ(1) = Qmf2{cond}(S(2),A(2)) - Qmf1(A1);
            Qmf1(A(1)) = Qmf1(A(1)) + lr1*dtQ(1);
        end
        
        % level 2
        dtQ(2) = Qmf3(S(3)) - Qmf2{cond}(S(2),A(2));
        
        
        if con(k) == 1
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr1*dtQ(2);
            Qmf1(A(1)) = Qmf1(A(1)) + lambda*lr1*dtQ(2);
        else
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lr2*dtQ(2);
        end
        
        %level 3
        dtQ(3) = R - Qmf3(S(3));
       
        if con(k) == 1  
            Qmf3(S(3)) = Qmf3(S(3)) + lr1*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr1*dtQ(3);
            Qmf1(A(1)) = Qmf1(A(1)) + (lambda^2)*lr1*dtQ(3);     
        else
            Qmf3(S(3)) = Qmf3(S(3)) + lr2*dtQ(3);
            Qmf2{cond}(S(2),A(2)) = Qmf2{cond}(S(2),A(2)) + lambda*lr2*dtQ(3);
        end     
               
        
   end    
end
      

lik = -lik;                                                                               % loglikelyhood vector
end