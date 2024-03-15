clear all;
close all;
%Use a default estimation data split of 0.7
estSplit = 0.7;

%Declare the number of experiments to generate data
numRuns = 11;

%Repeated execution is required to compute time cost of the functions.
%Therefore, we initialize a variable to calculate average time cost
avgComputeCost = zeros(6,numRuns-10);

%Generate the model response for two different stimuli - the pre-determined
%road profile from Simscape and a unit step input. Store input parameters
%as well as response data
[inputParams,sbResponseData,stepResponse] = generateQCM(numRuns);


%Initiate a parfor loop to conduct parallel estimation

numRunsArray = 10:numRuns;
estSplitArray = floor(numRunsArray*estSplit);
valSplitArray = numRunsArray-estSplitArray;
computeCost = zeros(6,numRuns-9);

for runCount = 10:numRuns
    %Split the validation and estimation data based on estSplit
    est_data = merge(sbResponseData{1:estSplitArray(runCount-9)});
    val_data = merge(sbResponseData{estSplitArray(runCount-9):runCount});
    [sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ,timeCost] = identifyQCM(val_data);
    computeCost(:,runCount-9) = timeCost;
    %Compare model responses with validation data in each case
    [ymod_sb,fit_sb,ic_sb] = compare(val_data,sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ);
    %Compare step responses of estimated models with known step response data
    [ymod_step,fit_step,ic_step] = compare(stepResponse,sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ);

end




%Plot percent fit of the models versus number of runs

