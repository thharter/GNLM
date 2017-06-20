%% Read model.in file
fid = fopen('B:\WorkSpace\GNLM\model_in_1\model_input.asc','r');
temp = fgetl(fid);
model_input = cell2mat(textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n',21156335));
fclose(fid);
save('model_input.mat','model_input','-v7.3');
%% Read DAIRIES 
