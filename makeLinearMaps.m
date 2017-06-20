%% INPUT VARIABLES
%------Name of GNLM results
% The results are written by GNLM using the format xxxxxx_year.mat
% If the data are ina different folder than the one that this script
% resides include either relative or absolute path on the prefix
result_prefix = 'Output_GNLM_run_17_04_';
%------Name for the maps
% use any name. if you want the output to a different folder add the path
% here
output_prefix = 'GNLM_maps_17_04_';

for iyear = 1:length(year_str)
    iyear
    clear temp GNLM_res
    temp = [];
    GNLM_res = load([result_prefix num2str(year_str(iyear))]);
    Nvar_names = fieldnames(GNLM_res);
    for j = 1:length(Nvar_names)
        temp = [temp GNLM_res.(Nvar_names{j,1})];
    end
    
    fid = fopen([output_prefix num2str(year_str(iyear)) '.dat'],'w');
    frmt = '%15.5f';
    first_line = Nvar_names{1,1};
    for j = 1:length(Nvar_names) - 1
        frmt = [frmt ' %15.5f'];
        first_line = [first_line '   ' Nvar_names{j+1,1} ];
    end
    frmt = [frmt '\n'];
    fprintf(fid,'%s\n', first_line);
    fprintf(fid, frmt, temp');
    fclose(fid);
end