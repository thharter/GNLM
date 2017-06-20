%% Write results to file
clear
clc
year = 2005;
load(['simulated_Year_' num2str(year)])
fid = fopen(['simulated_Land_' num2str(year) '.dat'],'w');
fprintf(fid,'%10g %10g %10g\n', new_pixels(:,1:3)');
fclose(fid);