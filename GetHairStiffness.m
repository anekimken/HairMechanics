% Get Hair Stiffness
clear all
close all

[FileName,PathName] = uigetfile('*.txt','Select the data file');
% FileName='ALN_Bend1.txt';
% PathName='/Users/adam/Documents/MATLAB/HairSwipe/HairMechanics/HM_12-3-15/';
fileID=fopen([PathName FileName]);
data=textscan(fileID,'%f %f %f','HeaderLines',9);

% [sensitivity]=SensitivityCalc('AN-HS9A',965,10.05,.0589); % in um/V
sensitivity=28.0^-1/5000;

figure(1)
plot(data{1}./1e6,'DisplayName','Setpoint (m)')
hold all
plot(data{2}./1e6,'DisplayName','Position (m)')
plot(data{3}.*sensitivity,'DisplayName','Cantilever Deflection (m)')

CantileverStiffness=.35;

CantileverForce=data{3}.*sensitivity*CantileverStiffness;

deflection=data{2}./1e6-data{3}.*sensitivity; % in m  % note: if deflection of cantilever leads to positive signal, subtract here (and vice versa)
plot(deflection,'DisplayName','Hair Deflection (m)')
smoothedDeflection=smooth(deflection,21);


% input where linear deflections are happening
figure(2)
plot(smoothedDeflection)
hold all
set(gca,'FontSize',24)
% pause
settingBreaks=1;
while settingBreaks
    [breaks,~]=ginput();
    breaks=round(breaks);
    plot(breaks,smoothedDeflection(breaks),'Marker','o','LineStyle','none')
    settingBreaks=input('Try again? ');
end

fits=cell(size(breaks,1)/2,2);
for i=1:size(breaks,1)/2
    time=(breaks(2*i-1):breaks(2*i)).'; %in s
    fits{i,1}=fit(time,deflection(breaks(2*i-1):breaks(2*i)),'poly1'); % deflection fit
    fits{i,2}=fit(time,CantileverForce(breaks(2*i-1):breaks(2*i)),'poly1'); % force fit
    plot(fits{i,1})
end
ylim([0-max(deflection*0.2) max(deflection*1.2) ])
legend('hide')

stiffness=zeros(size(fits,1),1);
stiffness2=zeros(size(fits,1),1);
for i=1:size(fits,1)
    stiffness(i)=abs(fits{i,2}.p1/fits{i,1}.p1);
%     stiffness2(i)=abs(mean((CantileverForce(breaks(2*i-1):breaks(2*i)))./(smoothedDeflection(breaks(2*i-1):breaks(2*i)))));
end

result1=mean(stiffness) %#ok<NOPTS>
sem1=std(stiffness)/sqrt(size(stiffness,1)) %#ok<NOPTS>
% result2=mean(stiffness2)



figure
plot(deflection*1e6,CantileverForce*1e6,'k','DisplayName','Indentation Data')
ylimits=ylim;
xlimits=xlim;
hold all
% title('Force vs. deflection','FontSize',24)
set(gca,'FontSize',24)

Fdfit=fit(deflection*1e6,CantileverForce*1e6,'poly1') %#ok<NOPTS>
fitPlot=plot(Fdfit);
set(fitPlot,'LineWidth',2)
xlabel('Hair Deflection (um)')
ylabel('Applied Force (uN)')
ylim(ylimits)
xlim(xlimits)
legend off

saveName=[FileName(1:end-4) '_ProcessedData.mat'];
% save(saveName,'stiffness','result1','sem1','data','sensitivity','CantileverStiffness')

