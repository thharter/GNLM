%% Read model.in file
fid = fopen('model_input.asc','r');
temp = fgetl(fid);
model_input = cell2mat(textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n',21155564));
fclose(fid);
save('model_input_pre_LandSim_2017.mat','model_input','-v7.3');
%% Read DAIRIES 
