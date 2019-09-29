
%=========================================================================%
% Model fitting scripts
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
subjects=1:32;

% set estimation options
options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000);
LB      = [0 0 0 0 -10 -10]; % parameters lower bounds
UB      = [10 10 1 1 10 10]; % parameters upper bounds
n_rep   = 10;

% Model options
nmodel  = 1:18;
nfpm    = [2 2 3 3 3 4 4 4 5];
nfpm    = [nfpm nfpm+1];% number of free parameters per model

% pre-allocate
parameters  = NaN(length(subjects),max(nfpm),length(nfpm));
ll          = NaN(length(subjects),length(nfpm));
bic         = NaN(length(subjects),length(nfpm));

% subject loop
for nsub=subjects
    
    data = SubData(nsub).data;   
    con  = data(:,4);                         % reward visibility (1=unconscious, 0=conscious)
    cor  = data(:,3);                         % 3: block ID (1=right response rewards most, 3=left response rewards most)
    cho  = data(:,6);                         % response (1= left, 2 = right)
    out  = (data(:,5)-0.5)*-2;                % reward (-1=punishment, 1=reward)
    
    
    % estimate all possible models/parameters
    for km = nmodel
        parameters_rep  = NaN(n_rep,6);
        ll_rep          = NaN(n_rep,1);
        % multiple starting point 
        for k_rep = 1:n_rep
            x0                                                  = [10*rand() 10*rand() rand() rand() 10*rand() 10*rand()]; % parameter initial value
            [parameters_rep(k_rep,1:6),ll_rep(k_rep,1)]         = fmincon(@(x) compute_model_LL(x,con,cho,out,km),x0,[],[],[],[],LB,UB,[],options);
        end
        [~,pos]                 = min(ll_rep);
        
        parameters(nsub,:,km)   = parameters_rep(pos(1),:);
        ll(nsub,km)             = ll_rep(pos(1),:);
    end
end


for n=1:length(nmodel)
    bic(:,n) = -2*-ll(:,n)+nfpm(n)*log(1200); % Bayesian information criterion
end
save('PARAMS2','parameters','ll','bic')

[posteriorBMC,outBMC]=VBA_groupBMC(-bic'./2); % bayesian model comparison
close all force
save('BMC2','outBMC','posteriorBMC')

