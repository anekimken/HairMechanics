z=serial('COM5');
fopen(z);
fwrite(z,[0 1 0 0 0 0]);
while z.BytesAvailable>6
    pause(0.01)
end
resp=fread(z);

fclose(z);