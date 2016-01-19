clear all
% [FileName,PathName] = uigetfile('*.txt','Select the MATLAB code file');
% fileID = fopen('HM_ALN_2.txt');
fileID=fopen('HM_11-17-15/HM_ALN_2.txt');%[PathName FileName];
data=textscan(fileID,'%f %f %f','HeaderLines',9)