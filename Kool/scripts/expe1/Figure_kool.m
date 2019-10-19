%=========================================================================%
% Figure displaying the output of parameter recovery and model
% identifiability simulations
% from Correa CMC, et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% Needs Matlab R2014b or more recent, and matlab's Statistics and Machine Learning toolbox
% Author: Mael Lebreton
% email: mael.lebreton@unige.ch
%=========================================================================%
clear
close all
clc

dbstop if error

cd ~/Project/Kool/scripts/expe1

% load simulation data
load('SIMU_RECOVERY_Kool_testW.mat')

%% declare variables
n_sub = 4;  %# number of subjects
n_fl    = 4; %# number of iteration
n_mod   = 2; %# number of models
n_par = 3; %# number of parameters
n_cor = 3; %item for corr

% pre allocate
bm      = zeros(n_mod,n_mod,n_fl);  % best model
ep      = zeros(n_mod,n_mod,n_fl);  % exceedance probability
pn_modest  = NaN(n_sub,n_par,n_fl);
pn_modsims = NaN(n_sub,n_par,n_fl);
Rest    = NaN(n_par,n_par,n_fl);
R2est   = NaN(n_par,n_par,n_fl);

LAB = {'\omega_1_M','\omega_2_M','\omega_3_M'}; %};


for k_fl = 1:n_fl
    
    % get model comparison result for each model simulation (/confussion
    % matrices)
    for k_sim = 1:n_mod       
        bmc_res                 = SimRun(k_fl).BMC_output(k_sim);
        ep(k_sim,:,k_fl)        = 100*bmc_res.out.ep;    
        [~,ln_max]              = max(bmc_res.out.ep);
        bm(k_sim,ln_max,k_fl)   = 1;
    end
    
    % get parameters from most complex model for recovery analysis
    pn_modest(:,:,k_fl)    = SimRun(k_fl).recov_param(n_cor).val(:,n_cor,:); % 
    pn_modsims(:,:,k_fl)   = squeeze(SimRun(k_fl).simu_param(:,n_cor,:));   % sims params
    
    % compute correlations between parameters used to simulate the data,
    % and recovered (i.e. estimated) parameters
    Rest(:,:,k_fl) = corr(squeeze(pn_modest(:,:,k_fl)));
    for k_par = 1:n_par
        Rest(k_par,k_par,k_fl) = corr(squeeze(pn_modest(:,k_par,k_fl)),squeeze(pn_modsims(:,k_par,k_fl)));
    end
    R2est(:,:,k_fl) = Rest(:,:,k_fl).*Rest(:,:,k_fl);
    
end

% compute confusion matrices
mean_ep     = squeeze(mean(ep,3));
n_goodcl    = squeeze(sum(bm,3));

%% Fig 1
h1 = figure('Units', 'pixels', ...
    'Position', [400 200 1000 350]);
set(h1,'Color',[1,1,1])

for k = 1:2
    subplot(1,2,k)
    
    switch k
        case 1
            mtp = mean_ep;
            lbl = 'Exceedance probability (%)';
        case 2
            mtp = n_goodcl;
            lbl = '% Best model';
    end
    
    colormap(flipud(gray))
    imagesc(flipud(mtp))
    ylabel('simulated model #')
    xlabel('estimated model #')
    set(gca,'XTick',1:n_mod,...
        'YTick',1:n_mod,...
        'XTickLabel',(1:n_mod),...
        'YTickLabel',fliplr(1:n_mod))
    
    c = colorbar;
    c.Label.String = lbl;
    
end


%% Fig 2
h2 = figure('Units', 'pixels', ...
    'Position', [400 150 600 600]);
set(h2,'Color',[1,1,1])


for k = 1:n_par
    
    subplot(4,2,k)
    hold on
    
%         B1  = random('Gamma',4,.5,n,1);
%         B2  = random('Gamma',4,.5,n,1);
%         B3  = random('Gamma',4,.5,n,1);
%         
%         LR = random('Beta',5,1.5,n,1);
%         
%         LAMBDA  = random('Uniform',0,1,n,1);
%         
%         W1  = random('Uniform',0,1,n,1);
%         W2  = random('Uniform',0,1,n,1);
%         W3  = random('Uniform',0,1,n,1);

    switch k
        case 1
            x = 0:0.01:1;
            distr_tp = unifpdf(x,0,1);
            xl = [0 1];
        case 2
            x = 0:0.01:1;
            distr_tp = unifpdf(x,0,1);
            xl = [0 1];
        case 3
            x = 0:0.01:1;
            distr_tp = unifpdf(x,0,1);
            xl = [0 1];
    end
    
    ax1 = gca; % current axes
    
    plot(ax1,x,distr_tp,'Color',.5*[1,1,1])
    set(ax1,'XLim',xl,...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'XTickLabel',[],...
        'YTickLabel',[])
    ax1_pos = ax1.Position;
    ax2 = axes('Position',ax1_pos,...
        'YLim',xl,...
        'XAxisLocation','bottom',...
        'YAxisLocation','left',...
        'Color','none',...
        'XLim',xl);
    xlabel(strcat(['Simulated ',LAB{k}]));
    ylabel(strcat(['Estimated ',LAB{k}]));
    
    hold on
    
    
    X = squeeze(pn_modsims(:,k,:));
    Y = squeeze(pn_modest(:,k,:));
    
    plot(ax2,xl,xl,':k',...
        'LineWidth',2)
    plot(ax2,X(:),Y(:),'o',...
        'MarkerFaceColor',[1,1,1],...
        'MarkerEdgeColor',[0,0,0])
    
    [b,~,stats]    = glmfit(X(:),Y(:),'normal');
    STORE_REG(k).b = b;
    STORE_REG(k).stats = stats;
    
    XX             = linspace(min(X(:)),max(X(:)),1000);
    [Yf,Yl,Yh]      = glmval(b,XX,'identity',stats,'confidence',0.95);
    XXX            = sortrows([XX',Yf,Yf-Yl,Yf+Yh],1);
    
    Xfill = [XXX(:,1);flipud(XXX(:,1))];
    fill(Xfill,[XXX(:,3);flipud(XXX(:,4))],.7*[1,1,1],'EdgeColor','none',...
        'Parent', ax2)
    alpha(0.5)
    hModel         =   plot(ax2,XXX(:,1),XXX(:,2),'-',...
        'Color',.5*[1,0,0],...
        'LineWidth',2);
    
    
    set(ax2,'Position',ax1_pos)
    
end


%% Fig 3
figure('Units', 'pixels', ...
    'Position', [400 200 200 350],...
    'Color',[1,1,1]);

mtp = NaN(2,n_par);
stp = NaN(2,n_par);
for k = 1:n_par
    
    
    mtp = STORE_REG(k).stats.beta;
    stp = STORE_REG(k).stats.se;
    subplot(4,2,k)
    hold on
    bar(mtp,'FaceColor',.9.*[1,1,1])
    errorbar(mtp,stp,'k','LineStyle','none')
    set(gca,'YLim',[-0.5 1.5],...
        'XLim',[0 3],...
        'XTick',[1 2],...
        'XTickLabel',{'\beta_0','\beta_1'})
    ylabel(LAB{k});
    
end





%% Fig 4
for k = 1:2
    
    figure('Units', 'pixels', ...
        'Position', [400 200 450 350]);
    set(gcf,'Color',[1,1,1])
    switch k
        case 1
            
            colormap(parula)           
            mat_tp = squeeze(mean(Rest,3));
            lbl = 'Pearson Correlation (R)';
            cax = [-1 1];
            rmat_avg = mat_tp;
        case 2
            colormap(flipud(gray))
            mat_tp = squeeze(mean(R2est,3));
            lbl = 'Pearson Correlation (R^2)';
            cax = [0 1];
            r2mat_avg = mat_tp;
    end
    
    
    imagesc(flipud(mat_tp))
    ylabel('parameter #')
    xlabel('parameter #')
    set(gca,'YTick',[1:n_par],...
        'XTick',[1:n_par],...
        'XTickLabel',LAB,...
        'YTickLabel',fliplr(LAB))
        
    c = colorbar;
    c.Label.String = lbl;
    caxis(cax)
end

rDiag = eye(n_par).*rmat_avg;
rDiag(rDiag==0) = NaN;
nanmean(rDiag(:))

rNdiag = (ones(n_par)-eye(n_par)).*rmat_avg;
rNdiag(rNdiag==0) = NaN;
nanmean(rNdiag(:))

r2Diag = eye(n_par).*r2mat_avg;
r2Diag(r2Diag==0) = NaN;
nanmean(r2Diag(:))

r2Ndiag = (ones(n_par)-eye(n_par)).*r2mat_avg;
r2Ndiag(r2Ndiag==0) = NaN;
nanmean(r2Ndiag(:))

for k = 1:n_mod
    for i = 1:n_fl
        for j = 1:n_mod
            mean_it(i,j) =  mean(SimRun(i).rewardrate(j).val);
        end
    end
    reward_rate(k) = mean(mean_it(:,k));
end    

reward_rate