%=========================================================================%
% Simulation script for parameter recovery and model identifiability
% from Correa CMC, et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% Needs Matlab R2014b or more recent, Matlab's Statistics and Machine Learning and optimization 
% toolboxes, and the VBA toolbox (https://mbb-team.github.io/VBA-toolbox/)
% Author: Mael Lebreton
% email: mael.lebreton@unige.ch
%=========================================================================%


%% PRELIMINARY STUFF

% prepare workspace
clc
clear
close all

% set random number generator to random seed (current time)
rng('shuffle')


%% INITIALISE FREE-PARAMETERS

% load fitted parameters
load('ParamsFull_2016_11.mat')
estim_params = squeeze(parameters(:,:,18));

% fit gamma distribution of beta (inverse temperature) on fitted parameters
pdB1  = fitdist(estim_params(:,11),'Gamma');
pdB2  = fitdist(estim_params(:,2),'Gamma');

% fit beta distribution of alpha (learning rate) on fitted parameters
pda1  = fitdist(estim_params(:,3),'Beta');
pda2  = fitdist(estim_params(:,4),'Beta');

% set normal distribution of pi (perseveration bias) on fitted parameters
pdPi1  = fitdist(estim_params(:,5),'Normal');
pdPi2  = fitdist(estim_params(:,6),'Normal');

% set options for fmincon
options = optimset('Algorithm', 'interior-point', 'MaxIter', 1000000);

rep     = 1; % number of run per subject
nsub    = rep*32; % N subjects

% weighting matrix for parameter setting
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


%% COMPUTE MODELS 


for k_it = 1:10 % for ten iterations
    
    clear ll ll_rep bic recov_param
    close all force
    
    
    for k_sim = 1:18 % for each model (SIM)
        
        n = 32; % N subjects
        
        % sample free-parameters from their related distribution
        B1  = random('Gamma',4,.5,n,1);
        B2  = random('Gamma',1.5,1,n,1);
        LR1 = random('Beta',5,1.5,n,1);
        LR2 = random('Beta',1.5,5,n,1);
        P1  = random('Normal',.7,.8,n,1);
        P2  = random('Normal',1.7,1.2,n,1);
        
        
        for k_sub=1:nsub % for each subject
            
            % get data
            resultname = strcat(fullfile('SubData',strcat('Sub',num2str(nsub),'data')));
            load(resultname);
            
            % get task information
            con  = data(:,4);                 % reward visibility (1=unconscious, 0=conscious)
            cor  = round((data(:,3)==1) +1);  % 3: block ID (1=right response rewards most, 3=left response rewards most)
            
            % get parameters for simulation (w/ weighting matrix)
            P(k_sub,k_sim,:) = [B1(k_sub),B2(k_sub),LR1(k_sub),LR2(k_sub),P1(k_sub),P2(k_sub)] .* KK(k_sim,:); 
            
            % get models simulations (prediction error, probability of
            % choice, choice, outcome) based on parameters and task
            % information
            [PE_Sim,Pc_Sim,~,cho,~,out] = compute_model_simu_2018_05(squeeze(P(k_sub,k_sim,:)),con,cor,k_sim);
            
            
            for k_est=1:18 % for each model (FIT ON SIM = RECOVERY)
                
                n_rep = 1;
                
                % initialize matrix for free-parameters
                parameters_rep = NaN(n_rep,6);
                
                % initialize matrix for related loglikelihood
                ll_rep = NaN(n_rep,1);
                
                % for k_rep = 1:n_rep
                k_rep = 1;
                
                % compute param and loglikelihood based on simulations
                % script, parameter sampling (with lower and upper bounds)
                % and options
                [parameters_rep(k_rep,1:6),ll_rep(k_rep,1)] = fmincon(@(x) compute_model_LL_2018_05(x,con,cho,out,k_est),[10*rand() 10*rand() rand() rand() 10*rand() 10*rand()],[],[],[],[],[0 0 0 0 -10 -10],[10 10 1 1 10 10],[],options);
                
                % end
                
                
                % [~,pos] = min(ll_rep);
                
                % recov_param(k_sim).val(k_sub,k_est,:)= parameters_rep(pos(1),:).*KK(k_est,:);
                % ll(k_sim).val(k_sub,k_est)= ll_rep(pos(1),:);
                
                % get param and loglikelihood 
                recov_param(k_sim).val(k_sub,k_est,:) = parameters_rep(1,:) .* KK(k_est,:);
                ll(k_sim).val(k_sub,k_est) = ll_rep(1,:);
                
            end % for each model (RECOVERY)
            
            
        end % for each subject
        
        
    end % for each model (SIM)
    
    
    for k_sim = 1:18 % for each model
        
        % get model parameters and loglikelihood
        MP = recov_param(k_sim).val;
        LL = ll(k_sim).val;
        
        % input number of free-parameters per model
        nfpm = [2 2 3 3 3 4 4 4 5];
        nfpm = [nfpm nfpm+1]; % 9 models + 1 free parameters for each model (= full model space)
        
        
        for n=1:18
            
            % compute BIC
            bic(:,n)= -2 * -LL(:,n) + nfpm(n) * log(1200); % l2 is already positive
            
        end
        
        
        % perform Bayesian model comparison (with cool VBA Toolbox)
        [posteriorAdo,outAdo] = VBA_groupBMC(-bic'./2);
        
        % get BMC outputs
        BMC_output(k_sim).post = posteriorAdo;
        BMC_output(k_sim).out  = outAdo;
        
    end
   
    
    %% END ANALYSIS
    
    close all force
    
    
    %% SAVE DATA
    
    xt        = datetime;
    add_rnd   = round(100*rand());
    flnm      = strcat('Simus_Distr_',num2str(datenum(xt)),'_',num2str(add_rnd),'.mat');
    full_flnm = fullfile('multiple_sims3',flnm);
    
    disp(datetime(xt,'ConvertFrom','datenum'))
    
    save(full_flnm)
    
end %for each iteration
