% This function generates the likelihood of each model/paramters

% need to adapt parameters !!
function lik = compute_model_LL(params,s,a,r,model)

        %% Kool parameters %%%

%         b = x(1);           % softmax inverse temperature
%         lr = x(2);          % learning rate
%         lambda = x(3);      % eligibility trace decay
%         w_low = x(4);           % mixing weight
%         w_high0 = x(5);           % mixing weight
%         w_high1 = x(6);           % mixing weight



beta1 = params(1);                                                              % choice temperature
beta2 = params(2);
lr1   = params(3);                                                             % supraliminal learning rate
lr2   = params(4);                                                             % subliminal learning rate
pi1   = params(5);
pi2   = params(6);

Q     = zeros(1,2);

lik   = 0;
prevC = rand>.5 +1;

pST = 0;
pCT = 0;

for i = 1:length(a)
    
    
    if a(i)
                
        per = (prevC == a(i))*2-1;  % perseveration
        dQ = Q(a(i)) - Q(3-a(i));
        
        PE =  r(i) - Q(a(i));
        
        ST = s(i)==1;
        CT = s(i)==0;        
        
       if model==1
            
            lik = lik + log(1./(1+exp(-beta1 *dQ)));
            Q(a(i)) = Q(a(i)) + lr1 * PE; % simple RL
            
       elseif model==2
            
            lik = lik + log(1./(1+exp(-beta1 *dQ)));
            Q(a(i)) = Q(a(i)) + (CT*lr1) * PE; % simple RL  
            
        elseif model==3
            
            lik = lik + log(1./(1+exp(-beta1 *dQ)));
            Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2) * PE ;  % RL with different LR for Sub and consc 
            
        elseif model==4
            
            lik = lik + log(1./(1+exp(-beta1 *dQ - pi1*per)));
            Q(a(i)) = Q(a(i)) + lr1 * PE; % simple RL
            
       elseif model==5
            
            lik = lik + log(1./(1+exp(-beta1 *dQ - pi1*per)));
            Q(a(i)) = Q(a(i)) + (CT*lr1).* PE; % simple RL 

        elseif model==6
            
            lik = lik + log(1./(1+exp(-beta1 *dQ - pi1*per)));
            Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL

        elseif model==7
            
            lik = lik + log(1./(1+exp(-beta1 *dQ - (pi1*pCT + pi2*pST)*per)));
            Q(a(i)) = Q(a(i)) + lr1.* PE; % simple RL
       
       elseif model==8
            
            lik = lik + log(1./(1+exp(-beta1 *dQ - (pi1*pCT + pi2*pST)*per)));
            Q(a(i)) = Q(a(i)) + (CT*lr1).* PE; % simple RL
            
        elseif model==9
            
            lik = lik + log(1./(1+exp(-beta1 *dQ - (pi1*pCT + pi2*pST)*per)));
            Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
            
       elseif model==10
            
            lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ)));
            Q(a(i)) = Q(a(i)) + lr1 * PE; % simple RL
            
       elseif model==11
            
            lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ)));
            Q(a(i)) = Q(a(i)) + (CT*lr1) * PE; % simple RL
            
        elseif model==12
            
            lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ)));
            Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2) * PE ;  % RL with different LR for Sub and consc
            
        elseif model==13
            
            lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - pi1*per)));
            Q(a(i)) = Q(a(i)) + lr1 * PE; % simple RL
            
       elseif model==14
            
            lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST)*dQ - pi1*per)));
            Q(a(i)) = Q(a(i)) + (CT*lr1).* PE; % simple RL

        elseif model==15
            
            lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - pi1*per)));
            Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL

        elseif model==16
            
            lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - (pi1*pCT + pi2*pST)*per)));
            Q(a(i)) = Q(a(i)) + lr1.* PE; % simple RL
       
       elseif model==17
            
            lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - (pi1*pCT + pi2*pST)*per)));
            Q(a(i)) = Q(a(i)) + (CT*lr1).* PE; % simple RL
            
        elseif model==18
            
            lik = lik + log(1./(1+exp(-(beta1*pCT + beta2*pST) *dQ - (pi1*pCT + pi2*pST)*per)));
            Q(a(i)) = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
            
       end
       
            prevC = a(i);
            pCT = CT;
            pST = ST;
        
    end
end

lik = -lik;                                                                               % loglikelyhood vector
