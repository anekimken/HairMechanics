function [RecordedData,index] = grabData(lj,numPoints)
try
    ljudObj=lj.ljudObj;
    ljhandle=lj.ljhandle;
    chanType=lj.chanType;
%     ljasm=LabJack.ljasm;
    
    DataStruct = NET.createArray('System.Double', 100);  %Max buffer size (#channels*numScansRequested) for reading both channels
    RecordedData=zeros(numPoints,1);
    scansRequested = 10; %read data at 10 Hz
    
    
    %Start the stream.
    chanObj = System.Enum.ToObject(chanType, 1); %channel = 0
    [ljerror, ~] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.START_STREAM, chanObj, 0, 0);
    
%     RecordedData=zeros(10,1);
    index=1;
    tic
    while index<numPoints
        [ljerror, PacketLength] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_STREAM_DATA, LabJack.LabJackUD.CHANNEL.ALL_CHANNELS, scansRequested, DataStruct);
        for  j= 1:PacketLength
            RecordedData(index+j-1)=DataStruct(j);
%             disp(PacketLength)
        end
        index=index+PacketLength;
    end
    
    % stop streaming
    chanObj = System.Enum.ToObject(chanType, 0); %channel = 0
    ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.STOP_STREAM, chanObj, 0, 0);
catch err
    
        if strncmp(char(err.ExceptionObject.ToString()),'Stream scans overlapped',10)
            disp('Try a slower sampling rate or lower resolution. See https://labjack.com/support/datasheets/u6/operation/stream-mode for details.')
        else
%             disp(ljerror)
        end
        closepreview
%     Stop the stream to avoid memory leak
        chanObj = System.Enum.ToObject(chanType, 0); %channel = 0
%         ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.STOP_STREAM, chanObj, 0, 0);
    
    rethrow(err)
end