% This function generates the likelihood of each model/paramters

function lik = compute_model_ll(params,con, output, model)


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
          
% Q(s,a): state-action value function for Q-learning


% loop through trials
for k = 1:ntrials
    
    if model==1
             %             lik = lik + log(1./(1+exp(-beta1 *dQ)));
             %             Q(a(i)) = Q(a(i)) + lr1 * PE; % simple RL
       if con(k) == 1  % high effort trial

 
            action = output.high.action(k); %choice 0
            A2 = output.high.A(k); %choice 1


            Q1 = output.high.Q(1,:,k);
            Q2 = output.high.Q(2,:,k);
            
            lik = lik + b1*Q1(action)-logsumexp(b1*Q1);    
            lik = lik + b1*Q2(A2)-logsumexp(b1*Q2);
            
       else
                       % store stuff
            A = output.low.A(k,1);

            Q = output.low.Q(k,:);
            
            lik = lik + b1*Q(A)-logsumexp(b1*Q);
    
       end
    end   
    if model==2
          
       if con(k) == 1  % high effort trial

 
            action = output.high.action(k); %choice 0
            A2 = output.high.A(k); %choice 1


            Q1 = output.high.Q(1,:,k);
            Q2 = output.high.Q(2,:,k);
            
            lik = lik + b1*Q1(action)-logsumexp(b1*Q1);    
            lik = lik + b1*Q2(A2)-logsumexp(b1*Q2);
            
       else
                       % store stuff
            A = output.low.A(k,1);

            Q = output.low.Q(k,:);
            
            lik = lik + b1*Q(A)-logsumexp(b1*Q);
    
       end
    end   
    if model==3
          
       if con(k) == 1  % high effort trial

 
            action = output.high.action(k); %choice 0
            A2 = output.high.A(k); %choice 1


            Q1 = output.high.Q(1,:,k);
            Q2 = output.high.Q(2,:,k);
            
            lik = lik + b2*Q1(action)-logsumexp(b2*Q1);    
            lik = lik + b3*Q2(A2)-logsumexp(b3*Q2);
            
       else
                       % store stuff
            A = output.low.A(k,1);

            Q = output.low.Q(k,:);
            
            lik = lik + b1*Q(A)-logsumexp(b1*Q);
    
       end
       
    end  
    if model==4
          
       if con(k) == 1  % high effort trial

 
            action = output.high.action(k); %choice 0
            A2 = output.high.A(k); %choice 1


            Q1 = output.high.Q(1,:,k);
            Q2 = output.high.Q(2,:,k);
            
            lik = lik + b2*Q1(action)-logsumexp(b2*Q1);    
            lik = lik + b3*Q2(A2)-logsumexp(b3*Q2);
            
       else
                       % store stuff
            A = output.low.A(k,1);

            Q = output.low.Q(k,:);
            
            lik = lik + b1*Q(A)-logsumexp(b1*Q);
    
       end
    end 
   if model==5
          
       if con(k) == 1  % high effort trial

 
            action = output.high.action(k); %choice 0
            A2 = output.high.A(k); %choice 1


            Q1 = output.high.Q(1,:,k);
            Q2 = output.high.Q(2,:,k);
            
            lik = lik + b1*Q1(action)-logsumexp(b1*Q1);    
            lik = lik + b1*Q2(A2)-logsumexp(b1*Q2);
            
       else
                       % store stuff
            A = output.low.A(k,1);

            Q = output.low.Q(k,:);
            
            lik = lik + b1*Q(A)-logsumexp(b1*Q);
    
       end
    end   
    if model==6
          
       if con(k) == 1  % high effort trial

 
            action = output.high.action(k); %choice 0
            A2 = output.high.A(k); %choice 1


            Q1 = output.high.Q(1,:,k);
            Q2 = output.high.Q(2,:,k);
            
            lik = lik + b2*Q1(action)-logsumexp(b2*Q1);    
            lik = lik + b3*Q2(A2)-logsumexp(b3*Q2);
            
       else
                       % store stuff
            A = output.low.A(k,1);

            Q = output.low.Q(k,:);
            
            lik = lik + b1*Q(A)-logsumexp(b1*Q);
    
       end  
    end   
    if model==7
          
       if con(k) == 1  % high effort trial

 
            action = output.high.action(k); %choice 0
            A2 = output.high.A(k); %choice 1


            Q1 = output.high.Q(1,:,k);
            Q2 = output.high.Q(2,:,k);
            
            lik = lik + b1*Q1(action)-logsumexp(b1*Q1);    
            lik = lik + b1*Q2(A2)-logsumexp(b1*Q2);
            
       else
                       % store stuff
            A = output.low.A(k,1);

            Q = output.low.Q(k,:);
            
            lik = lik + b1*Q(A)-logsumexp(b1*Q);
    
       end
    end   
    if model==8
          
       if con(k) == 1  % high effort trial

 
            action = output.high.action(k); %choice 0
            A2 = output.high.A(k); %choice 1


            Q1 = output.high.Q(1,:,k);
            Q2 = output.high.Q(2,:,k);
            
            lik = lik + b2*Q1(action)-logsumexp(b2*Q1);    
            lik = lik + b3*Q2(A2)-logsumexp(b3*Q2);
            
       else
                       % store stuff
            A = output.low.A(k,1);

            Q = output.low.Q(k,:);
            
            lik = lik + b1*Q(A)-logsumexp(b1*Q);
    
       end
    end
end

lik = -lik;
end
