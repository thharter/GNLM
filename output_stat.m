% This script generates the stats for the entire region
%% User Input
% 
output_stat_common_input_data;

%debug index
idbg = 0; %set 0 to skip debugin
%% Main loop
for iyear = 1:length(year_str)
    display(num2str(year_str(iyear)));
    GNLM_res = load([path_of_tempfiles prefix_name num2str(year_str(iyear))]);
    Nvar_names = fieldnames(GNLM_res);
    Nvar_names = Nvar_names(dd);
    
    %-------------------------------------
    %stats per subbasin
    %-------------------------------------
    display('SubBasins');
    if idbg == 0 || idbg == 1
        for isub = 1:length(subbasin_list)
            GNLM_stats.Basins.name{isub,1} = GW_Basin_name{GW_Basin_ID(:,1) == subbasin_list(isub)};
            %find the pixels of subbasin isub
            pixel_id = find(Subbasins == subbasin_list(isub));

            for j = 1:length(Nvar_names)
                pixel_id_non_zeros = pixel_id(GNLM_res.(Nvar_names{j})(pixel_id,1) ~=0);
                GNLM_stats.Basins.data{iyear,1}.(Nvar_names{j})(isub,:) = [...
                    length(pixel_id)/4 ...
                    length(pixel_id_non_zeros)/4 ...
                    0.25 * sum(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                    mean(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                    mean(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1)) ...
                    std(GNLM_res.(Nvar_names{j})(pixel_id,1))...
                    std(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1))...
                    prctile(GNLM_res.(Nvar_names{j})(pixel_id,1), [0 10 25 50 75 90 95 99 99.9 100])];
            end
        
        %{
        %NgwDirect Statistics
        for ingw = 1:size(ngw_group_stat,1)
            pixel_id_ngw = find(model_input(:,end) == subbasin_list(isub) ...
                & model_input(:,min(iyear,5)+4) >= ngw_group_stat(ingw,1) ...
                & model_input(:,min(iyear,5)+4) <= ngw_group_stat(ingw,2));
            
            pixel_id_ngw_non_zeros = pixel_id_ngw(GNLM_res.(Nvar_names{4})(pixel_id_ngw,1) ~=0);
            GNLM_stats.Basins.data{iyear,1}.([Nvar_names{4} '_' ngw_group_name{ingw}])(isub,:) = [...
                length(pixel_id_ngw)/4 ...
                length(pixel_id_ngw_non_zeros)/4 ...
                0.25 * sum(GNLM_res.(Nvar_names{4})(pixel_id_ngw,1)) ...
                mean(GNLM_res.(Nvar_names{j})(pixel_id_ngw,1)) ...
                mean(GNLM_res.(Nvar_names{4})(pixel_id_ngw_non_zeros,1)) ...
                std(GNLM_res.(Nvar_names{4})(pixel_id_ngw,1))...
                std(GNLM_res.(Nvar_names{4})(pixel_id_ngw_non_zeros,1))...
                prctile(GNLM_res.(Nvar_names{4})(pixel_id_ngw,1), [0 10 25 50 75 90 95 99 99.9 100])];
        end
        %}
        end
    end
    
    
    %-------------------------------------
    %stats per county
    %-------------------------------------
    display('County');
    if idbg == 0 || idbg == 2
        for icnty = 1:length(county_list)
            temp = find(county_name_ids == county_list(icnty));
            if isnan(county_name_list{temp,1})
                GNLM_stats.Counties.name{icnty,1} = ['County_' num2str(county_name_ids(temp))];
            else
                GNLM_stats.Counties.name{icnty,1} = county_name_list{temp,1};
            end

            %find the pixels of the county
            pixel_id = find(Counties == county_list(icnty));
            for j = 1:length(Nvar_names)
                pixel_id_non_zeros = pixel_id(GNLM_res.(Nvar_names{j})(pixel_id,1) ~=0);
                GNLM_stats.Counties.data{iyear,1}.(Nvar_names{j})(icnty,:) = [...
                    length(pixel_id)/4 ...
                    length(pixel_id_non_zeros)/4 ...
                    0.25 * sum(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                    mean(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                    mean(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1)) ...
                    std(GNLM_res.(Nvar_names{j})(pixel_id,1))...
                    std(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1))...
                    prctile(GNLM_res.(Nvar_names{j})(pixel_id,1), [0 10 25 50 75 90 95 99 99.9 100])];
            end

            %{
            %NgwDirect Statistics
            for ingw = 1:size(ngw_group_stat,1)
                pixel_id_ngw = find(model_input(:,end-1) == county_list(icnty) ...
                    & model_input(:,min(iyear,5)+4) >= ngw_group_stat(ingw,1) ...
                    & model_input(:,min(iyear,5)+4) <= ngw_group_stat(ingw,2));

                pixel_id_ngw_non_zeros = pixel_id_ngw(GNLM_res.(Nvar_names{4})(pixel_id_ngw,1) ~=0);
                GNLM_stats.Basins.data{iyear,1}.([Nvar_names{4} '_' ngw_group_name{ingw}])(icnty,:) = [...
                    length(pixel_id_ngw)/4 ...
                    length(pixel_id_ngw_non_zeros)/4 ...
                    0.25 * sum(GNLM_res.(Nvar_names{4})(pixel_id_ngw,1)) ...
                    mean(GNLM_res.(Nvar_names{j})(pixel_id_ngw,1)) ...
                    mean(GNLM_res.(Nvar_names{4})(pixel_id_ngw_non_zeros,1)) ...
                    std(GNLM_res.(Nvar_names{4})(pixel_id_ngw,1))...
                    std(GNLM_res.(Nvar_names{4})(pixel_id_ngw_non_zeros,1))...
                    prctile(GNLM_res.(Nvar_names{4})(pixel_id_ngw,1), [0 10 25 50 75 90 95 99 99.9 100])];
            end
            %}
        end
    end
    
    
    %-------------------------------------
    %stats per Land Use Group
    %-------------------------------------
    display('Land use groups');
    if idbg == 0 || idbg == 3
        for igrp = 1:size(LUgroups,1)
            GNLM_stats.LUGroup.name{igrp,1} = LUgroups{igrp,1};

            %find the pixels associated with this group
            pixel_id = false(N_pixels, 1);
            for j = 1:length(LUgroups{igrp,2})
                pixel_id( LU(:, min(iyear,5)) == Landuse_list{LUgroups{igrp,2}(j),2} ) = true;
            end
            pixel_id = find(pixel_id);

            for j = 1:length(Nvar_names)
                pixel_id_non_zeros = pixel_id(GNLM_res.(Nvar_names{j})(pixel_id,1) ~=0);
                GNLM_stats.LUGroup.data{iyear,1}.(Nvar_names{j})(igrp,:) = [...
                    length(pixel_id)/4 ...
                    length(pixel_id_non_zeros)/4 ...
                    0.25 * sum(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                    mean(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                    mean(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1)) ...
                    std(GNLM_res.(Nvar_names{j})(pixel_id,1))...
                    std(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1))...
                    prctile(GNLM_res.(Nvar_names{j})(pixel_id,1), [0 10 25 50 75 90 95 99 99.9 100])];
            end
        end 
    end
    

    %-------------------------------------
    %stats per land use
    %-------------------------------------
    display('LandUse');
    if idbg == 0 || idbg == 4
        for ilu = 1:size(Landuse_list,1)
            GNLM_stats.LUCaml.name{ilu,1} = Landuse_list{ilu,1};
            pixel_id = LU(:, min(iyear,5)) == Landuse_list{ilu,2};
            pixel_id = find(pixel_id);
            for j = 1:length(Nvar_names)
                pixel_id_non_zeros = pixel_id(GNLM_res.(Nvar_names{j})(pixel_id,1) ~=0);
                GNLM_stats.LUCaml.data{iyear,1}.(Nvar_names{j})(ilu,:) = [...
                    length(pixel_id)/4 ...
                    length(pixel_id_non_zeros)/4 ...
                    0.25 * sum(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                    mean(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                    mean(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1)) ...
                    std(GNLM_res.(Nvar_names{j})(pixel_id,1))...
                    std(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1))...
                    prctile(GNLM_res.(Nvar_names{j})(pixel_id,1), [0 10 25 50 75 90 95 99 99.9 100])];
            end
        end
    end
end
%%
save('GNLM_stats_2017_05_11','GNLM_stats');
write_stat_to_excel('OutputData\GNLM_output_stat_2017_05_11.xlsx', 'Basins', GNLM_stats.Basins.name, GNLM_stats.Basins.data, year_str)
write_stat_to_excel('OutputData\GNLM_output_stat_2017_05_11.xlsx', 'Counties', GNLM_stats.Counties.name, GNLM_stats.Counties.data, year_str)
write_stat_to_excel('OutputData\GNLM_output_stat_2017_05_11.xlsx', 'LUGroups', GNLM_stats.LUGroup .name, GNLM_stats.LUGroup.data, year_str)
write_stat_to_excel('OutputData\GNLM_output_stat_2017_05_11.xlsx', 'landUses', GNLM_stats.LUCaml.name, GNLM_stats.LUCaml.data, year_str)
%}
%% write spatial output
%
for iyear = 1:length(year_str)
    iyear
    clear temp GNLM_res
    temp = [];
    GNLM_res = load(['OutputData\' prefix_name num2str(year_str(iyear))]);
    Nvar_names = fieldnames(GNLM_res);
    for j = 1:length(Nvar_names)
        temp = [temp GNLM_res.(Nvar_names{j,1})];
    end
    
    fid = fopen(['OutputData\donot_sync_GNLM_Res' num2str(year_str(iyear)) '.dat'],'w');
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
%}
%% Make map for landuse groups
LU_GROUPS = -1*ones(N_pixels,5);

for i = 1:5
    for igrp = 1:size(LUgroups,1)
        [i igrp]
        pixel_id = false(N_pixels, 1);
        for j = 1:length(LUgroups{igrp,2})
            pixel_id(LU(:,i) == Landuse_list{LUgroups{igrp,2}(j),2}) = true;
        end
        pixel_id = find(pixel_id);
        LU_GROUPS(pixel_id,i) = igrp;
    end
end
fid = fopen('OutputData\donot_sync_LU_Groups.dat','w');
fprintf(fid, '%g %g %g %g %g\n', LU_GROUPS');
fclose(fid);
