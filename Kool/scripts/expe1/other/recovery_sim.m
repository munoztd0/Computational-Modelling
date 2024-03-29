
%==========================KOOL===============================================%
% Simulation script for parameter recovery and model identifiability
% Adappted from Correa CMC, et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% Needs Matlab R2014b or more recent, Matlab's Statistics and Machine Learning and optimization 
% toolboxes, and the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/)
% Author: David Munoz

clc
clear
close all

rng('shuffle')

% %%%
% cd ~/Project/VBA-toolbox/
% VBA_setup()
% 
cd ~/Project/Kool/data/
% %%%

dbstop if error

try 
    VBA_version;
catch
    warning('You should download the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/) to run the code')
end


%% load data
load('SUBDATA')


%# declare variables
nsub    = 98; % N subjects
iterations = 10; 
models = 6; 
param = 8;
ntrials = 200;


% set estimation options
options     = optimset('Algorithm', 'interior-point', 'MaxIter', 1000000);

%% parameteres ; 
%beta1, beta2, beta3, alpha, lamda,  w1, w2, w3
LB = [0 0 0 0 0 0 0 0]; % lower bounds 
UB = [20 20 20 1 1 1 1 1]; % upper bounds

% Model options #well .. model 6 first for now
KK = [1 0 0 1 1 0 0 0;... %1 MF simple %should be 1 0 0 1 1 0 0 0
    1 0 0 1 1 0 0 0;... %2 MB simple
    1 1 1 1 1 0 0 0;... %3 MF exhaustive
    1 1 1 1 1 0 0 0;... %4 MB exhaustive
    1 0 0 1 1 1 1 1;... %5 Mix model simple
    1 1 1 1 1 1 1 1]; %6 Mix model exhaustive
%     1 0 1 0 1 1 0 0;... %The transition-dependent learning rates (TDLR) algorithm
%     1 0 1 0 1 1 0 0];... %The unlucky-symbol algorithm


nfpm = [3 3 5 5 6 8]; % X X];
%nfpm = [nfpm nfpm+1]; % number of free parameters per model

%% simulation loop
for k_it = 1:iterations %# 50 before
    
    clear ll ll_rep bic recov_param
    close all force
       
    % simulate with all possible models
    for k_sim = 1:models
        
        % sample parameters
        n   = nsub;
        
        B1  = random('Gamma',4,.5,n,1);
        B2  = random('Gamma',4,.5,n,1);
        B3  = random('Gamma',4,.5,n,1);
        
        LR = random('Beta',5,1.5,n,1);
        
        LAMBDA  = random('Uniform',0,1,n,1);
        
        W1  = random('Uniform',0,1,n,1);
        W2  = random('Uniform',0,1,n,1);
        W3  = random('Uniform',0,1,n,1);


        % simulate data
        for k_sub=1:nsub
            
            
            % get task structure from behavioral data
            data = SUBDATA(k_sub); %%% was ksub instead of k_sub %%% 
            con  = data.high_effort; %%% 0 or 1
            %cor  = round((data(:,3)==1) +1); %# block number? WELLLLL ****
            %OUT
            %cor = ones(length(con),1);
            % simulate behavior with sampled parameters
            SimRun(k_it).simu_param(k_sub,k_sim,:)  = [B1(k_sub), B2(k_sub), B3(k_sub), LR(k_sub), LAMBDA(k_sub), W1(k_sub),W2(k_sub),W3(k_sub)].*KK(k_sim,:);

            %% Rewards
            
            addpath ~/Project/mfit/
            cd ~/Project/Kool/scripts/expe1
            
            rng shuffle

            data.bounds = [0 9];
            data.sd = 2;

            ws = 0:1/10:1;
            
            rews = generate_rews(ntrials,data.bounds,data.sd);
            rews = rews./9;

            rewardrate = zeros(1,length(ws));
            
            A = median(B1(:));
            B = median(LR(:));
            C = median(LAMBDA(:));
            x = [A B C];
            %x = median(results.x(:,1:3)); %%%
            %ned b, lr lamda
            
            W = 0 ;
            
            
% 
%             for w_i = 1:length(ws)
%         
%                 W1(4) = ws(w_i);
%         %###
%                 output = MBMF_high_effort_arm_sim(x,rews);          % simulate behavior
%                 rewardrate(w_i) = sum(output.R)/length(output.R);   % store reward rate for each value of w
%         
%             end
%     
%             params = polyfit(zscore(ws),zscore(rewardrate),1);      % compute slope
%             
%             data.slope(i) = params(1);
%             data.rewardrate(:,i) = rewardrate;
            
            %%

       
            output  = draft_MBMF_sim(squeeze(SimRun(k_it).simu_param(k_sub,k_sim,:)),con, rews, k_sim);   
            
            %%%% until here!!
            
            % re-estimate parameters with all possible models
            for k_est=1:models
                x0                                                  = [10*rand() 10*rand() 10*rand() rand() rand() rand() rand() rand()]; % parameter initial value ?ok?
                [parameters_rep(1,1:models),ll_rep]                      =   fmincon(@(x) compute_model_LL(x,con,out,k_est),x0,[],[],[],[],LB,UB,[],options);
                %until then
                SimRun(k_it).recov_param(k_sim).val(k_sub,k_est,:)  = parameters_rep.*KK(k_est,:);
                SimRun(k_it).ll(k_sim).val(k_sub,k_est)             = ll_rep;
            end
        end
    end
  
    % model comparison step, for each simulation
    for k_sim = 1:models        
        LL                                      = SimRun(k_it).ll(k_sim).val; %%% same change here %%%
        for n=1:models
            SimRun(k_it).bic(:,n)               = -2*-LL(:,n) + nfpm(n)*log(ntrials); % bayesian Information criterion
        end     
        [posteriorAdo,outAdo]                   = VBA_groupBMC(-SimRun(k_it).bic'./2); %%% same change here %%%
        SimRun(k_it).BMC_output(k_sim).post     = posteriorAdo;
        SimRun(k_it).BMC_output(k_sim).out      = outAdo;
        
    end
    
    disp(['Iteration ', num2str(k_it), '/', num2str(k_sub),'.'])
    
    close all force
end

%% save files
save('SIMU_RECOVERY_Kool10','SimRun')

%% notes
        %whatout the order

        %A and B, respectively.
        % Kool 2016
        % weighting parameter w, ranging from 0 to 1, 
        %the inverse temperature, ranging from 0 to 10, 
        %and the learning rate, ranging from 0 to 10. ???
        % eligibility trace parameter was fixed at a value that corresponded approximately with previous reports of this task, 
        %λ = 0.5, 
        
        %For each agent, we randomly sampled parameters from uniform distributions: 
        % (alpha,lamda, weigh, ~U(0,+1) // Beta ~U(0,+2) 
        
        
        %% Kool parameters %%%

        % % parameters
        % b_low = x(1);           % softmax inverse temperature
        % b_high0 = x(2);           % softmax inverse temperature
        % b_high1 = x(3);           % softmax inverse temperature
        % lr = x(4);          % learning rate
        % lambda = x(5);      % eligibility trace decay
        % w_low = x(6);           % mixing weight
        % w_high0 = x(7);           % mixing weight
        % w_high1 = x(8);           % mixing weight
