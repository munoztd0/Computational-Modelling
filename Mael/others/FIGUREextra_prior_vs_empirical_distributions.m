
%=========================================================================%
% Figure showing the correspondance between parameter prior ditributions
% and parameter empirical distributions
% from Correa CMC, et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% Needs Matlab R2014b or more recent, and matlab's Statistics and Machine Learning toolbox
% Author: Mael Lebreton
% email: mael.lebreton@unige.ch
%=========================================================================%

clc
clear
close all


% get empirical distributions
load('PARAMS')
estim_params = squeeze(parameters(:,:,18));

% get prior distributions
b = 0:0.1:10;
beta1_distrCH = gampdf(b,4,.5);
beta2_distrCH = gampdf(b,1.5,1);
a = 0:0.01:1;
alpha1_distrCH = betapdf(a,5,1.5);
alpha2_distrCH = betapdf(a,1.5,5);
p = -2:0.1:6;
pi1_distrCH = normpdf(p,.7,.8);
pi2_distrCH = normpdf(p,1.7,1.2);

% Plot
LL = {'\beta_U_M','\beta_M','\alpha_U_M','\alpha_M','\pi_U_M','\pi_M'};

figure('Units', 'pixels', ...
    'Position', [400 100 800 900],...
    'Color',[1,1,1])

n = 10000;
for k = 1:6
    
    subplot(3,2,k)
    hold on
    
    switch k
        case 1
            dist_tp = beta1_distrCH./4;
            rand_tp = random('Gamma',4,.5,n,1);
            x = b;
            xbin = 0:0.25:5;
            XL = [0 5];
        case 2
            dist_tp = beta2_distrCH./4;
            rand_tp = random('Gamma',1.5,1,n,1);
            x = b;
            xbin = 0:0.25:5;
            XL = [0 5];
        case 3
            dist_tp = alpha1_distrCH./20;
            rand_tp = random('Beta',5,1.5,n,1);
            x = a;
            xbin = 0:0.05:1;
            XL = [0 1];
        case 4
            dist_tp = alpha2_distrCH./20;
            rand_tp = random('Beta',1.5,5,n,1);
            x = a;
            xbin = 0:0.05:1;
            XL = [0 1];
        case 5
            dist_tp = pi1_distrCH./4;
            rand_tp = random('Normal',.7,.8,n,1);
            x = p;
            xbin = -2:.25:6;
            XL = [-2 6];
        case 6
            dist_tp = pi2_distrCH./4;
            rand_tp = random('Normal',1.7,1.2,n,1);
            x = p;
            xbin = -2:.25:6;
            XL = [-2 6];
    end
    
    hc2 = histc(rand_tp,xbin)./n;
    bar(xbin,hc2,...
        'FaceColor',.90*[1,1,1],...
        'EdgeColor','none')
    
    hc = histc(estim_params(:,k),xbin)./32;
    bar(xbin,hc,...
        'FaceColor','none',...
        'LineWidth',1)
    plot(x,dist_tp,'-r')
    
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'TickLength'  , [.02 .02] , ...
        'YMinorTick'  , 'on'      , ...
        'XColor'      , [.0 .0 .0], ...
        'XLim'        ,XL      ,...
        'YColor'      , [.0 .0 .0], ...
        'LineWidth'   , .5        , ...
        'FontName'   , 'Arial' );
    
    hYLabel = ylabel('Frequency');
    hXLabel = xlabel(strcat(['Parameter (',LL{k},') value']));
    
    set([hXLabel,hYLabel] , ...
        'FontName'   , 'Arial'    , ...
        'FontSize'   , 10          );
    
end
