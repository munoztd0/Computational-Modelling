function results = wrapper

load ~/Project/Kool/data/experiment_1/groupdata
addpath ~/Project/mfit/
% simulation parameters

nstarts = 100;

data = groupdata.subdata(groupdata.i);

% run optimization
f = @(x,data) MBMF_complexity_llik(x,data);
results = mfit_optimize(f,set_params,data,nstarts);

save('results_2', 'ans')
end