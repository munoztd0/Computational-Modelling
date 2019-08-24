%=========================================================================%
% Figure/analyses predicting performance with model parameters
% from Correa CMC, et al. (2018) J.Neuro (https://doi.org/10.1523/JNEUROSCI.0457-18.2018)
% Needs Matlab R2014b or more recent, and matlab's Statistics and Machine Learning toolbox
% Author: Mael Lebreton
% email: mael.lebreton@unige.ch
%=========================================================================%

clc
clear
close all

% load data 
load('SUB_DATA')

% load estimated model parameters
load('PARAMS')
mP = squeeze(parameters(:,:,18));

% Specs
subjects    = 1:32;
nmodel      = 18;
nsub        = numel(subjects);
perf        = NaN(nsub,1);

% subject loop
for ksub=1:32
    
    data        = SubData(ksub).data;
    cor         = data(:,3)==3;                      % 3: block ID (1=right response rewards most, 3=left response rewards most)
    cho         = data(:,6)==1;                      % response (1= left, 2 = right)
    perf(ksub)  = mean(cho==cor);
    
end

[b,dev,stats] = glmfit(mP,perf);

%% fig 1
figure;
set(gcf,'Color',[1,1,1])
hold on

mtp = squeeze(stats.beta(2:end));
stp = squeeze(stats.se(2:end));

[p05] = find(stats.p(2:end)<.05 & stats.p(2:end)>.01);
[p01] = find(stats.p(2:end)<.01 & stats.p(2:end)>.001);
[p001] = find(stats.p(2:end)<.001);
if exist('p05','var'); text(p05-.05,mtp(p05)+2*stp(p05),'*','FontSize',14);end
if exist('p01','var'); text(p01-.10,mtp(p01)+2*stp(p01),'**','FontSize',14);end
if exist('p001','var'); text(p001,mtp(p001)+2*stp(p001),'*','FontSize',14);end

hData1 = bar(1:6,mtp);
hYLabel = ylabel('Regression coefficient');
set(hData1,...
    'FaceColor',.9*[1,1,1],...
    'EdgeColor',[0,0,0],...
    'BarWidth',.8)
errorbar(1:6,mtp,stp,'k','LineStyle','none');

LL = {'\beta_U_M','\beta_M','\alpha_U_M','\alpha_M','\pi_U_M','\pi_M'};
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'YMinorTick'  , 'on'      , ...
    'XColor'      , [.0 .0 .0], ...
    'XLim'        ,[0 7]      ,...
    'XTick'       , 1:6       ,...
    'XTickLabel'  , LL        ,...
    'YColor'      , [.0 .0 .0], ...
    'LineWidth'   , .5        , ...
    'FontName'   , 'Arial' );
set(hYLabel , ...
    'FontName'   , 'Arial'      , ...
    'FontSize'   , 10          );

%% fig 2
figure;
set(gcf,'Color',[1,1,1])

for k = 1:6
    subplot(3,2,k)
    hold on
    
    X = mP(:,k);
    Y = perf;
    
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
    beta= stats.beta(2);
    legend(strcat(['p = ',num2str(pval)]),...
                  strcat(['beta = ',num2str(beta)]))        
    hYLabel = ylabel('Performance (% correct)');
    hXLabel = xlabel(LL{k});
    
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




