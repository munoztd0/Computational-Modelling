function results = wrapper

load ../groupdata

% simulation parameters

nstarts = 100;

data = groupdata.subdata(groupdata.i);

% run optimization
f = @(x,data) MBMF_complexity_exhaustive_llik(x,data);
results = mfit_optimize(f,set_params,data,nstarts);

end