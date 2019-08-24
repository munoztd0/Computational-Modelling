function results = wrapper

load ../groupdata
addpath /home/davidM/Mael/mfit/
% simulation parameters

nstarts = 100;

data = groupdata.subdata(groupdata.i);

% run optimization
f = @(x,data) MBMF_complexity_llik(x,data);
results = mfit_optimize(f,set_params,data,nstarts);
save('results_me', 'ans')
end