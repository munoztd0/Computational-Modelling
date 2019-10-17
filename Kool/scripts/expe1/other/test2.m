%% pre-Allocate
choice0 = randi([1 3],200,1);
choice1 = randi([1 6],200,1);

s=1;
condition = 1;

state2 = randi([1 3],200,1);

model = 1;

ntrials = 12;

rf1     = rand(12,1); % random number to implement stochadtic choice
rf2     = rand(12,1); % random number to attribute reward
prevC   = rand>.5 +1;
pST     = 0;
pCT     = 0;
pc(1) = .5;

Q    = zeros(ntrials,2);
ch   = NaN(ntrials,1);
pc   = NaN(ntrials,1);                % the likelihood of the observed choice
PE   = NaN(ntrials,1);
r    = NaN(ntrials,1);
per  = NaN(ntrials,1);
dQ   = NaN(ntrials,1);

%% initialization
dtQ = zeros(3,1);

%% Loop
for k = 1:12
    
    per(k)  = (prevC == 1)*2-1;
    dQ(k)   = Q(k,1) - Q(k,2);
    
%     C1 = s(k)==0;
%     ST = s(k)==1;
    
    if model==1
        
        pc(k) = (1./(1+exp(-beta1 *dQ(k))));
        
        if pc(k)>.5
            
            choice0 = choice0;
        else
            choice0 = 
            
        ch(k)   = 2 - (rf1(k) < pc(k));
        rwd     = rf2(k) < (.3 +.4.*double(ch(k) == b(k)));
        r(k)    =  rwd*2-1;
        PE(k)   =  r(k) - Q(k,ch(k));
        
        Q(k+1,ch(k)) = Q(k,ch(k)) + lr1 * PE(k);
        
        
%         if condition(k)==1
%         % top level
%         dtQ(1) = Qmf_middle(choice1(k)) - Qmf_top(choice0(k));
%         Qmf_top(choice0(k)) = Qmf_top(choice0(k)) + lr*dtQ(1);
%         end
    end
    
end