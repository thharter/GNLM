prefix_name = 'Output_GNLM_run_17_05_11_';
path_of_tempfiles = 'D:\GoogleDrive\giorgk_Gdrive\FREP 2012-2014\GNLM-CV\OutputData\';
xls_path = 'Input_Data\data_17_04_24\';
ManureSalesFile = 'NmanureSale_2015-0706.xlsx';%This is used to get a list of counties
LandUseFile = 'LanduseTable_2017_0419.xlsx';
%           1     2       3       4       5       6       7       8
year_str=[1945  1960    1975    1990    2005    2020    2035    2050];
load('Input_Data\model_in\model_input.mat')
%Break model_input into multiple arrays for better handling
XYRC = model_input(:,1:4); %x-y coordinates, row column
LU = model_input(:,5:9); %Land uses
DirApp = model_input(:,10:14);
Ndep = model_input(:,15);
Septics = model_input(:,16);
Counties = model_input(:,17);
Subbasins = model_input(:,18);
N_pixels = size(model_input,1);
clear model_input


% Basin categories
[GW_Basin_ID, GW_Basin_name] = import_GW_Basins_attributes;
subbasin_list = unique(Subbasins);

% County Categories
county_list = unique(Counties);
[~, ~, county_name_list] = xlsread([xls_path ManureSalesFile],'GNLM Nexport by County','A2:B30');
for i = 1:size(county_name_list,1)
    county_name_ids(i,1) = county_name_list{i,2};
end


%Land Use Categories
[~, ~, Landuse_list] = xlsread([xls_path LandUseFile],'FINAL Landuse Table','A2:B208');
[~, ~, Landuse_Groups] = xlsread([xls_path LandUseFile],'FINAL Landuse Table','F2:F208');
%for each landuse group assign a list of land uses
[LUgroups, lua,lub] = unique(Landuse_Groups);
for i = 1:length(LUgroups)
    LUgroups{i,2} = find(lub == i);
end

for i = 1:5
    for j = [1 2 3 5]
        LU(DirApp(:,i) == j, i) = j + 10000;
    end
    LU(DirApp(:,i) > 6000 & DirApp(:,i) < 6500 ,i) = 16000;
    LU(DirApp(:,i) >= 6500 & DirApp(:,i) < 7000 ,i) = 16500;
end


%county_name_list(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),NmanureSale20150706)) = {''};
%GNLM_stats.Basins.name{length(subbasin_list),1} = [];
%GNLM_stats.Basins.data{length(subbasin_list),1} = [];
% sort index for NvarNames 
dd = [3;2;4;6;7;8;5;10;9;11;14;12;1;13];

