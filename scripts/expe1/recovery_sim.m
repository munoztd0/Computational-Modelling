
%==========================KOOL===============================================%
% Simulation script for parameter recovery and model identifiability
% from Correa CMC, et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% Needs Matlab R2014b or more recent, Matlab's Statistics and Machine Learning and optimization 
% toolboxes, and the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/)
% Author: Mael Lebreton

clc
clear
close all

rng('shuffle')

%%%
cd ~/Project/VBA-toolbox/
VBA_setup()

cd ~/Project/Kool/data/
%%%

dbstop if error

try 
    VBA_version;
catch
    warning('You should download the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/) to run the code')
end


%% load data
load('SUBDATA')


%# declare variables
nsub    = 101; % N subjects
iterations = 10; 
models = 18; 


% set estimation options
options     = optimset('Algorithm', 'interior-point', 'MaxIter', 1000000);


LB = [0 0 0 0 0 0]; % parameters lower bounds 
UB = [20 1 1 1 1 1]; % parameters upper bounds

% Model options #well .. I'm gonna do the same for now
KK = [1 1 0 0 0 0 0 0;... %1 MF simple
    1 1 1 0 0 0 0 0;... %2 MB simple
    1 1 1 1 1 0 0 0;... %3 MF exhaustive
    1 1 1 1 1 0 0 0;... %4 MB exhaustive
    1 1 1 1 1 1 0 0;... %5 Mix model simple
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
        
        LR = random('Beta',5,1.5,n,1);
        LAMDA  = random('Uniform',0,1,n,1);
        B_low  = random('Gamma',4,.5,n,1);
        B_high0  = random('Gamma',4,.5,n,1);
        B_high1  = random('Gamma',4,.5,n,1);

        W_low  = random('Uniform',0,1,n,1);
        W_high0  = random('Uniform',0,1,n,1);
        W_high1  = random('Uniform',0,1,n,1);
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


        % simulate data
        for k_sub=1:nsub
            
            
            % get task structure from behavioral data
            data = SUBDATA.experiment_1(k_sub); %%% was ksub instead of k_sub %%% 
            con  = data.high_effort; %%% 0 or 1
            %cor  = round((data(:,3)==1) +1); %# block number? WELLLLL ****
            cor = ones(length(con),1);
           
            % simulate behavior with sampled parameters
            SimRun(k_it).simu_param(k_sub,k_sim,:)  = [B(k_sub),LR(k_sub),LAMDA(k_sub),W_low(k_sub),W_high0(k_sub),W_high1(k_sub)].*KK(k_sim,:);

            cd ~/Project/Kool/scripts/expe1
       
            [PE_Sim,Pc_Sim,~,cho,out]               = compute_model_simu(squeeze(SimRun(k_it).simu_param(k_sub,k_sim,:)),con,cor,k_sim);
            %%% needed to change the P(k_sub,k_sim,:) in %%%
            %%% SimRun(k_it).simu_param(k_sub,k_sim,:) in order to work %%%
            
            % re-estimate parameters with all possible models
            for k_est=1:18
                x0                                                  = [10*rand() 10*rand() rand() rand() 10*rand() 10*rand()]; % parameter initial value
                [parameters_rep(1,1:6),ll_rep]                      =   fmincon(@(x) compute_model_LL(x,con,cho,out,k_est),x0,[],[],[],[],LB,UB,[],options);
                SimRun(k_it).recov_param(k_sim).val(k_sub,k_est,:)  = parameters_rep.*KK(k_est,:);
                SimRun(k_it).ll(k_sim).val(k_sub,k_est)             = ll_rep;
            end
        end
    end
  
    % model comparison step, for each simulation
    for k_sim = 1:18        
        LL                                      = SimRun(k_it).ll(k_sim).val; %%% same change here %%%
        for n=1:18
            SimRun(k_it).bic(:,n)               = -2*-LL(:,n) + nfpm(n)*log(1200); % bayesian Information criterion
        end     
        [posteriorAdo,outAdo]                   = VBA_groupBMC(-SimRun(k_it).bic'./2); %%% same change here %%%
        SimRun(k_it).BMC_output(k_sim).post     = posteriorAdo;
        SimRun(k_it).BMC_output(k_sim).out      = outAdo;
        
    end
    
    close all force
end

%% save files
save('SIMU_RECOVERY_Kool10','SimRun')