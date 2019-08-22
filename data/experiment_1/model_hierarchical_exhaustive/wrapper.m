function results = wrapper

load ../groupdata

data = groupdata.subdata(groupdata.i);

% simulation parameters
nstarts = 5;

% run optimization
f = @(x,data) MBMF_complexity_exhaustive_llik(x,data);
results = mfit_optimize_hierarchical(f,set_params,data,nstarts);

end
