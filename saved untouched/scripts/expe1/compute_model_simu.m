% This function generates the likelihood of each model/paramters
%need to adapt this !
function [PE,pc,Q,ch,r] = compute_model_simu(params,s,b,model)


%% Parameters
% beta1 = params(1);                                                             % choice temperature
% beta2 = params(2);                                                             % choice temperature
% lr1   = params(3);                                                             % supraliminal learning rate
% lr2   = params(4);                                                             % subliminal learning rate
% pi1   = params(5);
% pi2   = params(6);

%# this is gonna me a mess to adapt#%

b = params(1);           % softmax inverse temperature
lr = params(2);          % learning rate
lambda = params(3);      % eligibility trace decay
w_low = params(4);           % mixing weight
w_high0 = params(5);           % mixing weight
w_high1 = params(6);           % mixing weight


ntrials = length(b); %# changing hard coded 1200 by ntrials 

%% pre-Allocate
Q    = zeros(ntrials,2);
ch   = NaN(ntrials,1);
pc   = NaN(ntrials,1);                % the likelihood of the observed choice
PE   = NaN(ntrials,1);
r    = NaN(ntrials,1);
per  = NaN(ntrials,1);
dQ   = NaN(ntrials,1);

%% Initialize
rf1     = rand(ntrials,1); % random number to implement stochastic choice
rf2     = rand(ntrials,1); % random number to attribute reward
prevC   = rand>.5 +1;
pST     = 0;
pCT     = 0;
pc(1) = .5;

%% Loop
for k = 1:ntrials 
    
    per(k)  = (prevC == 1)*2-1;
    dQ(k)   = Q(k,1) - Q(k,2);
    
    CT = s(k)==0;
    ST = s(k)==1;
    
    if model==1
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + lr1 * PE(k);
        
    elseif model==2
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1) * PE(k);
        
    elseif model==3
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1 + ST*lr2) * PE(k);

        
    elseif model==4
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k) - pi1*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + lr1 * PE(k);
        
    elseif model==5
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k) - pi1*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1).* PE(k);
        
    elseif model==6
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k) - pi1*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1 + ST*lr2).* PE(k);
        
    elseif model==7
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k) - pi1*pCT*per(k) - pi2*pST*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + lr1.* PE(k);
        
    elseif model==8
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k) - pi1*pCT*per(k) - pi2*pST*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1).* PE(k);
        
    elseif model==9
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k) - pi1*pCT*per(k) - pi2*pST*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1 + ST*lr2).* PE(k);
        
    elseif model==10
        
        pc(k) = (1./(1+exp(- beta1*pCT*dQ(k) - beta2*pST*dQ(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + lr1 * PE(k);
        
    elseif model==11
        
        pc(k) = (1./(1+exp(- beta1*pCT*dQ(k) - beta2*pST*dQ(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1) * PE(k);
        
    elseif model==12
        
        pc(k) = (1./(1+exp(- beta1*pCT*dQ(k) - beta2*pST*dQ(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1 + ST*lr2) * PE(k) ;
        
    elseif model==13
        
        pc(k) = (1./(1+exp(- beta1*pCT*dQ(k) - beta2*pST*dQ(k) - pi1*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + lr1 * PE(k);
        
    elseif model==14
        
        pc(k) = (1./(1+exp(- beta1*pCT*dQ(k) - beta2*pST*dQ(k) - pi1*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1).* PE(k);
        
    elseif model==15
        
        pc(k) = (1./(1+exp(- beta1*pCT*dQ(k) - beta2*pST*dQ(k) - pi1*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1 + ST*lr2).* PE(k);
        
    elseif model==16
        
        pc(k) = (1./(1+exp(- beta1*pCT*dQ(k) - beta2*pST*dQ(k) - pi1*pCT*per(k) - pi2*pST*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + lr1.* PE(k);
        
    elseif model==17
        
        pc(k) = (1./(1+exp(- beta1*pCT*dQ(k) - beta2*pST*dQ(k) - pi1*pCT*per(k) - pi2*pST*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1).* PE(k);
        
    elseif model==18
        
        pc(k) = (1./(1+exp(- beta1*pCT*dQ(k) - beta2*pST*dQ(k) - pi1*pCT*per(k) - pi2*pST*per(k))));
        
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + (CT*lr1 + ST*lr2).* PE(k);
        
        
    end
    
    Q(k+1,3-ch(k))= Q(k,3-ch(k));
    
    prevC = ch(k);
    pCT = CT;
    pST = ST;
    
end
