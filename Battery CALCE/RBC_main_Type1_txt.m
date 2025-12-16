%% Importing Data from .txt files

clear all

% Define the directory where your .txt files are located
folderPath = 'C:\M.Sc\SoSe 23\ML\Project\Battery CALCE-20230817\Type 1\CX2_31\CX2_31';
txtFiles = dir(fullfile(folderPath, '*.txt'));
dataStruct = struct();

for i = 1:numel(txtFiles)
    txtFileName = fullfile(folderPath, txtFiles(i).name);
    importedData = importdata(txtFileName, '\t');
    dataStruct(i).filename = txtFiles(i).name;
    dataStruct(i).data = importedData;
    disp(['Data loaded from ' dataStruct(i).filename]);
end

importedData_tbl = struct2table(dataStruct);

% Creating a table for entire data
disp('Creating a table with data from data struct...')
[numTables,~] = size(importedData_tbl);

txtData = [];

for i = 1:numTables
    HammerSpace = importedData_tbl.data(i,1).data;
    txtData = vertcat(txtData, HammerSpace);
end    

disp('Splitting data into training and testing set')

% Splitting Data into training and testing set
%define the ratio for train and test data
train_ratio = 0.7;  % Adjust this value as needed

%Calculate the number of rows for the train and test data
total_rows = size(txtData, 1);
num_train_rows = floor(train_ratio * total_rows);
num_test_rows = total_rows - num_train_rows;

%Split the data into train and test
trainData = txtData(1:num_train_rows, :);
testData = txtData(num_train_rows+1:end,:);

disp('Ready for regression!')

%% Regression training Type 1

trainedModel = trainRegressionModel_Type1_txt(trainData)