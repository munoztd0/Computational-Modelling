% This function generates the likelihood of each model/paramters

function [kPE,kpc,kQ,kch] = compute_model_output(params,s,a,r,model)

beta1 = params(1);% choice temperature
beta2 = params(2);
lr1   = params(3); % supraliminal learning rate
lr2   = params(4); % subliminal learning rate
pi1   = params(5);
pi2   = params(6);


% PreAllocate
kQ    = zeros(1200,2);
kch   = NaN(1200,1);
kpc   = NaN(1200,1);       % the likelihood of the observed choice
kPE   = NaN(1200,1);

% Initialize
prevC   = rand>.5 +1;
pST     = 0;
pCT     = 0;
Q       = zeros(1,2);

k=0;
for i = 1:length(a)
    
    if a(i)
        k=k+1;
        
        ch  = a(i)==1;
        per = (prevC == 1)*2-1;
        dQ  = Q(1) - Q(2);
        PE  =  r(i) - Q(a(i));
        
        CT  = s(i)==0;
        ST  = s(i)==1;
        
        if model==1
            
            pc          = (1./(1+exp(-beta1 *dQ)));
            Q(a(i))     = Q(a(i)) + lr1 * PE; % simple RL
            
        elseif model==2
            
            pc          = (1./(1+exp(-beta1 *dQ)));
            Q(a(i))     = Q(a(i)) + (CT*lr1) * PE; % simple RL
            
        elseif model==3
            
            pc          = (1./(1+exp(-beta1 *dQ)));
            Q(a(i)) 	= Q(a(i)) + (CT*lr1 + ST*lr2) * PE ;  % RL with different LR for Sub and consc
            
        elseif model==4
            
            pc          = (1./(1+exp(-beta1 *dQ - pi1*per)));
            Q(a(i))     = Q(a(i)) + lr1 * PE; % simple RL

        elseif model==5
            
            pc          = (1./(1+exp(-beta1 *dQ - pi1*per)));
            Q(a(i))     = Q(a(i)) + (CT*lr1).* PE; % simple RL
            
        elseif model==6
            
            pc          = (1./(1+exp(-beta1 *dQ - pi1*per)));
            Q(a(i))     = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
            
        elseif model==7
            
            pc          = (1./(1+exp(-beta1 *dQ - pi1*pCT*per - pi2*pST*per)));
            Q(a(i))     = Q(a(i)) + lr1.* PE; % simple RL
              
        elseif model==8
            
            pc          = (1./(1+exp(-beta1 *dQ - pi1*pCT*per - pi2*pST*per)));
            Q(a(i))     = Q(a(i)) + (CT*lr1).* PE; % simple RL
            
        elseif model==9
            pc          = (1./(1+exp(-beta1 *dQ - pi1*pCT*per - pi2*pST*per)));
            Q(a(i))     = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
            
        elseif model==10
            
            pc          = (1./(1+exp(- beta1*pCT*dQ - beta2*pST*dQ)));
            Q(a(i))     = Q(a(i)) + lr1 * PE; % simple RL
 
        elseif model==11
            
            pc          = (1./(1+exp(- beta1*pCT*dQ - beta2*pST*dQ)));
            Q(a(i))     = Q(a(i)) + (CT*lr1) * PE; % simple RL
            
        elseif model==12
            
            pc          = (1./(1+exp(- beta1*pCT*dQ - beta2*pST*dQ)));
            Q(a(i))     = Q(a(i)) + (CT*lr1 + ST*lr2) * PE ;  % RL with different LR for Sub and consc
            
        elseif model==13
            
            pc          = (1./(1+exp(- beta1*pCT*dQ - beta2*pST*dQ - pi1*per)));
            Q(a(i))     = Q(a(i)) + lr1 * PE; % simple RL
            
        elseif model==14
            
            pc          = (1./(1+exp(- beta1*pCT*dQ - beta2*pST*dQ - pi1*per)));
            Q(a(i))     = Q(a(i)) + (CT*lr1).* PE; % simple RL
            
        elseif model==15
            
            pc          = (1./(1+exp(- beta1*pCT*dQ - beta2*pST*dQ - pi1*per)));
            Q(a(i))     = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
            
        elseif model==16
            
            pc          = (1./(1+exp(- beta1*pCT*dQ - beta2*pST*dQ - pi1*pCT*per - pi2*pST*per)));
            Q(a(i))     = Q(a(i)) + lr1.* PE; % simple RL
            
        elseif model==17
            
            pc          = (1./(1+exp(- beta1*pCT*dQ - beta2*pST*dQ - pi1*pCT*per - pi2*pST*per)));
            Q(a(i))     = Q(a(i)) + (CT*lr1).* PE; % simple RL       
            
        elseif model==18
            
            pc          = (1./(1+exp(- beta1*pCT*dQ - beta2*pST*dQ - pi1*pCT*per - pi2*pST*per)));
            Q(a(i))     = Q(a(i)) + (CT*lr1 + ST*lr2).* PE; % simple RL
            
        end
        
            prevC   = a(i);
            pCT     = CT;
            pST     = ST; 
        
        % store 
        kPE(i)      = PE;
        kpc(i)      = pc;
        kQ(i,:)     = Q;
        kch(i)      = double(ch);
        
    else
        
        % manage missed trials
        kPE(i)      = NaN;
        kpc(i)      = NaN;
        kQ(i,:)     = NaN(1,2);
        kch(i)      = NaN;
        
    end
end
