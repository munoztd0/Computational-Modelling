function [param] = set_params

% create parameter structure
g = [4.82 0.88];  % parameters of the gamma prior
param(1).name = 'inverse temperature';
param(1).logpdf = @(x) sum(log(gampdf(x,g(1),g(2))));  % log density function for prior
param(1).lb = 0;   % lower bound
param(1).ub = 20;  % upper bound

param(2).name = 'inverse temperature';
param(2).logpdf = @(x) sum(log(gampdf(x,g(1),g(2))));  % log density function for prior
param(2).lb = 0;   % lower bound
param(2).ub = 20;  % upper bound

param(3).name = 'inverse temperature';
param(3).logpdf = @(x) sum(log(gampdf(x,g(1),g(2))));  % log density function for prior
param(3).lb = 0;   % lower bound
param(3).ub = 20;  % upper bound

param(4).name = 'learning rate';
param(4).logpdf = @(x) 0;
param(4).lb = 0;
param(4).ub = 1;

param(5).name = 'eligibility trace decay';
param(5).logpdf = @(x) 0;
param(5).lb = 0;
param(5).ub = 1;

param(6).name = 'mixing weight low effort';
param(6).logpdf = @(x) 0;
param(6).lb = 0;
param(6).ub = 1;

param(7).name = 'mixing weight high effort 0';
param(7).logpdf = @(x) 0;
param(7).lb = 0;
param(7).ub = 1;

param(8).name = 'mixing weight high effort 1';
param(8).logpdf = @(x) 0;
param(8).lb = 0;
param(8).ub = 1;

end