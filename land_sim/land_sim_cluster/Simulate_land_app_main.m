function Simulate_land_app_main(year)
% debug parameter(Set this to 1 for the actual run)
deb_param = 1;


if year > 5
    error('The year must be less or equal to 5')
end
%% Import data
load('DirectAppFacilityDairies');
load('DirectAppFacilityWWTPFPBS');
load('LanduseTable201110166');

load('model_input')

%% Define the simulation order [rows in matrix]
% 1. Biosolids (4xxx)   [187 - 194]
% 2. Dairies (about 120 or so with FID numbers in the 1xxx and 2xxx)
% 3. WWTPs (30xx)       [1 - 54]
% 4. FPs (35xx and 36xx)    [55 - 186]

order_sim = [187:194 1:54 55:186]';
order_list = [1 length(187:194)];
order_list = [order_list;nan nan];
order_list = [order_list; order_list(1,2)+1 order_list(1,2) + length(1:54)];
order_list = [order_list; order_list(3,2)+1 order_list(3,2) + length(55:186)];
%% Define crop ids for each category
temp = cell2mat(LanduseTable201110166(:,4));
Crop_ids(1,1).ids = cell2mat(LanduseTable201110166(find(temp ~= 0 ),2));
temp = cell2mat(LanduseTable201110166(:,3));
Crop_ids(2,1).ids = cell2mat(LanduseTable201110166(find(temp ~= 0 ),2));
temp = cell2mat(LanduseTable201110166(:,4));
Crop_ids(3,1).ids = cell2mat(LanduseTable201110166(find(temp ~= 0 ),2));
temp = cell2mat(LanduseTable201110166(:,5));
Crop_ids(4,1).ids = cell2mat(LanduseTable201110166(find(temp ~= 0 ),2));
%% Main loop
% Select YEAR 
%   1    2    3    4    5
% 1945 1960 1975 1990 2005
YEARS = [1945 1960 1975 1990 2005];


new_pixels = zeros(500000,4);
cnt_new_pxl = 1;
print_every = 1000;
%start_in_new_pixel = 1;
for cat_id = 1:4 %This is the category id gets [1 2 3 4]
    cnt_indx = 0;
    
    print_this = 0;

    %Remove the pixels that cannot be selected
    candidate_ids = find(model_input(:,year+9) == 0);
    id_list_temp = [];
    for i = 1:length(Crop_ids(cat_id,1).ids)
        id_list_temp = [id_list_temp; find(model_input(candidate_ids,year+4) == Crop_ids(cat_id,1).ids(i,1))];
    end
    
    temp_model_input = [candidate_ids(id_list_temp) model_input(candidate_ids(id_list_temp),[3 4])]; 

    if cat_id == 2
        ids_in_app_fac_pixels = [];
        App_fac_pixels = [];
        for i = 1:size(DirectAppFacilityDairies,1)
            if strcmp(DirectAppFacilityDairies(i,7), 'SIMULATED')
                ids_in_app_fac_pixels = [ids_in_app_fac_pixels; i];
                App_fac_pixels = [App_fac_pixels; 0 round(str2double(DirectAppFacilityDairies(i,8))/0.25/deb_param)];
            end
        end
        App_fac_pixels(isnan(App_fac_pixels)) = 0;
    else
        App_fac_pixels = zeros(size(order_sim,1),2);
        App_fac_pixels(:,2) = round(cell2mat(DirectAppFacilityWWTPFPBS(1:194,4))./0.25/deb_param);
    end
    
    while 1
        if cat_id == 2
            cnt_indx = cnt_indx + 1;
            if cnt_indx > length(ids_in_app_fac_pixels)
                cnt_indx = 1;
            end
            fac_id = ids_in_app_fac_pixels(cnt_indx);
            fac_ij = cell2mat(DirectAppFacilityDairies(fac_id,5:6));
	    fac_id = cell2mat(DirectAppFacilityDairies(fac_id,1));
            current_app_fac_pixels = App_fac_pixels;
        else
            ids_in_app_fac_pixels = order_sim(order_list(cat_id,1):order_list(cat_id,2) ,:);
            current_app_fac_pixels = App_fac_pixels(ids_in_app_fac_pixels,:);
            %Next facility id data
            cnt_indx = cnt_indx + 1;
            if cnt_indx > length(ids_in_app_fac_pixels)
                cnt_indx = 1;
            end
            fac_id = ids_in_app_fac_pixels(cnt_indx);
            fac_ij = cell2mat(DirectAppFacilityWWTPFPBS(fac_id,7:8));
	    fac_id = cell2mat(DirectAppFacilityWWTPFPBS(fac_id,1));
        end
        
        Npixels_found = sum(current_app_fac_pixels(:,1));
        N_pixels_categry = sum(current_app_fac_pixels(:,2));
        %fprintf('NPixels %g out of %g\n', Npixels_found, N_pixels_categry);
        if Npixels_found >= N_pixels_categry
            %Move to the next category
            break;
        else
            if current_app_fac_pixels(cnt_indx,1) == current_app_fac_pixels(cnt_indx,2)
                continue;
            end

            if Npixels_found == print_this
		fprintf('NPixels %g out of %g\n', Npixels_found, N_pixels_categry);
		print_this = print_this + print_every;
	    end
            % find the nearest availabe pixel
            %dst = pdist2(fac_ij,temp_model_input(:,2:3));
            dst = sqrt((fac_ij(1,1) - temp_model_input(:,2)).^2 + (fac_ij(1,2) - temp_model_input(:,3)).^2);
            [c, d] = min(dst);
            
            new_pixels(cnt_new_pxl,:) = [temp_model_input(d,2:3) fac_id c];
	    model_input(temp_model_input(d,1), year+9) = fac_id;
            cnt_new_pxl = cnt_new_pxl + 1;
            % remove this pixel from the list of candidates
            temp_model_input(d,:) = [];
            if cat_id == 2
                App_fac_pixels(cnt_indx,1) = App_fac_pixels(cnt_indx,1) + 1;
            else
                App_fac_pixels(ids_in_app_fac_pixels(cnt_indx,1)) = App_fac_pixels(ids_in_app_fac_pixels(cnt_indx,1)) + 1;
            end
        end
    end
    %for j = start_in_new_pixel:cnt_new_pxl-1
    %    model_input(new_pixels(j,1),year+9) = new_pixels(j,2);
    %end
    %start_in_new_pixel = cnt_new_pxl;
end
new_pixels(cnt_new_pxl:end,:) = [];
save('-mat7-binary',['simulated_Year_' num2str(YEARS(year)) '.mat'], 'new_pixels');

   
