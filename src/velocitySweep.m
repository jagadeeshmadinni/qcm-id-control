clear all;
close all;
%Use a default estimation data split of 0.7
estSplit = 0.7;
maxVel = 100;
%Declare the number of experiments to generate data
numRuns = size(10:maxVel,2);

%Repeated execution is required to compute time cost of the functions.
%Therefore, we initialize a variable to calculate average time cost
avgComputeCost = zeros(6,maxVel-9);
%Generate the model response for two different stimuli - the pre-determined
%road profile from Simscape and a unit step input. Store input parameters
%as well as response data
[inputParams,sbResponseData,stepResponse] = generateResponseVel(maxVel);


%Initiate a parfor loop to conduct parallel estimation

numRunsArray = 10:maxVel;
runSize = size(numRunsArray,2);
estSplitArray = floor(numRunsArray*estSplit);
valSplitArray = numRunsArray-estSplitArray;
computeCost = zeros(6,runSize);
fit_sb_array = zeros(runSize,4,6);
fit_step_array = zeros(runSize,4,6);


parfor runCount = 10:maxVel
    %Split the validation and estimation data based on estSplit
    est_data = merge(sbResponseData{1:estSplitArray(runCount-9)});
    val_data = merge(sbResponseData{estSplitArray(runCount-9)+1:runCount});
    [sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ,timeCost] = identifyQCM(est_data);
    computeCost(:,runCount-9) = timeCost;

    %Compare model responses with validation data in each case
    [ymod_sb,fit_sb,ic_sb] = compare(val_data,sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ);
    avg_fit_sb = reshape(mean(cell2mat(fit_sb),2),[4,6]);
    fit_sb_array(runCount-9,:,:) = avg_fit_sb; 
    %Compare step responses of estimated models with known step response data
    step_val_data = getexp(stepResponse,estSplitArray(runCount-9)+1:runCount);
    [ymod_step,fit_step,ic_step] = compare(step_val_data,sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ);
    avg_fit_step = reshape(mean(cell2mat(fit_step),2),[4,6]);
    fit_step_array(runCount-9,:,:) = avg_fit_step;

end

%Plot percent fit of the models versus number of runs

outputList = ["Vehicle Displacement","Vehicle Velocity","Suspension Displacement","Suspension Velocity"];
t = figure;
plot(10:maxVel,computeCost(1,1:maxVel-9));
xlabel("Number of experiments");
ylabel("Computational Time Cost(s)");
hold on;
plot(10:maxVel,computeCost(2,1:maxVel-9));
plot(10:maxVel,computeCost(3,1:maxVel-9));
%plot(10:maxVel,computeCost(4,1:maxVel-9));
plot(10:maxVel,computeCost(5,1:maxVel-9));
plot(10:maxVel,computeCost(6,1:maxVel-9));
%legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
legend("State Space Model", "N4SID Model","Transfer Function Model","Output Error(OE) Model","Box Jenkins Model");

hold off;
exportgraphics(t,"TimeCostPlot.png")
fit = figure;
for j = 1:4

    subplot(2,2,j);
    plot(10:maxVel, fit_sb_array(:,j,1));
    title(outputList(j));
    xlabel("Number of experiments");
    ylabel("Percent Fit");
    hold on;
    plot(10:maxVel, fit_sb_array(:,j,2));
    plot(10:maxVel, fit_sb_array(:,j,3));
    %plot(10:maxVel, fit_sb_array(:,j,4));
    plot(10:maxVel, fit_sb_array(:,j,5));
    plot(10:maxVel, fit_sb_array(:,j,6));
    %legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
    legend("State Space Model", "N4SID Model","Transfer Function Model","Output Error(OE) Model","Box Jenkins Model");
    hold off;
end

exportgraphics(fit,"OutputFit.png");


step_fit = figure;
for itr = 1:4

    subplot(2,2,itr);
    plot(10:maxVel, fit_step_array(:,itr,1));
    title(outputList(itr));
    xlabel("Number of experiments");
    ylabel("Percent Fit");
    hold on;
    plot(10:maxVel, fit_step_array(:,itr,2));
    plot(10:maxVel, fit_step_array(:,itr,3));
    %plot(10:maxVel, fit_step_array(:,itr,4));
    plot(10:maxVel, fit_step_array(:,itr,5));
    plot(10:maxVel, fit_step_array(:,itr,6));
    %legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
    legend("State Space Model", "N4SID Model","Transfer Function Model","Output Error(OE) Model","Box Jenkins Model");
    hold off;
end

exportgraphics(step_fit,"OutputStepFit.png");

