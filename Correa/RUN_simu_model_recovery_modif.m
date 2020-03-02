
%=========================================================================%
% Simulation script for parameter recovery and model identifiability
% from Correa CMC, et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% Needs Matlab R2014b or more recent, Matlab's Statistics and Machine Learning and optimization 
% toolboxes, and the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/)
% Author: Mael Lebreton
% email: mael.lebreton@unige.ch
%=========================================================================%

clc
clear
close all

rng('shuffle')

try 
    VBA_version;
catch
    warning('You should the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/) to run the code')
end

% load data
load('SUB_DATA')
rep     = 1; %%% this part was missing
nsub = rep*32;

% set estimation options
options     = optimset('Algorithm', 'interior-point', 'MaxIter', 1000000);
LB = [0 0 0 0 -10 -10]; % parameters lower bounds
UB = [10 10 1 1 10 10]; % parameters upper bounds

% Model options
KK = [1 0 1 0 0 0;...
    1 0 1 0 0 0;...
    1 0 1 1 0 0;...
    1 0 1 0 1 0;...
    1 0 1 0 1 0;...
    1 0 1 1 1 0;...
    1 0 1 0 1 1;...
    1 0 1 0 1 1;...
    1 0 1 1 1 1;...
    1 1 1 0 0 0;...
    1 1 1 0 0 0;...
    1 1 1 1 0 0;...
    1 1 1 0 1 0;...
    1 1 1 0 1 0;...
    1 1 1 1 1 0;...
    1 1 1 0 1 1;...
    1 1 1 0 1 1;...
    1 1 1 1 1 1];

nfpm = [2 2 3 3 3 4 4 4 5];
nfpm = [nfpm nfpm+1]; % number of free parameters per model

% simulation loop
for k_it = 1:50
    
    clear ll ll_rep bic recov_param
    close all force
       
    % simulate with all possible models
    for k_sim = 1:18
        
        % sample parameters
        n   = 32;
        B1  = random('Gamma',4,.5,n,1);
        B2  = random('Gamma',1.5,1,n,1);
        LR1 = random('Beta',5,1.5,n,1);
        LR2 = random('Beta',1.5,5,n,1);
        P1  = random('Normal',.7,.8,n,1);
        P2  = random('Normal',1.7,1.2,n,1);
        
        % simulate data
        for k_sub=1:nsub
            
            % get task structure from behavioral data
            data = SubData(ksub).data;
            con  = data(:,4);
            cor  = round((data(:,3)==1) +1);
           
            % simulate behavior with sampled parameters
            SimRun(k_it).simu_param(k_sub,k_sim,:)  = [B1(k_sub),B2(k_sub),LR1(k_sub),LR2(k_sub),P1(k_sub),P2(k_sub)].*KK(k_sim,:);
            [PE_Sim,Pc_Sim,~,cho,out]               = compute_model_simu(squeeze(SimRun(k_it).simu_param(k_sub,k_sim,:)),con,cor,k_sim);
            
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
        LL                                      = SimRun(k_it).ll(k_sim).val;
        for n=1:18
            SimRun(k_it).bic(:,n)               = -2*-LL(:,n) + nfpm(n)*log(1200); % bayesian Information criterion
        end     
        [posteriorAdo,outAdo]                   = VBA_groupBMC(-SimRun(k_it).bic'./2);
        SimRun(k_it).BMC_output(k_sim).post     = posteriorAdo;
        SimRun(k_it).BMC_output(k_sim).out      = outAdo;
        
    end
    
    close all force
end

save('SIMU_RECOVERY','SimRun')
