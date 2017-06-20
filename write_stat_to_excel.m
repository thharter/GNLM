function write_stat_to_excel(filename, sheetname, namedata, numericdata, yearlist)

% write the groupnames on the first column
fieldValuesNames = fieldnames(numericdata{1,1});
Noffset = length(namedata)+3;

% create the cell variable to hold the first row
temp_cell= {'';''};
cnt=3;
temp_data = [];
for i = 1:length(fieldValuesNames)
    temp_cell{cnt,1} =  fieldValuesNames{i,1};
    cnt=cnt+1;
    for j = 1:length(namedata)
        try
            temp_cell{cnt,1} = namedata{j,1}{1};
        catch
            temp_cell{cnt,1} = namedata{j,1};
        end
        cnt=cnt+1;
    end
    cnt=cnt+2;
end
xlswrite(filename, temp_cell, sheetname, 'A1');


%write the year data
data_explanation = {'ha (all)', 'ha (non zero)', 'Sum', 'Mean (all)', ...
                    'Mean (non zeros)', 'Std (all)',  'Std (non zero)', ...
                    'Min', '10%', '25%', 'Median', '75%', '90%', ...
                    '95%', '99%', '99.9%', 'Max'};
temp_cell = []; cnt = 1;
for i = 1:length(numericdata)
    for j = 1:length(data_explanation)
        if j == 5
             temp_cell{1,cnt} = num2str(yearlist(i));
        else
            temp_cell{1,cnt} = {''};
        end
        temp_cell{2,cnt} = data_explanation{1,j};
        cnt=cnt+1;
    end
    cnt=cnt+2;
    
end
xlswrite(filename, temp_cell, sheetname, 'B2');

temp_data_all = [];
for iyear = 1:length(numericdata)
    temp_data=[];
    for j = 1:length(fieldValuesNames)
        temp_data =[temp_data; numericdata{iyear,1}.(fieldValuesNames{j,1});nan(3,length(data_explanation))];
    end
    if iyear == 1
        temp_data_all = temp_data;
    else
        temp_data_all = [temp_data_all nan(size(temp_data,1),2) temp_data];
    end
end
xlswrite(filename, temp_data_all, sheetname, 'B4');

function S = num2xlrow(v)
% this function will convert 1->A, 2->B, etc.

if v <= 26
    S = char(v+64);
else
    % find how many abcs fit in the number
    n = floor(v/26);
    S = char(n+64);
    %add the remainder
    S=[S char(v - n*26 + 64)];
end