%=========================================================================%
% Figure/analyses of estimated models paramaters
% from Correa CMC, et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% Needs Matlab R2014b or more recent, and matlab's Statistics and Machine Learning toolbox
% Author: Mael Lebreton
% email: mael.lebreton@unige.ch
%=========================================================================%
clc
clear
close all

% load estimated model parameters
load('PARAMS')
mP  = squeeze(parameters(:,:,18));

% specs
subjects    = 1:32;
nsub        = numel(subjects);

% Stats: parameters comparison
B1 = squeeze(mP(:,1));
B2 = squeeze(mP(:,2));
a1 = squeeze(mP(:,3));
a2 = squeeze(mP(:,4));
p1 = squeeze(mP(:,5));
p2 = squeeze(mP(:,6));

PARAMS_MEAN     = mean([B1,B2,a1,a2,p1,p2]);
PARAMS_SEM      = std([B1,B2,a1,a2,p1,p2])./sqrt(32);

[Ha, Pa, CIa, STATSa] = ttest(B1,B2);
[Hb, Pb, CIb, STATSb] = ttest(a1,a2);
[Hc, Pc, CIc, STATSc] = ttest(p1,p2);



%% Figure: parameters comparison
%===================================
%  All subjects
colrand_sub = 0.8 + rand(nsub,3)./5;
MS = 4;

h2 = figure('Units', 'pixels', ...
    'Position', [400 300 800 350]);
set(gcf,'Color',[1,1,1])

LL = {'UM','M'};

x1 = (1:2);

% SUBPLOT 1
subplot(1,3,1)
hold on
mtp1 = squeeze(mean(mP(:,1:2),1));
stp1 = squeeze(std(mP(:,1:2),0,1))./sqrt(32);
hData1 = bar(x1,mtp1);
set(hData1,...
    'FaceColor',.9*[1,1,1],...
    'EdgeColor',[0,0,0],...
    'BarWidth',.8)
for k_sub = subjects    
    plot([1 2]+ .3*(rand(1,2)-.5), mP(k_sub,1:2),'-o',...
        'MarkerSize',MS,...
        'Color',.65*colrand_sub(k_sub,:),...
        'MarkerFaceColor',.8*colrand_sub(k_sub,:),...
        'MarkerEdgeColor',.5*colrand_sub(k_sub,:))
end
errorbar(x1 + [-0.25 0.25],mtp1,stp1,'k','LineStyle','none');
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'YMinorTick'  , 'on'      , ...
    'XColor'      , [.0 .0 .0], ...
    'YLim'        ,[0 6]      ,...
    'XLim'        ,[0.5 2.5]      ,...
    'XTick'       , 1:2       ,...
    'XTickLabel'  , LL        ,...
    'YColor'      , [.0 .0 .0], ...
    'LineWidth'   , .5        , ...
    'FontName'   , 'Arial' );
hYLabel = ylabel('temperature \beta');
set(hYLabel , ...
    'FontName'   , 'Arial'      , ...
    'FontSize'   , 10          );

% SUBPLOT 2
subplot(1,3,2)
hold on
mtp1 = squeeze(mean(mP(:,3:4),1));
stp1 = squeeze(std(mP(:,3:4),0,1))./sqrt(32);
hData1 = bar(x1,mtp1);
set(hData1,...
    'FaceColor',.9*[1,1,1],...
    'EdgeColor',[0,0,0],...
    'BarWidth',.8)
for k_sub = subjects    
    plot([1 2]+ .3*(rand(1,2)-.5), mP(k_sub,3:4),'-o',...
        'MarkerSize',MS,...
        'Color',.65*colrand_sub(k_sub,:),...
        'MarkerFaceColor',.8*colrand_sub(k_sub,:),...
        'MarkerEdgeColor',.5*colrand_sub(k_sub,:))
end
errorbar(x1 + [-0.25 0.25],mtp1,stp1,'k','LineStyle','none');
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'YMinorTick'  , 'on'      , ...
    'XColor'      , [.0 .0 .0], ...
    'YLim'        ,[0 1]      ,...
    'XLim'        ,[0.5 2.5]      ,...
    'XTick'       ,[1 2]      ,...
    'XTickLabel'  ,LL         ,...
    'YColor'      , [.0 .0 .0], ...
    'LineWidth'   , .5        , ...
    'FontName'   , 'Arial' );
hYLabel = ylabel('learning-rate \alpha');
set(hYLabel , ...
    'FontName'   , 'Arial'      , ...
    'FontSize'   , 10          );

% SUBPLOT 3
subplot(1,3,3)
hold on
mtp1 = squeeze(mean(mP(:,5:6),1));
stp1 = squeeze(std(mP(:,5:6),0,1))./sqrt(32);
hData1 = bar(x1,mtp1);
set(hData1,...
    'FaceColor',.9*[1,1,1],...
    'EdgeColor',[0,0,0],...
    'BarWidth',.8)
for k_sub = subjects  
    plot([1 2]+ .3*rand(1,2)-.5, mP(k_sub,5:6),'-o',...
        'MarkerSize',MS,...
        'Color',.65*colrand_sub(k_sub,:),...
        'MarkerFaceColor',.8*colrand_sub(k_sub,:),...
        'MarkerEdgeColor',.5*colrand_sub(k_sub,:))
end
errorbar(x1 + [-0.25 0.25],mtp1,stp1,'k','LineStyle','none');
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'YMinorTick'  , 'on'      , ...
    'XColor'      , [.0 .0 .0], ...
    'YLim'        ,[-2 6]      ,...
    'XLim'        ,[0.5 2.5]      ,...
    'XTick'       ,[1 2]      ,...
    'XTickLabel'  ,LL         ,...
    'YColor'      , [.0 .0 .0], ...
    'LineWidth'   , .5        , ...
    'FontName'   , 'Arial' );
hYLabel = ylabel('perseveration \pi');
set(hYLabel , ...
    'FontName'   , 'Arial'      , ...
    'FontSize'   , 10          );



%% fig 2
figure('Units', 'pixels', ...
    'Position', [400 200 900 300],...
    'Color',[1,1,1]);

for k = 1:3
    subplot(1,3,k)
    hold on
    
    switch k
        case 1
            X = mP(:,1);
            Y = mP(:,2);
            leg_beg = '\beta';
        case 2
            X = mP(:,3);
            Y = mP(:,4);
            leg_beg = '\alpha';
        case 3
            X = mP(:,5);
            Y = mP(:,6);
            leg_beg = '\pi';
    end
    
    [R(k),P(k)]     = corr(X,Y);
    [b,~,stats]     = glmfit(X(:),Y(:),'normal');
    XX              = linspace(min(X(:)),max(X(:)),1000);
    [Yf,Yl,Yh]      = glmval(b,XX,'identity',stats,'confidence',0.95);
    XXX           	= sortrows([XX',Yf,Yf-Yl,Yf+Yh],1);
    
    Xfill = [XXX(:,1);flipud(XXX(:,1))];
    fill(Xfill,[XXX(:,3);flipud(XXX(:,4))],.7*[1,1,1],'EdgeColor','none')
    alpha(0.5)
    
    hModel         =   plot(XXX(:,1),XXX(:,2),'-',...
        'Color',.5*[1,0,0],...
        'LineWidth',2);
    
    plot(X,Y,'o',...
        'MarkerFaceColor',[1,1,1],...
        'MarkerEdgeColor',[0,0,0])
    
    pval = stats.p(2);
    legend(strcat(['p = ',num2str(pval)]))
    
    hYLabel = ylabel(strcat([leg_beg,' Masked']));
    hXLabel = xlabel(strcat([leg_beg,' UnMasked']));
    
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'TickLength'  , [.02 .02] , ...
        'YMinorTick'  , 'on'      , ...
        'XColor'      , [.0 .0 .0], ...
        'YColor'      , [.0 .0 .0], ...
        'LineWidth'   , .5        , ...
        'FontName'   , 'Arial' );
    
    set([hXLabel hYLabel] , ...
        'FontName'   , 'Arial'      , ...
        'FontSize'   , 10          );
end

