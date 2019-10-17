
%=========================================================================%
% Simulation script for parameter recovery and model identifiability
% Adappted from Correa et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% and Kool, Gershman, Cushman (2018) J.CogNeuro (https://doi.org/10.1162/jocn_a_01263)
% Needs Matlab R2014b or more recent, Matlab's Statistics and Machine Learning and optimization 
% toolboxes, and the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/)
% Author: David Munoz Tord - david.munoz@etu.unige.ch


clc
clear
close all

rng('shuffle')

% % %%%
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
nsub    = 98; 
iterations =50; 
models = 2; 
param =3;
ntrials = 200; 


% set estimation options
options     = optimset('Algorithm', 'interior-point', 'MaxIter', 1000000);

%% parameteres ; 
%beta1, beta2, beta3, alpha, lamda,  w1, w2, w3
LB = [0 0 0]; % lower bounds 
%UB = [20 20 20 1 1 1 1 1]; % upper bounds WHY  upper bounds = 20 if random UP = 4??
UB = [10 1 1]; 

%notes
%simu.recov -> column = model // val = param
% Model options #well .. model 6 first for now
KK = [1 1 1;... %1 MF simple %chanef 6 =0
      1 1 1];%... %2 MB simple %chanef 6 =0
      %1 1 1 1 0 0;... %3 MF exhaustive 3beta %chanef 6 =0
      %1 1 1 0 1 1];%... %4 MB exhaustive 3beta %chanef 6 =0
      %1 1 1 1 0 0;... %5 Mix model simple
      %1 1 1 1 1 1 0 0;... %6 Mix model simple     3beta 1weight
      %1 1 1 1 1 1];%;... %7 Mix model simple     1beta 3weight
      %1 1 1 1 1 1 1 1]; %8 Mix model exhaustive
%     1 0 1 0 1 1 0 0;... %The transition-dependent learning rates (TDLR) algorithm
%     1 0 1 0 1 1 0 0];... %The unlucky-symbol algorithm

nfpm = [3 3];
%nfpm = [3 3 3 3 3 3 3 3];
%nfpm = [3 3 5 5 4 6 6 8]; % X X];
%nfpm = [4 4 6 6 4 6 6 8]; % X X];
  

tic
%% simulation loop
for k_it = 1:iterations %# 50 before
    tic
    clear ll ll_rep bic recov_param
    close all force
       
    % simulate with all possible models
    for k_sim = 1:models
  
        % sample parameters %should the same subject have the same
        % parameters?
        n   = nsub;
        
        B1  = random('Gamma',4,.5,n,1);
        %B2  = random('Gamma',4,.5,n,1);
        %B3  = random('Gamma',4,.5,n,1);
        
        LR = random('Beta',5,1.5,n,1);
        
        LAMBDA  = random('Uniform',0,1,n,1);
        
        
        %W1  = random('Uniform',0,1,n,1);
        %W2  = random('Uniform',0,1,n,1);
        %W3  = random('Uniform',0,1,n,1);

        % simulate data
        for k_sub=1:nsub
              
            % get task structure from behavioral data
            data = SUBDATA(k_sub); %%% was ksub instead of k_sub %%% 
            con  = data.high_effort; %%% 0 or 1 %cor  = round((data(:,3)==1) +1); %# block number? WELLLLL ****

            % simulate behavior with sampled parameters . // B2(k_sub), B3(k_sub),
            SimRun(k_it).simu_param(k_sub,k_sim,:)  = [B1(k_sub), LR(k_sub), LAMBDA(k_sub)].*KK(k_sim,:); %

            addpath ~/Project/mfit/
            cd ~/Project/Kool/scripts/expe1

            %% Rewards
            data.bounds = [0 9];
            data.sd = 2;
            rews = C_i_generate_rews(ntrials,data.bounds,data.sd);
            rews = rews./9;

            %% SARS
            output  = C_ii_MBMF_sim(squeeze(SimRun(k_it).simu_param(k_sub,k_sim,:)),con, rews, k_sim);   %# returns S A R & S1
            SimRun(k_it).rewardrate(k_sim).val(k_sub) = sum(output.R)/length(output.R); 
            % re-estimate parameters with all possible models
            for k_est=1:models
                  
                x0                                                  = [10*rand() rand() rand()];% rand() rand()]; % 10*rand() 10*rand()% parameter initial value ?ok at ten?
                [parameters_rep(1,1:param),ll_rep]                  = fmincon(@(x) C_iii_MBMF_model_ll(x,con, output, k_est),x0,[],[],[],[],LB,UB,[],options); %changed out by rews
                                                                  % [x,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
                SimRun(k_it).recov_param(k_sim).val(k_sub,k_est,:)  = parameters_rep.*KK(k_est,:);
                SimRun(k_it).ll(k_sim).val(k_sub,k_est)             = ll_rep;
            end
        end
    end
  
    % model comparison step, for each simulation
    for k_sim = 1:models 
        
        
        LL                                      = SimRun(k_it).ll(k_sim).val; 
        for n=1:models
            
            SimRun(k_it).bic(:,n)               = -2*-LL(:,n) + nfpm(n)*log(ntrials); % bayesian Information criterion = -2*L + k*log(n)
            SimRun(k_it).aic(:,n)               = 2*nfpm(n)-2*log(LL(:,n));  %AIC=2k-2log(L)

        end     
        [posteriorAdo,outAdo]                   = VBA_groupBMC(-SimRun(k_it).bic'./2); 
        SimRun(k_it).BMC_output(k_sim).post     = posteriorAdo;
        SimRun(k_it).BMC_output(k_sim).out      = outAdo;
        
        [posteriorAdoAIC,outAdoAIC]                   = VBA_groupBMC(-SimRun(k_it).aic'./2); %??
        SimRun(k_it).BMC_outputAIC(k_sim).post     = posteriorAdoAIC;
        SimRun(k_it).BMC_outputAIC(k_sim).out      = outAdoAIC;
        
    end
    
    disp(['Iteration ', num2str(k_it), '/', num2str(k_sub),'.'])
    toc
    close all force
    
end
toc
%% save files
n_iter = num2str(iterations);
save('SIMU_RECOVERY_Kool_MB_VS_MF_98x50','SimRun')

%% notes


