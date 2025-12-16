% In almost all the .xslx files the data is in the 2nd sheet of the file. 
% The following files give an error when importing data, since the data is
% not in Sheet no.2, kindly move the data sheet in the 2nd place for these 
% files mentioned below and everything will work normally.
% This error came up in the ending stages of the project which left me not
% enough time to work on a possible solution.

% Type 2
% CX2_36_9_23_10.xlsx
% 
% Type 3
% CX2_8_7_11_11.xlsx
% CX2_8_6_10_11.xlsx
% CX2_8_5_9_11.xlsx
% 
% Type 4
% cx2_3_7_11_11.xlsx
% cx2_3_6_7_11.xlsx
% cx2_3_6_10_11.xlsx


clear all

% % Define the directory where your .xlsx files are located
% folderPath = 'C:\M.Sc\SoSe 23\ML\Project\Battery CALCE-20230817\Type 4\CX2_3\CX2_3'; 
% xlsxFiles = dir(fullfile(folderPath, '*.xlsx'));
% dataStructArray = struct([]);
% 
% for i = 1:numel(xlsxFiles)  
%     filePath = fullfile(folderPath, xlsxFiles(i).name);
%     importedData = importdata(filePath);
%     dataStructArray(i).FileName = xlsxFiles(i).name;
%     dataStructArray(i).Data = importedData;
%     disp(['Data loaded from ' filePath]);
% end
% 
% importedData_tbl = struct2table(dataStructArray);
% 
% %% Creating a table for entire data
% 
% % xslxData_1 = xslxData.Data(1,1).data.Channel_10x2D006;
% [numTables,~] = size(importedData_tbl);
% 
% tableStruct = struct();
% 
% for i = 1:numTables
%     tableName = ['table_' num2str(i)];
%     % Replace the last variable after 'Data(i,1).data.xxx' before
%     % proceeding as follows
%     % CX2_16 - Channel_10x2D006
%     % CX2_33 - Channel_10x2D012
%     % CX2_35 - Channel_10x2D002
%     % CX2_34 - Channel_10x2D001  [Giving an error for some reason]
%     % CX2_36 - Channel_10x2D003
%     % CX2_37 - Channel_10x2D004
%     % CX2_38 - Channel_10x2D005
%     % CX2_8  - Channel_10x2D009
%     % CX2_3  - Channel_10x2D013
%     % CX2_32 - Channel_10x2D007
%     tableStruct.(tableName) = array2table(importedData_tbl.Data(i,1).data.Channel_10x2D007);
% end 
% 
% xslxData = [];
% 
% for i = 1:numTables    
%     tableName = ['table_' num2str(i)];
%     xslxData = vertcat(xslxData, tableStruct.(tableName));
% end   
% 
% sum(ismissing(xslxData))

% Define the directory where your .xlsx files are located
folderPath = 'C:\M.Sc\SoSe 23\ML\Project\Battery CALCE-20230817\Type 1\CX2_16\CX2_16';
xlsxFiles = dir(fullfile(folderPath, "*.xlsx"));

datastore = {};
xslxData = [];

% Loop through each Excel file in the folder
for i = 1:numel(xlsxFiles)
    currentFile = xlsxFiles(i).name;
    currentds = spreadsheetDatastore(fullfile(folderPath, currentFile),'Includesubfolders', true, 'FileExtensions', '.xlsx', 'VariableNamingRule', 'preserve');
    disp(['Data loaded from ' currentFile]);
    currentds.Sheets = [2]; 
    currentds.Range = 'A:Q';
    
    datastore{i} = currentds;
    %disp(['Data loaded from ' currentFile]);
end

% Combine individual datastores into a table
disp('Combining all datastores...')
xlsxDatastore = combine(datastore{:});

disp('Creating a table with data from all datastores...')
for i = 1:numel(xlsxFiles)
    temp = readall(xlsxDatastore.UnderlyingDatastores{1,i});
    xslxData = vertcat(xslxData,temp);
end


% Splitting Data into training and testing set

disp('Splitting data into training and testing set')
%define the ratio for train and test data
train_ratio = 0.7;  % Adjust this value as needed

%Calculate the number of rows for the train and test data
total_rows = size(xslxData, 1);
num_train_rows = floor(train_ratio * total_rows);
num_test_rows = total_rows - num_train_rows;

%Split the data into train and test
trainData = xslxData(1:num_train_rows, :);
testData = xslxData(num_train_rows+1:end,:);

disp('Ready for regression!')

%% Regression training Type 1

trainedModel = trainRegressionModel_Type1_xlsx(trainData);

% Predicting using trained Model and comparison with Test data
yfit = trainedModel.predictFcn(testData);
accuracy = median(yfit./testData.("Charge_Capacity(Ah)"));
MSE = trainedModel.LinearModel.MSE
RMSE = trainedModel.LinearModel.RMSE

% Plots
figure
plot(yfit,testData.("Charge_Capacity(Ah)"));
xlabel('Predicted values');
ylabel('Test data values');
title('Trained Model predicted values vs Test data');

figure
plot(trainedModel.LinearModel.Residuals,"Standardized"); 
xlabel('Predicted Response');
title('Residuals');