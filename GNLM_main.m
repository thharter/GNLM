%% GNLM CODE Version 2 
% see code outline :
% https://docs.google.com/document/d/1eynWP9TSKQukUsE9rlcsP4pXrpeaZp5CD0CBhSEPMFA/edit?usp=sharing
%% Define YEAR
% 1945  1960    1975    1990    2005    2020    2035    2050
%   1     2       3       4       5       6       7       8
clear
clc
iyear = 8;
year_str=[1945  1960    1975    1990    2005    2020    2035    2050];

year_col = min(iyear,5);
%% Read Input data
% main model input data
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

% Read attribute data
GW_Basin_ID = import_GW_Basins_attributes;

% Read excel tables
xls_path = 'Input_Data\data_17_04_24\';
TimeSeriesFile = 'TimeSeriesLandUse_CV_FREP_2017-0404.xlsx';
NIrrigationFile = 'NIrrigation2005Table_2015-0603.xlsx';
DirectAppFile = 'DirectAppFacility_2015-0706.xlsx';
LandUseFile = 'LanduseTable_2017_0419.xlsx';
ManureSalesFile = 'NmanureSale_2015-0706.xlsx';

TotalPeopleRatio = xlsread([xls_path TimeSeriesFile], 'TimeSeriesTable_Ratios','C1:C8');
TotalAnimalRatio = xlsread([xls_path TimeSeriesFile], 'TimeSeriesTable_Ratios','C9:C16');
NDepositionRatio = xlsread([xls_path TimeSeriesFile], 'TimeSeriesTable_Ratios','C17:C24'); % Read NdepositionRatio1
NIrrigationRatio = xlsread([xls_path TimeSeriesFile], 'TimeSeriesTable_Ratios','C41:C48');
NmanureSaleTotalCOUNTY = xlsread([xls_path ManureSalesFile], 'GNLM Nexport by County','B2:C30');

temp = xlsread([xls_path DirectAppFile], 'DirectAppFacility','A2:J1835');
DirAppFac.FACID = temp(:,1); 
DirAppFac.EFF_KgN_Y = temp(:,9);DirAppFac.EFF_KgN_Y(isnan(DirAppFac.EFF_KgN_Y)) = 0;
DirAppFac.PERC_KgN_Y = temp(:,10);DirAppFac.PERC_KgN_Y(isnan(DirAppFac.PERC_KgN_Y)) = 0;

temp = xlsread([xls_path TimeSeriesFile], 'TimeSeriesTableCrops','A2:E296');
TimeSeriesCrop = reshape(temp(:,3),5,295/5)'; % This is the Nnorm
NharvestSeries = reshape(temp(:,5),5,295/5)';
DWR_Codes = reshape(temp(:,1),5,295/5)';
DWR_Codes(:,2:end) = [];

NIrrigation2005Table = xlsread([xls_path NIrrigationFile], 'FinalNIrrigation2005','B2:C29');
% Replace the first 2 entries because they are read as nan
NIrrigation2005Table(1,1) = 5600;
NIrrigation2005Table(2,1) = 52100;

temp = xlsread([xls_path LandUseFile], 'FINAL Landuse Table','B2:E208');
LUT.DWR_code = temp(:,1);
LUT.Dairy = temp(:,2);
LUT.WWTP_B = temp(:,3);
LUT.FP = temp(:,4);
%% Initialize Output Variables
NgwDirect = zeros(N_pixels,1);

%% Preliminary modifications
for i = 1:5
    for j = [1 2 3 5]
        LU(DirApp(:,i) == j, i) = j + 10000;
    end
    LU(DirApp(:,i) > 6000 & DirApp(:,i) < 6500 ,i) = 16000;
    LU(DirApp(:,i) >= 6500 & DirApp(:,i) < 7000 ,i) = 16500;
    NgwDirect(LU(:,i) == 1601) = 30;
    NgwDirect(LU(:,i) == 1602) = 15;
end

% Below we compute each component of the N mass balance equation separately
%% Nseptic
% Nseptic = 4 * Septics * (365*0.85*13.3*1e-03) * TotalPeopleRatio
% Septics is the 16th column of the model_input
Nseptic = 4 * Septics * (365*0.85*13.3*1e-03) * TotalPeopleRatio(iyear);

%% Ndeposition 
% Ndeposition = Ndep * NdepositionRatio
% Ndep is the 15th column of the model_input
Ndeposition = Ndep * NDepositionRatio(iyear);

%% Nirrigation
Nirrigation = zeros(N_pixels,1);
% the 18th column of model_input is the ObjectID that points to the
% SubbasinID via the table GW_Basin_ID
for i = 3:size(NIrrigation2005Table,1)
    %find the objectid of the subbasin
    obj_id = GW_Basin_ID(GW_Basin_ID(:,2) == NIrrigation2005Table(i,1),1);
    if isempty(obj_id)
        continue
    end
    
    %set all pixels with this obj_id an NIrrigation value
    Nirrigation(Subbasins == obj_id) = NIrrigation2005Table(i,2) * NIrrigationRatio(iyear);
end

for i = 1:size(GW_Basin_ID,1)
    if ~isempty(find(NIrrigation2005Table(3:end,1) == GW_Basin_ID(i,2), 1))
        continue
    end
    if GW_Basin_ID(i,2) >= 5600 && GW_Basin_ID(i,2) <=5699
        tempTable = NIrrigation2005Table(1,2);
    elseif GW_Basin_ID(i,2) >= 52100 && GW_Basin_ID(i,2) <=52199
        tempTable = NIrrigation2005Table(2,2);
    else
        continue
    end
    Nirrigation(Subbasins == GW_Basin_ID(i,1)) = tempTable * NIrrigationRatio(iyear);
end

%% NgwDirect and NlandApplied
NlandApplied = zeros(N_pixels,1);

% Urban 
NgwDirect(DirApp(:,year_col) == 1) = 10 + 10;
% Lagoons (Also, remember to change the lagoon loading rate in the Matlab script to 1171 kg N/ha/year. This is from a recent California dairy industry report)
if iyear > 2; NgwDirect(DirApp(:,year_col) == 2) = 1171; end % old value 182.5
% Corrals
if iyear > 2; NgwDirect(DirApp(:,year_col) == 3) = 183; end
% Golf courses
NgwDirect(DirApp(:,year_col) == 5) = 10;

for i = 1:length(DirAppFac.FACID)
    [i length(DirAppFac.FACID)]
    %% Get all pixels that correspond to the Facility
    pixels_per_fac_id = find(DirApp(:,year_col) == DirAppFac.FACID(i,1));
    
    % Dairies
    if DirAppFac.FACID(i,1) >= 1001 && DirAppFac.FACID(i,1) <= 2999
        if iyear > 2
            temp_land_use_of_pixels = LU(pixels_per_fac_id, year_col);
            dlt = [];
            for j = 1:length(temp_land_use_of_pixels)
                if LUT.Dairy(LUT.DWR_code ==temp_land_use_of_pixels(j,1) ,1) ~= 1
                    dlt = [dlt;j];
                end
            end
            pixels_per_fac_id(dlt,:) = [];
            NlandApplied(pixels_per_fac_id, 1) = TotalAnimalRatio(iyear) * DirAppFac.EFF_KgN_Y(i,1) / (0.25*length(pixels_per_fac_id));
        end

    end
    
    % WWTP effluent application area in agriculture
    if DirAppFac.FACID(i,1) >= 3001 && DirAppFac.FACID(i,1) <= 3499
        NlandApplied(pixels_per_fac_id, 1) = TotalPeopleRatio(iyear) * DirAppFac.EFF_KgN_Y(i,1) / (0.25*length(pixels_per_fac_id));
    end
    % FP effluent application area in agriculture
    if DirAppFac.FACID(i,1) >= 3501 && DirAppFac.FACID(i,1) <= 3599
        NlandApplied(pixels_per_fac_id, 1) = TotalPeopleRatio(iyear) * DirAppFac.EFF_KgN_Y(i,1) / (0.25*length(pixels_per_fac_id));
    end
    
    % Biosolids application area in agriculture
    if DirAppFac.FACID(i,1) >= 4000 && DirAppFac.FACID(i,1) <= 4999
        NlandApplied(pixels_per_fac_id, 1) = TotalPeopleRatio(iyear) * DirAppFac.EFF_KgN_Y(i,1) / (0.25*length(pixels_per_fac_id));
    end
    
    % WWTP PercBasins
    if DirAppFac.FACID(i,1) >= 6000 && DirAppFac.FACID(i,1) <= 6499
        NgwDirect(pixels_per_fac_id, 1) = TotalPeopleRatio(iyear) * DirAppFac.PERC_KgN_Y(i,1) / (0.25*length(pixels_per_fac_id));
    end
    
    % FP PercBasins
    if DirAppFac.FACID(i,1) >= 6500 && DirAppFac.FACID(i,1) <= 6599
        NgwDirect(pixels_per_fac_id, 1) = TotalPeopleRatio(iyear) * DirAppFac.PERC_KgN_Y(i,1) / (0.25*length(pixels_per_fac_id));
    end
end

%% Nfertilizer

Nnorm  = zeros(N_pixels,1);
for i = 1:length(DWR_Codes)
    temp_id = find(LU(:, year_col) == DWR_Codes(i, 1));
    Nnorm(temp_id, 1) = TimeSeriesCrop(i, year_col);
end
Nfertilizer = 0.5*Nnorm + max(0,0.5*Nnorm - NlandApplied);

%% NmanureSale
NmanureSale = zeros(N_pixels,1);
% set Total Manure Sale Ratio according tothe simulation year
TotalManureSaleRatio = 0;
if iyear == 4
    TotalManureSaleRatio = 10/25;
elseif iyear > 4
    TotalManureSaleRatio = 1;
end

if TotalManureSaleRatio > 0
    %Get a unique list of county ids in Model_input
    study_area_county_ids = unique(Counties);
    % loop throught the counties
    for i_cnty = 1:length(study_area_county_ids)
       %find its NmanureSaleTotalCounty
       row_CNTY_table = find(NmanureSaleTotalCOUNTY(:,1) == study_area_county_ids(i_cnty));
       if isempty(row_CNTY_table)
           continue
       else
           if NmanureSaleTotalCOUNTY(row_CNTY_table,2) == 0
               continue
           else
               % we have reach that far only if this county has non zero NmanureSaleTotalCOUNTY
               % therefore we should do the required calculations
               
               %First we have to find the pixels of this county
               county_pixels = find(Counties == study_area_county_ids(i_cnty));
               dwr_cnty = LU(county_pixels, year_col);
               [dwr_cnt_unique, ic, ia] = unique(dwr_cnty);
               [C1,ic1,ia1] = intersect(dwr_cnt_unique, LUT.DWR_code);
               dwr_cnt_unique = [dwr_cnt_unique zeros(size(dwr_cnt_unique,1),1)];
               dwr_cnt_unique(ic1,2) =  LUT.Dairy(ia1);% we make a pair of unique dwr code and LUdrivenNsource type_Dairy
               %Map the driven Nsource type to dwr_cnty
               dwr_cnty = [dwr_cnty dwr_cnt_unique(ia,2)];
               %add a third column with the DirAppYear values
               dwr_cnty = [dwr_cnty DirApp(county_pixels, year_col)];
               %delete the pixels that are 0 in the second column (but allow NmanureSale on all pixels with LUT.Dairy = 1 or 2)
               dlt_id = dwr_cnty(:,2) == 0;
               county_pixels(dlt_id,:) = [];
               dwr_cnty(dlt_id,:) = [];
               %delete the pixel with 3xxx, 35xx, 4xxx
               dlt_id = dwr_cnty(:,3)>=3000 & dwr_cnty(:,3) < 5000;
               county_pixels(dlt_id,:) = [];
               dwr_cnty(dlt_id,:) = [];% This seems to have no impact on the code
               NmanureSaleAreaCOUNTY = 0.25 * length(county_pixels);
               NmanureSale(county_pixels,1) = 4* 0.25 * TotalManureSaleRatio * ...
                                                     TotalAnimalRatio(iyear) * ...
                                                     NmanureSaleTotalCOUNTY(row_CNTY_table,2) / ...
                                                     NmanureSaleAreaCOUNTY;
           end
       end
    end
end
%% Nharvest_actual 
Nharvest  = zeros(N_pixels,1);
for i = 1:length(DWR_Codes)
    temp_id = find(LU(:, year_col) == DWR_Codes(i, 1));
    Nharvest(temp_id, 1) = NharvestSeries(i,min(iyear,5));
end

Nirrigation(Nharvest == 0) = 0;

Nharvest_actual = min(Nharvest, 0.9*(Ndeposition + Nirrigation + Nfertilizer + ...
                                     NmanureSale + NlandApplied));
                                 
%% Nrunoff 
Nrunoff_actual = min(14, 0.9*(Ndeposition + Nirrigation + Nfertilizer + ...
                              NmanureSale + NlandApplied) - Nharvest_actual);

%% NGW
Ngw = zeros(N_pixels,1);

test_ngw_direct = false(N_pixels, 1);
for jj = [1601 1602 10001 10002 10003 10005]
    test_ngw_direct(LU(:,year_col) == jj) = true;
end
test_ngw_direct(LU(:,year_col) >10000) = true;
    
Ngw(test_ngw_direct, :) = NgwDirect(test_ngw_direct);
test_ngw_direct = ~test_ngw_direct;% invert the selection for efficiency
Ngw(test_ngw_direct,:) = Nseptic(test_ngw_direct,1) + NgwDirect(test_ngw_direct,1) + ...
                max(0, (0.9*(Ndeposition(test_ngw_direct,1) + Nirrigation(test_ngw_direct,1) + ...
                      Nfertilizer(test_ngw_direct,1) + NmanureSale(test_ngw_direct,1) + ...
                      NlandApplied(test_ngw_direct,1) - ...
                      Nharvest_actual(test_ngw_direct,1) - Nrunoff_actual(test_ngw_direct,1))));

%% NatmLosses 
NatmLosses = zeros(N_pixels,1);
NatmLosses(~test_ngw_direct, :) = 0;
NatmLosses(test_ngw_direct,:) = (0.15/0.85) * Nseptic(test_ngw_direct,1) + ...
                       0.1*(Ndeposition(test_ngw_direct,1) + Nirrigation(test_ngw_direct,1) + ...
                       Nfertilizer(test_ngw_direct,1) + NmanureSale(test_ngw_direct,1) + NlandApplied(test_ngw_direct,1)) + ...
                       (0.38/0.62)*(NmanureSale(test_ngw_direct,1) + NlandApplied(test_ngw_direct,1));

%% Ngw_nondirect
Ngw_nondirect = zeros(N_pixels,1);
Ngw_nondirect(test_ngw_direct,:) = max(0, 0.9*(Ndeposition(test_ngw_direct,1) + Nirrigation(test_ngw_direct,1)...
                                    + Nfertilizer(test_ngw_direct,1) + NmanureSale(test_ngw_direct,1) ...
                                    + NlandApplied(test_ngw_direct,1)) ...
                                    - Nharvest_actual(test_ngw_direct,1) - Nrunoff_actual(test_ngw_direct,1));
%% Save results
LU_year = LU(:, year_col);
DirApp_year = DirApp(:,year_col);

save(['OutputData\Output_GNLM_run_17_05_11_' num2str(year_str(iyear))],...
     'Ngw',...
     'Nrunoff_actual',...
     'Nharvest',...
     'Nharvest_actual',...
     'NmanureSale',...
     'Nfertilizer',...
     'Nnorm',...
     'NlandApplied',...
     'NgwDirect',...
     'Nirrigation',...
     'Ndeposition',...
     'Nseptic',...
     'NatmLosses',...
     'Ngw_nondirect',...
     'LU_year',...
     'DirApp_year'...
    );

