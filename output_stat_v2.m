% This script generates the stats for selected regions
% to configure the input data change the file
%output_stat_common_input_data.m
%
output_stat_common_input_data;

% Now assign an id for each pixel according to the desired statistic 
% classification
% for counties or subregions this is simply 
% region_cat = Counties;
% or 
% region_cat = Subbasins;
% In general you have either to provide a linear array with the ids of the 
% classification regions and a cell list that maps each region id to a
% string name
%=====================Basin Group==========================================
% below is an example where the pixel are classified according to the three
% basins
Region_Names{1,1} = 'SacV';Region_Names{1,2} = 1;
Region_Names{2,1} = 'SJV';Region_Names{2,2} = 2;
Region_Names{3,1} = 'TLB';Region_Names{3,2} = 3;
%Kern, Kings, Tulare, Fresno => TLB
%Madera, Merced, Stanislaus, San Joaquin, Contra Costa => SJV
%all the other named counties =>  SacV
Basin_county_id{1,1} = [7 11 21 61 67 89 95 101 103 113 115];
Basin_county_id{2,1} = [13 39 47 77 99];
Basin_county_id{3,1} = [19 29 31 107];
region_cat = nan(N_pixels,1);
for i = 1:length(Basin_county_id)
    for j = 1:length(Basin_county_id{i,1})
        id = find(Counties == Basin_county_id{i,1}(j));
        region_cat(id,1) = i;
    end
end
%--------------------------------------------------------------------------


for iyear = 1:length(year_str)
    display(num2str(year_str(iyear)));
    GNLM_res = load([path_of_tempfiles prefix_name num2str(year_str(iyear))]);
    Nvar_names = fieldnames(GNLM_res);
    Nvar_names = Nvar_names(dd);
    for ireg = 1:length(Region_Names)
        
        % some county names are identified as nans.
        % Here we set the names as County_id in the model input file
        % temp = find(Region_Names_ids == county_list(ireg));
        %if isnan(county_name_list{temp,1})
        %    GNLM_stats.Regions(ireg,1).name = ['Region_' num2str(county_name_ids(temp))];
        %else
            GNLM_stats.Regions(ireg,1).name = Region_Names{ireg,1};
        %end
        display([num2str(ireg) ' out of ' num2str(length(Region_Names))]);
        %find the pixels for the current county
        pixel_id_region = find(region_cat == Region_Names{ireg,2});

        
        for igrp = 1:size(LUgroups,1)
           % find the pixel of the current LUgroup for this county only
           pixel_id_LUgrp = false(N_pixels, 1);
           for j = 1:length(LUgroups{igrp,2})
               pixel_id_LUgrp( LU(:, min(iyear,5)) == Landuse_list{LUgroups{igrp,2}(j),2} ) = true;
           end
           pixel_id_LUgrp = find(pixel_id_LUgrp);
           pixel_id = intersect(pixel_id_LUgrp,pixel_id_region);
           GNLM_stats.Regions(ireg,1).LUgroups(igrp,1).name = LUgroups{igrp,1};
           if ~isempty(pixel_id)
               for j = 1:length(Nvar_names)
                   pixel_id_non_zeros = pixel_id(GNLM_res.(Nvar_names{j})(pixel_id,1) ~=0);
                   
                   GNLM_stats.Regions(ireg,1).LUgroups(igrp,1).data(iyear,1).(Nvar_names{j}) = [ ...
                       length(pixel_id)/4 ...
                       length(pixel_id_non_zeros)/4 ...
                       0.25 * sum(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                       mean(GNLM_res.(Nvar_names{j})(pixel_id,1)) ...
                       mean(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1)) ...
                       std(GNLM_res.(Nvar_names{j})(pixel_id,1))...
                       std(GNLM_res.(Nvar_names{j})(pixel_id_non_zeros,1))...
                       prctile(GNLM_res.(Nvar_names{j})(pixel_id,1), [0 10 25 50 75 90 95 99 99.9 100])...
                   ];
               end
           end
        end
    end
end
%
%% write STATS to excel
% The first column is a list of GNLM output variables folloed by a list of
% LUgroups
clear firstCol secrow thirdrow temp_all_data
firstCol = {'';''}; % two first rows are blank
cnt = 3;
for i = 1:length(Nvar_names)
    firstCol{cnt,1} = Nvar_names{i};
    cnt = cnt+1;
   for j = 1:length(LUgroups)
       firstCol{cnt,1} = LUgroups{j,1};
       cnt = cnt+1;
   end
   cnt = cnt+2;
end

data_explanation = {'ha (all)', 'ha (non zero)', 'Sum', 'Mean (all)', ...
                    'Mean (non zeros)', 'Std (all)',  'Std (non zero)', ...
                    'Min', '10%', '25%', 'Median', '75%', '90%', ...
                    '95%', '99%', '99.9%', 'Max'};

% the first two rows contain the year and the stats
cnt = 1;
for i = 1:length(year_str)
   secrow{1, (i-1)*(length(data_explanation)+2)+5} =  year_str(i);
   for j = 1:length(data_explanation)
       thirdrow{1,cnt} = data_explanation{j};
       cnt = cnt+1;
   end
   cnt = cnt + 2;
end

% for each spreadsheet prepare the data
for ireg = 1:length(GNLM_stats.Regions)
    
    sheetname = GNLM_stats.Regions(ireg).name;
    display([num2str(ireg) sheetname])
    temp_all_data = [];
    for i = 1:length(Nvar_names)
        for ilu = 1:length(LUgroups)
            temp_one_line = [];
            if isempty(GNLM_stats.Regions(ireg).LUgroups(ilu).data)
                temp_one_line = [temp_one_line nan(1,171)];
            else
                for iyr = 1:size(GNLM_stats.Regions(ireg).LUgroups(ilu).data,1)
                    if isempty(GNLM_stats.Regions(ireg).LUgroups(ilu).data(iyr,1).(Nvar_names{i}))
                        temp_one_line = [temp_one_line nan(1,19)];
                    else
                        temp_one_line = [temp_one_line GNLM_stats.Regions(ireg).LUgroups(ilu).data(iyr,1).(Nvar_names{i}) nan nan];
                    end
                end
                for ii = iyr:8
                    temp_one_line = [temp_one_line nan(1,19)];
                end
            end
            % add this line to the final matrix
            temp_all_data = [temp_all_data; temp_one_line];
        end
        temp_all_data = [temp_all_data; nan(3,171)];
    end
    xlswrite('Basin_LU_Stats_2017_05_11', firstCol, sheetname, 'A1');
    xlswrite('Basin_LU_Stats_2017_05_11', secrow, sheetname, 'B2');
    xlswrite('Basin_LU_Stats_2017_05_11', thirdrow, sheetname, 'B3');
    xlswrite('Basin_LU_Stats_2017_05_11', temp_all_data, sheetname, 'B4');
end

