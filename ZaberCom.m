function [ response ] = ZaberCom(serialObject,CommandName,value)
%ZABERCOM returns value to send to zaber to perform certain command
%   supported commands:
%   home
%   set microstep value
%   move relative
%   store position
%   go to stored position
%   renumber actuators

if strcmp(CommandName,'renumber')
    commandSequence=[0 2 0 0 0 0];
elseif strcmp(CommandName,'home')
    commandSequence=[1 1 0 0 0 0];
elseif strcmp(CommandName, 'microstepRes')
    commandSequence=[1 37 64 0 0 0]; %set to 64 microsteps
elseif strcmp(CommandName, 'moveRel')
    byte6 = value / 256^3;
    value   = value - 256^3 * Cmd_Byte_6;
    byte5 = value / 256^2;
    value   = value - 256^2 * Cmd_Byte_5;
    byte4 = value / 256;
    value   = value - 256   * Cmd_Byte_4;
    byte3 = value;
    commandSequence=[1 21 byte3 byte4 byte5 byte6];
elseif strcmp(CommandName, 'storePosition')
    commandSequence=[1 16 1 0 0 0];
else
    disp('Try a new command!')
end

fwrite(serialObject,commandSequence)
    
while serialObject.BytesAvailable < 6
    pause(0.01)
end

serialResponse=fread(serialObject,6);

response.address=serialResponse(1);
response.command=serialResponse(2);
response.value = 256^3 * serialResponse(6) + 256^2 * serialResponse(5) + 256 * serialResponse(4) + serialResponse(3);
if serialResponse(6) > 127 
    response.value = response.value - 256^4;
end

end
    
    
    


