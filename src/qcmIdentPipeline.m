clear all;
close all;
%Use a default estimation data split of 0.7
estSplit = 0.7;

%Declare the number of experiments to generate data
numRuns = 20;

%Repeated execution is required to compute time cost of the functions.
%Therefore, we initialize a variable to calculate average time cost
avgComputeCost = zeros(6,numRuns-10);

%Generate the model response for two different stimuli - the pre-determined
%road profile from Simscape and a unit step input. Store input parameters
%as well as response data
[inputParams,totalResponseData,modelStepResponse] = generateQCM(numRuns);

%Perform model estimation over a desired number of times to capture time
%cost. Save the fit data
for loopCounter = 1:10  
        
    ss_fit = zeros(4,numRuns-10);
    n4s_fit= zeros(4,numRuns-10);
    tf_fit = zeros(4,numRuns-10);
    arx_fit = zeros(4,numRuns-10);
    OE_fit = zeros(4,numRuns-10);
    BJ_fit = zeros(4,numRuns-10);
    computeCost = zeros(6,numRuns-10);
    parfor itr = 10:numRuns
        
        responseData = totalResponseData(1:numRuns);
        [ymod, fit, ic, timeCost] = identifyQCM(estSplit,responseData);
        ss_fit(:,itr-9) = fit{1,1};
        n4s_fit(:,itr-9) = fit{2,2};
        tf_fit(:,itr-9) = fit{3,3};
        arx_fit(:,itr-9) = fit{4,4};
        OE_fit(:,itr-9) = fit{5,5};
        BJ_fit(:,itr-9) = fit{6,6};
        computeCost(:,itr-9) = timeCost;
    
    end
        avgComputeCost = avgComputeCost + computeCost;
        
end

avgComputeCost = avgComputeCost/loopCounter;

outputList = ["Vehicle Displacement","Vehicle Velocity","Suspension Displacement","Suspension Velocity"];
t = figure;
plot(10:numRuns,avgComputeCost(1,1:numRuns-9));
xlabel("Number of experiments");
ylabel("Computational Time Cost(s)");
hold on;
plot(10:numRuns,avgComputeCost(2,1:numRuns-9));
plot(10:numRuns,avgComputeCost(3,1:numRuns-9));
%plot(10:numRuns,computeCost(4,1:numRuns-9));
plot(10:numRuns,avgComputeCost(5,1:numRuns-9));
plot(10:numRuns,avgComputeCost(6,1:numRuns-9));
%legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
legend("State Space Model", "N4SID Model","Transfer Function Model","Output Error(OE) Model","Box Jenkins Model");

hold off;
exportgraphics(t,"TimeCostPlot.png")
fit = figure;
for j = 1:4

    subplot(2,2,j);
    plot(10:numRuns, ss_fit(j,1:numRuns-9));
    xlabel(outputList(j));
    ylabel("Percent Fit");
    hold on;
    plot(10:numRuns, n4s_fit(j,1:numRuns-9));
    plot(10:numRuns, tf_fit(j,1:numRuns-9));
    %plot(10:numRuns, arx_fit(j,1:numRuns-9));
    plot(10:numRuns, OE_fit(j,1:numRuns-9));
    plot(10:numRuns, BJ_fit(j,1:numRuns-9));
    %legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
    legend("State Space Model", "N4SID Model","Transfer Function Model","Output Error(OE) Model","Box Jenkins Model");
    hold off;
end

exportgraphics(fit,"OutputFit.png");