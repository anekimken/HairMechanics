% makes plots for hair mechanics from data that was already processed
% Adam Nekimken
% 13 January 2016

close all
clear all
save='Yes' %#ok<NOPTS>

plotSize=[0.35 0.25 2.85 3.5/1.6-.5];
plotPos=[0 2 3.5 3.5/1.6];

% load one file for example plots
FileName='ALN_Bend1.txt';
PathName='/Users/adam/Documents/MATLAB/HairSwipe/HairMechanics/HM_12-3-15/';
fileID=fopen([PathName FileName]);
data=textscan(fileID,'%f %f %f','HeaderLines',9);

[sensitivity]=SensitivityCalc('AN-HS9A',965,10.05,.0589); % in um/V

CantileverStiffness=1.003;

CantileverForce=data{3}.*sensitivity*CantileverStiffness;

deflection=data{2}./1e6-data{3}.*sensitivity; % in m  % note: if deflection of cantilever leads to positive signal, subtract here (and vice versa)
smoothedDeflection=smooth(deflection,21);

% example of deformation profile
figure('Units','inches',...
'Position',plotPos,...
'PaperPositionMode','auto',...
'PaperSize',[3.5 3.5/1.6])


plot(0:0.001:size(smoothedDeflection,1)/1000-.001, smoothedDeflection*1e6,'k','LineWidth',1)

% xlabel('Time (s)','FontSize',12)
% ylabel('Deflection ({\mu}m)','FontSize',12,'Interpreter','latex')
ylimits=ylim;
% xlimits=xlim;
ylim([0 ylimits(2)])
set(gca,'FontSize',12)
set(gca,'Box','off','Units','inches',...
'ActivePositionProperty','Position',...
'Position',plotSize)
[newX,newY]=MiriamAxes(gca,'xy');
set(get(newX,'XLabel'),'Visible','off')
set(get(newY,'YLabel'),'Visible','off')
% print(gcf,'-depsc','test.eps')



%example of Force v deflection plot with best fit line
figure('Units','inches',...
'ActivePositionProperty','Position',...
'Position',plotPos,...
'PaperPositionMode','auto',...
'PaperSize',[3.5 3.5/1.6])
plot(deflection*1e6,CantileverForce*1e6,'k','DisplayName','Indentation Data','LineWidth',0.5)
ylimits=ylim;
xlimits=[0 60];
hold all
% title('Force vs. deflection','FontSize',24)
set(gca,'FontSize',12)

Fdfit=fit(deflection*1e6,CantileverForce*1e6,'poly1');
fitPlot=plot(Fdfit);
set(fitPlot,'LineWidth',1)
% xlabel('Hair Deflection ($\mu$m)','Interpreter','latex','FontName','Helvetica')
% ylabel('Applied Force ($\mu$N)','Interpreter','latex')
ylim(ylimits)
xlim([0 xlimits(2)])
legend off
set(gca,'Box','off','Units','inches',...
'ActivePositionProperty','Position',...
'Position',plotSize)
[newX,newY]=MiriamAxes(gca,'xy');
set(get(newX,'XLabel'),'Visible','off')
% set(newX,'Position',[0.18    0.11    0.775    0.0000000001]) % need to set same axes positions for all axes on all figures
set(get(newY,'YLabel'),'Visible','off')
% print(gcf,'-depsc','test2.eps')

%% Stiffness vs. free length plot

%load data
load('HairLengths.mat');
daterTots=dir('*_ProcessedData.mat');
FreeLength=zeros(size(daterTots));
kPoints=cell(size(daterTots));
kAvg=zeros(size(daterTots));
errorBarSize=zeros(size(daterTots));
fitData=zeros(size(daterTots));
index=1;


for i=1:size(daterTots,1)
    load(daterTots(i).name);
    for j=1:size(HairLengths,1)
        if strcmp(daterTots(i).name,HairLengths{j,1})
            FreeLength(i)=HairLengths{j,2};
        end
    end
    kPoints{i}=stiffness;
    kAvg(i)=mean(kPoints{i});
    errorBarSize(i)=std(kPoints{i})/sqrt(size(kPoints{i},1));
    for k=1:size(kPoints{i},1)
        fitData(index,1)=FreeLength(i);
        fitData(index,2)=kPoints{i}(k);
        index=index+1;
    end
end
inverseCubic=fittype('a/(x)^3');
options=fitoptions('Method','NonLinearLeastSquares');
Lkfit=fit(fitData(:,1),fitData(:,2),inverseCubic,options);

%make plot
figure('Units','inches',...
'Position',plotPos,...
'PaperPositionMode','auto',...
'PaperSize',[3.5 3.5/1.6])
% errorbar(FreeLength,kAvg,errorBarSize,'kx')
hold on
for i=1:size(daterTots,1)
    plot(FreeLength(i,1), kPoints{i,1},'ko','MarkerSize',5,'LineWidth',.75)
end

fitPlot=plot(Lkfit);
legend off
set(fitPlot,'LineWidth',2)

ylimits=ylim;
ylim('auto')%[0 ylimits(2)])
xlimits=xlim;
xlim([4 xlimits(2)])
set(gca,'FontSize',12)
% xlabel('Free Length of Hair (mm)')
% ylabel('Stiffness of Hair (N/m)')
set(gca,'Box','off','Units','inches',...
'ActivePositionProperty','Position',...
'Position',plotSize)
[newX,newY]=MiriamAxes(gca,'xy');
set(get(newX,'XLabel'),'Visible','off')
set(get(newY,'YLabel'),'Visible','off')

%% Save everything
if strcmp(save,'Yes')
    saveas(figure(1),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/DeflectionTimePlot','pdf')
    saveas(figure(1),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/DeflectionTimePlot.fig')
    saveas(figure(2),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/ForceDistancePlot','pdf')
    saveas(figure(2),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/ForceDistancePlot.fig')
    saveas(figure(3),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/StiffnessVLengthPlot','pdf')
    saveas(figure(3),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/StiffnessVLengthPlot.fig')
end
