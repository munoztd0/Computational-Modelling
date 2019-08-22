function results = wrapper

load ../groupdata

hi = groupdata.hi_acc_nofirsttimeout_firstchoice==1;
lo = groupdata.lo_acc_nofirsttimeout==1;

%% uncomment the line for the group you want to estimate
data = groupdata.subdata(groupdata.i);                    % all subjects
% data = groupdata.subdata(groupdata.i(hi));              % subjects with 100% accuracy on high-effort probes
% data = groupdata.subdata(groupdata.i(lo));              % subjects with 100% accuracy on low-effort probes
% data = groupdata.subdata(groupdata.i(hi&lo));           % subjects with 100% accuracy on all probes

%% model fitting
% simulation parameters
nstarts = 5;

% run optimization
f = @(x,data) MBMF_complexity_probes_llik(x,data);
results = mfit_optimize_hierarchical(f,set_params,data,nstarts);

end
