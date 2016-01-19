% makes plots for hair mechanics from data that was already processed
% Adam Nekimken
% 13 January 2016

close all
clear all
save='No'


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
figure(1)
plot(0:0.001:size(smoothedDeflection,1)/1000-.001, smoothedDeflection*1e6,'k','LineWidth',2)
% [hl1,ax2,ax3] = floatAxisX(0:0.001:size(smoothedDeflection,1)/1000-.001, smoothedDeflection*1e6,'k-','Time (s)');
% [hl2,ax4,ax5] = floatAxisY(0:0.001:size(smoothedDeflection,1)/1000-.001, smoothedDeflection*1e6,'k-','Deflection (um)');
% [hl2,ax2,ax3] = floatAxisX(psal,pres,'r:','Salinity (dotted)',[32 34 0 100]);

xlabel('Time (s)','FontSize',24)
ylabel('Deflection (um)','FontSize',24)
ylimits=ylim;
% xlimits=xlim;
ylim([0 ylimits(2)])
set(gca,'FontSize',24)
set(gca,'Box','off')
MiriamAxes(gca,'xy')



%example of Force v deflection plot with best fit line
figure(2)
plot(deflection*1e6,CantileverForce*1e6,'k','DisplayName','Indentation Data')
ylimits=ylim;
xlimits=xlim;
hold all
% title('Force vs. deflection','FontSize',24)
set(gca,'FontSize',24)

Fdfit=fit(deflection*1e6,CantileverForce*1e6,'poly1');
fitPlot=plot(Fdfit);
set(fitPlot,'LineWidth',2)
xlabel('Hair Deflection (um)')
ylabel('Applied Force (uN)')
ylim(ylimits)
xlim([0 xlimits(2)])
legend off
set(gca,'Box','off')
MiriamAxes(gca,'xy')

%% Stiffness vs. free length plot

%load data
load('HairLengths.mat');
daterTots=dir('*_ProcessedData.mat');
FreeLength=zeros(size(daterTots));
kPoints=cell(size(daterTots));
kAvg=zeros(size(daterTots));
errorBarSize=zeros(size(daterTots));

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
end

%make plot
figure(3)
% errorbar(FreeLength,kAvg,errorBarSize,'kx')
hold on
for i=1:size(daterTots,1)
    plot(FreeLength(i,1), kPoints{i,1},'ko','MarkerSize',6,'LineWidth',.75)
end

ylimits=ylim;
ylim([0 ylimits(2)])
set(gca,'FontSize',24)
xlabel('Free Length of Hair (mm)')
ylabel('Stiffness of Hair (N/m)')
set(gca,'Box','off')
MiriamAxes(gca,'x')


%% Save everything
if strcmp(save,'Yes')
    saveas(figure(1),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/DeflectionTimePlot.pdf')
    saveas(figure(1),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/DeflectionTimePlot.fig')
    saveas(figure(2),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/ForceDistancePlot.pdf')
    saveas(figure(2),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/ForceDistancePlot.fig')
    saveas(figure(3),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/StiffnessVLengthPlot.pdf')
    saveas(figure(3),'/Users/adam/Documents/MATLAB/HairSwipe/Paper/StiffnessVLengthPlot.fig')
end
