function varargout = HairMechGUI(varargin)
% HAIRMECHGUI MATLAB code for HairMechGUI.fig
%      HAIRMECHGUI, by itself, creates a new HAIRMECHGUI or raises the existing
%      singleton*.
%
%      H = HAIRMECHGUI returns the handle to a new HAIRMECHGUI or the handle to
%      the existing singleton*.
%
%      HAIRMECHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HAIRMECHGUI.M with the given input arguments.
%
%      HAIRMECHGUI('Property','Value',...) creates a new HAIRMECHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HairMechGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HairMechGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HairMechGUI

% Last Modified by GUIDE v2.5 29-Oct-2015 13:52:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @HairMechGUI_OpeningFcn, ...
    'gui_OutputFcn',  @HairMechGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before HairMechGUI is made visible.
function HairMechGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HairMechGUI (see VARARGIN)

% Choose default command line output for HairMechGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HairMechGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = HairMechGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in ZaberInit.
function ZaberInit_Callback(hObject, eventdata, handles)
% hObject    handle to ZaberInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% open serial port
zaber=serial('COM5');
set(hObject,'UserData',zaber);
fopen(zaber);

% make sure numbering is what we think it is
numberResp=ZaberCom(zaber,'renumber',0);

% set microstep value so we know what it is
microstepResp=ZaberCom(zaber,'microstepRes',64);

% send actuator to home position
homeResp=ZaberCom(zaber,'home',0);

% update status and next button
if numberResp.command==2 && microstepResp.command==37 && homeResp.command==1
    % init was good if we got here
    set(handles.ZaberInitStatus,'String','Init Done')
    set(handles.LabJackInit,'Enable','on')
    set(handles.ZaberInit,'Enable','off')
end

% Update handles structure
guidata(gcf, handles);  

end

% --- Executes on button press in LabJackInit.
function LabJackInit_Callback(hObject, eventdata, handles)
% hObject    handle to LabJackInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% initialize LabJack
[ljudObj,ljhandle,chanType] = LabJackInit_PC(100,1);
% data = NET.createArray('System.Double', 100);  %Max buffer size (#channels*numScansRequested) for reading both channels
data=zeros(100,1);

% TimeToStream=0.1;
% DataRate=100;
[RecordedData,index] = grabData(ljudObj,ljhandle,data);
disp(RecordedData(1:index-1))
set(handles.CantileverSignal,'String',['Cantilever Signal: ',num2str(mean(RecordedData))])

% update status and next button
set(handles.LabJackInitStatus,'String','Init Done')
set(handles.Approach,'Enable','on')
set(handles.LabJackInit,'Enable','off')

end

% --- Executes on button press in Approach.
function Approach_Callback(hObject, eventdata, handles)
% hObject    handle to Approach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ApproachStatus,'String','Approaching...')

% while cantilever displacement is around zero
% step down Zaber

% move up a little bit
% store final position

% update status and next button
set(handles.ApproachStatus,'String','Approach Complete')
set(handles.StartExperiment,'Enable','on')

end

% --- Executes on button press in StartExperiment.
function StartExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to StartExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ExperimentStatus,'String','Running Experiment...')

% for number of steps in experiment
% move down a little bit
% measure cantilever signal for a while

% update status
set(handles.ExperimentStatus,'String','Experiment Complete!')

end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% close serial port
% get(handles.ZaberInit,'UserData')
zaber=get(handles.ZaberInit,'UserData');
fclose(zaber)
delete(zaber)

% stop LabJack

% Hint: delete(hObject) closes the figure
delete(hObject);
end
