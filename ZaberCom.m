function [ commandFormat ] = ZaberCom(name,value)
%ZABERCOM returns value to send to zaber to perform certain command
%   supported commands:
%   home
%   set microstep value
%   move relative
%   store position
%   go to stored position

if strcmp(name,'home')
    commandFormat='/home';
elseif strcmp(name, 'microstepRes')
    commandFormat='/1 37 64'; %set to 64 microsteps
elseif strcmp(name, 'moveRel')
    commandFormat=['/1 21 ',num2str(value)];
elseif strcmp(name, 'storePosition')
    commandFormat=['/1 16 '];
end
    
    
    


