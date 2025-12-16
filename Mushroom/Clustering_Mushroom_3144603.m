%% Importing Data

% Save this file in the same folder with the Mushroom data extracted from
% the .zip file

clc
clear all


data = readtable('agaricus-lepiota.data','FileType','text');
fprintf('Dataset size: %d samples, %d features\n', size(data,1), size(data,2));


% No. of missing data
missing_data = sum(char(data{:,:}) == '?')

% Replacing missing data
missing_column=data(:,12);
d=size(missing_column);

for i=1:d
    missing_column(i,:) = fillmissing(data(i,12),"knn",5);
end

data(:,12) = missing_column;

% Categorising given data
cats = categorical(data{:,:});
data_1 = double(cats);

%% Determining optimal number of clusters

data_1 = zscore(data_1);
% Linkages

Z = linkage(data_1, "average", "cityblock");
figure
dendrogram(Z)
title('Hierarchy of clusters')
% grp_1 = cluster(Z,"maxclust",2);

Y = pdist(data_1, "cityblock");
c = cophenet(Z,Y)

% Determining optimum number of cluster for given Data
clustEv = evalclusters(data_1,"kmeans","silhouette","KList",2:8, "Distance","cityblock")
OptK = clustEv.OptimalK

%% kmeans Clustering with PCA

% Principal Component Analysis (PCA)
[pcs,scrs,~,~,pexp] = pca(data_1);

figure
pareto(pexp)
xlabel('Principal Component');
ylabel('Variance Explained (%)');
title('Pareto Chart for PCA');

% scatter(scrs(:,1),scrs(:,2),10)

% kmeans Clustering

% Following line can be used to cluster given data according to optimal no.
% of clusters found by evalclusters function in the previous section

%[grp,C] = kmeans(data_1,OptK,"Start","cluster","Replicates",5);

% For our case, considering number of clusters to be 2 (poisonous & edible)
k = 2;

[grp,C] = kmeans(data_1,k,"Start","cluster","Distance","cityblock","Replicates",10, "MaxIter", 500);
figure
gscatter(scrs(:,1),scrs(:,2),grp)
title('kmeans Clustering with 2 clusters');
xlabel('Principal Component 1');
ylabel('Principal Component 2');

%% Evaluating Cluster Quality using Silhouette

figure
silhouette(data_1,grp, "cityblock")
title('Silhouette: k-means Clustering')

% Step 6: Calculate Silhouette Scores
silhouette_scores = silhouette(data_1, grp, "cityblock");
average_silhouette = mean(silhouette_scores);

fprintf('Average Silhouette Score for k-means Clustering: %.4f\n', average_silhouette)



%% Gaussian Mixture Model with Multidimensional scaling 

% Multidimensional scaling
dist = pdist(data_1, "cityblock");
[X,e] = cmdscale(dist,2);

figure
pareto(e)
xlabel('Principal Component');
ylabel('Variance Explained (%)');
title('Pareto Chart for Multidimensional Scaling');


% GMM Clustering
mdl= fitgmdist(X,k,"CovarianceType", "diagonal", "RegularizationValue",0.001, "Replicates", 5);
grp1= cluster(mdl,X);

figure
gscatter(X(:,1),X(:,2),grp1)
title('GMM Clustering with 2 clusters');
xlabel('Principal Component 1');
ylabel('Principal Component 2');

%% Evaluating Cluster Quality using Silhouette

figure
silhouette(data_1, grp1, "cityblock")
title('Silhouette: GMM Clustering')

% Step 6: Calculate Silhouette Scores
silhouette_scores = silhouette(data_1, grp1, "cityblock");
average_silhouette_1 = mean(silhouette_scores);

fprintf('Average Silhouette Score for GMM Clustering: %.4f\n', average_silhouette_1)

