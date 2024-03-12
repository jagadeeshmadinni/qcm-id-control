clear all;
close all;

estSplit = 0.3;

% parfor numRuns = 10:100
%     
%     [est_data,val_data,modelStepResponse] = generateQCM(numRuns);
%     [ymod, fit, ic] = identifyQCM(val_data,est_data);
% 
% end    

[inputParams,totalResponseData,modelStepResponse] = generateQCM();

numRuns = 15;

ss_fit = zeros(4,numRuns);
n4s_fit= zeros(4,numRuns);
tf_fit = zeros(4,numRuns);
arx_fit = zeros(4,numRuns);
OE_fit = zeros(4,numRuns);
BJ_fit = zeros(4,numRuns);
computeCost = zeros(6,numRuns);
for itr = 10:numRuns
    
    responseData = totalResponseData(1:numRuns);
    [ymod, fit, ic, timeCost] = identifyQCM(estSplit,responseData);
    ss_fit(:,itr) = fit{1,1};
    n4s_fit(:,itr) = fit{2,2};
    tf_fit(:,itr) = fit{3,3};
    arx_fit(:,itr) = fit{4,4};
    OE_fit(:,itr) = fit{5,5};
    BJ_fit(:,itr) = fit{6,6};
    computeCost(:,itr) = timeCost;

end

t = figure;
plot(10:numRuns,computeCost(1,10:numRuns));
xlabel("Number of experiments");
ylabel("Computational Time Cost(s)");
hold on;
plot(10:numRuns,computeCost(2,10:numRuns));
plot(10:numRuns,computeCost(3,10:numRuns));
plot(10:numRuns,computeCost(4,10:numRuns));
plot(10:numRuns,computeCost(5,10:numRuns));
plot(10:numRuns,computeCost(6,10:numRuns));
legend("Transfer Function Model","State Space Model", "N4SID Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
hold off;
exportgraphics(t,"TimeCostPlot.png")

fit = figure;
subplot(2,2,1);
plot(10:numRuns, ss_fit(1,10:numRuns));
xlabel("Vehicle Displacement");
ylabel("Percent Fit");
hold on;
plot(10:numRuns, n4s_fit(1,10:numRuns));
plot(10:numRuns, tf_fit(1,10:numRuns));
plot(10:numRuns, arx_fit(1,10:numRuns));
plot(10:numRuns, OE_fit(1,10:numRuns));
plot(10:numRuns, BJ_fit(1,10:numRuns));
legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
hold off;

subplot(2,2,2);
plot(10:numRuns, ss_fit(2,10:numRuns));
xlabel("Vehicle Velocity");
ylabel("Percent Fit");
hold on;
plot(10:numRuns, n4s_fit(2,10:numRuns));
plot(10:numRuns, tf_fit(2,10:numRuns));
plot(10:numRuns, arx_fit(2,10:numRuns));
plot(10:numRuns, OE_fit(2,10:numRuns));
plot(10:numRuns, BJ_fit(2,10:numRuns));
legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
hold off;

subplot(2,2,3);
plot(10:numRuns, ss_fit(3,10:numRuns));
xlabel("Suspension Displacement");
ylabel("Percent Fit");
hold on;
plot(10:numRuns, n4s_fit(3,10:numRuns));
plot(10:numRuns, tf_fit(3,10:numRuns));
plot(10:numRuns, arx_fit(3,10:numRuns));
plot(10:numRuns, OE_fit(3,10:numRuns));
plot(10:numRuns, BJ_fit(3,10:numRuns));
legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
hold off;

subplot(2,2,4);
plot(10:numRuns, ss_fit(4,10:numRuns));
xlabel("Suspension Velocity");
ylabel("Percent Fit");
hold on;
plot(10:numRuns, n4s_fit(4,10:numRuns));
plot(10:numRuns, tf_fit(4,10:numRuns));
plot(10:numRuns, arx_fit(4,10:numRuns));
plot(10:numRuns, OE_fit(4,10:numRuns));
plot(10:numRuns, BJ_fit(4,10:numRuns));
legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
hold off;
exportgraphics(fit,"OutputFit.png");